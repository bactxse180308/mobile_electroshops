import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Đổi giữa emulator và máy thật bằng cách bật/tắt cờ này.
  // true  -> Android Emulator (host = 10.0.2.2)
  // false -> Máy Android thật trên cùng WiFi (host = IP LAN 192.168.1.11 của PC)
  static const bool useEmulator = false;
  // Truyền lúc chạy: flutter run --dart-define=API_HOST=192.168.x.x
  static const String _lanHost =
      String.fromEnvironment('API_HOST', defaultValue: '192.168.1.11');

  static String get _androidHost => useEmulator ? '10.0.2.2' : _lanHost;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      return Platform.isAndroid
          ? 'http://$_androidHost:8080'
          : 'http://localhost:8080';
    } catch (e) {
      return 'http://localhost:8080';
    }
  }

  /// URL WebSocket/STOMP (raw, KHÔNG SockJS) suy ra từ [baseUrl].
  static String get wsUrl =>
      '${baseUrl.replaceFirst('http', 'ws')}/ws-native';

  static Future<Map<String, String>> getHeaders({bool requireAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}
