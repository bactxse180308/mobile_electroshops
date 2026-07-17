import 'package:flutter/foundation.dart';
import '../core/constants/app_strings.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/sender_role.dart';
import '../services/admin_chat_api.dart';
import '../services/chat_socket.dart';
import 'chat_provider.dart' show ChatStatus;

/// Chat State (phía ADMIN) — global: danh sách hội thoại + hội thoại đang mở.
/// Subscribe `/topic/support` để nhận mọi tin của khách realtime, cập nhật badge.
class AdminChatProvider extends ChangeNotifier {
  final AdminChatApi _api;
  final ChatSocket _socket;

  AdminChatProvider({required AdminChatApi api, required ChatSocket socket})
      : _api = api,
        _socket = socket;

  static const int _pageSize = 20;

  // ── Danh sách hội thoại ──────────────────────────────────────────────────
  final List<Conversation> _conversations = [];
  List<Conversation> get conversations => List.unmodifiable(_conversations);

  ChatStatus _listStatus = ChatStatus.initial;
  ChatStatus get listStatus => _listStatus;

  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  bool _started = false;

  // ── Hội thoại đang mở ────────────────────────────────────────────────────
  int? _activeId;
  int? get activeId => _activeId;

  final List<ChatMessage> _messages = []; // cũ → mới
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  ChatStatus _activeStatus = ChatStatus.initial;
  ChatStatus get activeStatus => _activeStatus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasMore = true;
  bool _loadingOlder = false;
  bool get loadingOlder => _loadingOlder;

  /// id tin cuối của NHÂN VIÊN → chỉ tin này hiện trạng thái đã gửi/đã đọc.
  int? get lastStaffMessageId {
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isFromCustomer) return _messages[i].id;
    }
    return null;
  }

  /// Gọi sau khi đăng nhập (role ADMIN): mở socket + nạp danh sách hội thoại.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _socket.connect(_onTopic, destination: '/topic/support');
    await loadConversations();
  }

  Future<void> loadConversations() async {
    _listStatus = ChatStatus.loading;
    notifyListeners();
    try {
      final list = await _api.listConversations();
      _conversations
        ..clear()
        ..addAll(list);
      _listStatus = _conversations.isEmpty ? ChatStatus.empty : ChatStatus.success;
    } catch (_) {
      _errorMessage = AppStrings.chatLoadError;
      _listStatus = ChatStatus.error;
    }
    notifyListeners();
  }

  Future<void> openConversation(int conversationId) async {
    _activeId = conversationId;
    _messages.clear();
    _activeStatus = ChatStatus.loading;
    notifyListeners();
    try {
      final history = await _api.getMessages(conversationId, size: _pageSize);
      _messages.addAll(history.reversed);
      _hasMore = history.length == _pageSize;
      _activeStatus = _messages.isEmpty ? ChatStatus.empty : ChatStatus.success;
    } catch (_) {
      _errorMessage = AppStrings.chatLoadError;
      _activeStatus = ChatStatus.error;
    }
    _setUnread(conversationId, 0);
    notifyListeners();
    try {
      await _api.markRead(conversationId);
    } catch (_) {}
  }

  void leaveConversation() {
    _activeId = null;
  }

  Future<void> sendReply(String text) async {
    final content = text.trim();
    final id = _activeId;
    if (content.isEmpty || id == null) return;
    final sent = await _api.reply(id, content);
    _appendUnique(sent);
    _activeStatus = ChatStatus.success;
    notifyListeners();
  }

  Future<void> loadOlder() async {
    final id = _activeId;
    if (_loadingOlder || !_hasMore || _messages.isEmpty || id == null) return;
    _loadingOlder = true;
    notifyListeners();
    try {
      final older = await _api.getMessages(id, before: _messages.first.id, size: _pageSize);
      _messages.insertAll(0, older.reversed);
      _hasMore = older.length == _pageSize;
    } catch (_) {}
    _loadingOlder = false;
    notifyListeners();
  }

  void _onTopic(ChatMessage message) {
    final convId = message.conversationId;
    final idx = _conversations.indexWhere((c) => c.id == convId);

    if (idx < 0) {
      // Hội thoại mới (khách lần đầu nhắn) → nạp lại danh sách.
      loadConversations();
      return;
    }

    final viewing = convId == _activeId;
    if (viewing) {
      _appendUnique(message);
      _activeStatus = ChatStatus.success;
      _setUnread(convId, 0);
      _api.markRead(convId).catchError((_) {});
    } else if (message.senderRole == SenderRole.customer) {
      final c = _conversations[idx];
      _conversations[idx] = c.copyWith(
        unreadCount: c.unreadCount + 1,
        lastMessageAt: message.createdAt,
      );
    }
    _bumpToTop(convId);
    notifyListeners();
  }

  void _setUnread(int convId, int value) {
    final idx = _conversations.indexWhere((c) => c.id == convId);
    if (idx >= 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: value);
    }
  }

  void _bumpToTop(int convId) {
    final idx = _conversations.indexWhere((c) => c.id == convId);
    if (idx > 0) {
      final c = _conversations.removeAt(idx);
      _conversations.insert(0, c);
    }
  }

  void _appendUnique(ChatMessage m) {
    if (_messages.any((x) => x.id == m.id)) return;
    _messages.add(m);
  }

  void reset() {
    _socket.disconnect();
    _conversations.clear();
    _messages.clear();
    _activeId = null;
    _started = false;
    _listStatus = ChatStatus.initial;
    _activeStatus = ChatStatus.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
