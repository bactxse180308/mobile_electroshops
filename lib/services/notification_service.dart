import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';

class NotificationService {
  Future<List<dynamic>> fetchNotifications() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications');
    final headers = await ApiConfig.getHeaders(requireAuth: true);
    
    final response = await http.get(url, headers: headers);
    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && responseData['status'] == 200) {
      return responseData['data'] ?? [];
    } else {
      throw Exception(responseData['message'] ?? 'Không thể tải thông báo.');
    }
  }

  Future<void> markAsRead(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/$id/read');
    final headers = await ApiConfig.getHeaders(requireAuth: true);
    final response = await http.patch(url, headers: headers);
    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    
    if (response.statusCode != 200 || responseData['status'] != 200) {
      throw Exception(responseData['message'] ?? 'Không thể đánh dấu đã đọc.');
    }
  }

  Future<void> markAllAsRead() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/read-all');
    final headers = await ApiConfig.getHeaders(requireAuth: true);
    final response = await http.patch(url, headers: headers);
    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200 || responseData['status'] != 200) {
      throw Exception(responseData['message'] ?? 'Không thể đánh dấu tất cả đã đọc.');
    }
  }

  Future<void> deleteNotification(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/notifications/$id');
    final headers = await ApiConfig.getHeaders(requireAuth: true);
    final response = await http.delete(url, headers: headers);
    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200 || responseData['status'] != 200) {
      throw Exception(responseData['message'] ?? 'Không thể xóa thông báo.');
    }
  }
}
