import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

/// REST cho phía NHÂN VIÊN (ADMIN): quản lý danh sách hội thoại & trả lời khách.
class AdminChatApi {
  static const String _base = '/api/v1/admin/chat';
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _decode(http.Response res) async {
    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body.isEmpty ? <String, dynamic>{} : json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  /// Danh sách hội thoại (mặc định OPEN), sắp xếp mới nhất trước.
  Future<List<Conversation>> listConversations({
    String status = 'OPEN',
    int page = 0,
    int size = 50,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/conversations').replace(
      queryParameters: {'status': status, 'page': page.toString(), 'size': size.toString()},
    );
    final headers = await ApiConfig.getHeaders();
    final res = await http.get(url, headers: headers).timeout(_timeout);
    final j = await _decode(res);
    final page0 = j['data'] as Map<String, dynamic>;
    final content = page0['content'] as List<dynamic>? ?? [];
    return content
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lịch sử tin nhắn của 1 hội thoại (mới → cũ).
  Future<List<ChatMessage>> getMessages(int conversationId, {int? before, int size = 20}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/conversations/$conversationId/messages').replace(
      queryParameters: {
        if (before != null) 'before': before.toString(),
        'size': size.toString(),
      },
    );
    final headers = await ApiConfig.getHeaders();
    final res = await http.get(url, headers: headers).timeout(_timeout);
    final j = await _decode(res);
    final data = j['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Trả lời khách.
  Future<ChatMessage> reply(int conversationId, String content) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/conversations/$conversationId/messages');
    final headers = await ApiConfig.getHeaders();
    final res = await http
        .post(url, headers: headers, body: json.encode({'content': content}))
        .timeout(_timeout);
    final j = await _decode(res);
    return ChatMessage.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Đánh dấu nhân viên đã đọc hội thoại.
  Future<void> markRead(int conversationId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/conversations/$conversationId/read');
    final headers = await ApiConfig.getHeaders();
    final res = await http.patch(url, headers: headers).timeout(_timeout);
    await _decode(res);
  }
}
