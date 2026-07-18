import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

/// Tách logic gọi REST khỏi UI (gửi tin = POST, lịch sử = GET).
/// API khách KHÔNG nhận conversationId — server suy từ JWT (chống IDOR).
class ChatApi {
  static const String _base = '/api/v1/chat';
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _decode(http.Response res) async {
    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body.isEmpty
          ? <String, dynamic>{}
          : json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode}');
  }

  /// Lấy/tạo hội thoại đang mở của tôi.
  Future<Conversation> getConversation() async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/conversation');
    final headers = await ApiConfig.getHeaders();
    final res = await http.get(url, headers: headers).timeout(_timeout);
    final j = await _decode(res);
    return Conversation.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Lịch sử tin nhắn (mới → cũ) theo cursor `before`.
  Future<List<ChatMessage>> getHistory({int? before, int size = 20}) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}$_base/conversation/messages').replace(
      queryParameters: {
        if (before != null) 'before': before.toString(),
        'size': size.toString(),
      },
    );
    final headers = await ApiConfig.getHeaders();
    final res = await http.get(url, headers: headers).timeout(_timeout);
    // Khách chưa có hội thoại nào → BE trả 404 → coi như lịch sử rỗng.
    if (res.statusCode == 404) return [];
    final j = await _decode(res);
    final data = j['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gửi tin text, có thể kèm sản phẩm hoặc đơn hàng.
  Future<ChatMessage> sendText(
    String content, {
    int? productId,
    int? orderId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/messages');
    final headers = await ApiConfig.getHeaders();
    final res = await http
        .post(url,
            headers: headers,
            body: json.encode({
              'content': content,
              if (productId != null) 'productId': productId,
              if (orderId != null) 'orderId': orderId,
            }))
        .timeout(_timeout);
    final j = await _decode(res);
    return ChatMessage.fromJson(j['data'] as Map<String, dynamic>);
  }

  /// Đánh dấu khách đã đọc tới tin mới nhất.
  Future<void> markRead() async {
    final url = Uri.parse('${ApiConfig.baseUrl}$_base/conversation/read');
    final headers = await ApiConfig.getHeaders();
    final res = await http.patch(url, headers: headers).timeout(_timeout);
    await _decode(res);
  }
}
