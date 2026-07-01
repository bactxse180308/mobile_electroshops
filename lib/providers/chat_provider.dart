import 'package:flutter/foundation.dart';
import '../core/constants/app_strings.dart';
import '../features/chat/models/chat_message.dart';
import '../features/chat/models/sender_role.dart';
import '../features/chat/services/chat_api.dart';
import '../features/chat/services/chat_socket.dart';

enum ChatStatus { initial, loading, success, empty, error }

/// Chat State (phía KHÁCH) — global: giữ kết nối WebSocket khi đã đăng nhập để
/// đếm tin chưa đọc (badge) ngay cả khi không mở màn chat.
class ChatProvider extends ChangeNotifier {
  final ChatApi _api;
  final ChatSocket _socket;

  ChatProvider({required ChatApi api, required ChatSocket socket})
      : _api = api,
        _socket = socket;

  static const int _pageSize = 20;

  final List<ChatMessage> _messages = []; // cũ → mới
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  ChatStatus _status = ChatStatus.initial;
  ChatStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasMore = true;
  bool _loadingOlder = false;
  bool get loadingOlder => _loadingOlder;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _started = false;
  bool _historyLoaded = false;
  bool _viewing = false;

  int? get lastCustomerMessageId {
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isFromCustomer) return _messages[i].id;
    }
    return null;
  }

  /// Gọi sau khi đăng nhập (role CUSTOMER): mở socket + lấy số tin chưa đọc cho badge.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    // KHÔNG gọi getConversation ở đây để tránh tạo hội thoại rỗng cho mọi khách
    // vừa đăng nhập (sẽ làm rác inbox admin). Hội thoại chỉ tạo khi khách gửi tin.
    // Badge đếm tin đến realtime trong phiên; mở chat sẽ đồng bộ phần còn lại.
    await _socket.connect(_onIncoming);
    notifyListeners();
  }

  /// Mở màn chat: nạp lịch sử (lần đầu), đánh dấu đã đọc, xoá badge.
  Future<void> enterChat() async {
    _viewing = true;
    await start(); // đảm bảo socket đã mở (vd mở chat từ trang sản phẩm)
    if (!_historyLoaded) {
      _status = ChatStatus.loading;
      notifyListeners();
      try {
        final history = await _api.getHistory(size: _pageSize);
        _messages
          ..clear()
          ..addAll(history.reversed);
        _hasMore = history.length == _pageSize;
        _historyLoaded = true;
        _status = _messages.isEmpty ? ChatStatus.empty : ChatStatus.success;
      } catch (_) {
        _errorMessage = AppStrings.chatLoadError;
        _status = ChatStatus.error;
        notifyListeners();
        return;
      }
    }
    _unreadCount = 0;
    notifyListeners();
    try {
      await _api.markRead();
    } catch (_) {}
  }

  /// Rời màn chat (KHÔNG ngắt socket — vẫn cần đếm tin để hiện badge).
  void leaveChat() {
    _viewing = false;
  }

  Future<void> sendMessage(String text, {int? productId}) async {
    final content = text.trim();
    if (content.isEmpty && productId == null) return;
    final sent = await _api.sendText(content, productId: productId);
    _appendUnique(sent);
    _status = ChatStatus.success;
    notifyListeners();
  }

  Future<void> loadOlder() async {
    if (_loadingOlder || !_hasMore || _messages.isEmpty) return;
    _loadingOlder = true;
    notifyListeners();
    try {
      final older = await _api.getHistory(before: _messages.first.id, size: _pageSize);
      _messages.insertAll(0, older.reversed);
      _hasMore = older.length == _pageSize;
    } catch (_) {}
    _loadingOlder = false;
    notifyListeners();
  }

  void _onIncoming(ChatMessage message) {
    if (message.senderRole == SenderRole.staff) {
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].isFromCustomer && !_messages[i].read) {
          _messages[i] = _messages[i].copyWith(read: true);
        }
      }
      if (!_viewing) _unreadCount++;
    }
    if (_historyLoaded) {
      _appendUnique(message);
      _status = ChatStatus.success;
    }
    notifyListeners();
    if (_viewing) {
      _unreadCount = 0;
      _api.markRead().catchError((_) {});
    }
  }

  void _appendUnique(ChatMessage m) {
    if (_messages.any((x) => x.id == m.id)) return;
    _messages.add(m);
  }

  /// Gọi khi đăng xuất: ngắt socket & xoá sạch state.
  void reset() {
    _socket.disconnect();
    _messages.clear();
    _unreadCount = 0;
    _started = false;
    _historyLoaded = false;
    _viewing = false;
    _status = ChatStatus.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
