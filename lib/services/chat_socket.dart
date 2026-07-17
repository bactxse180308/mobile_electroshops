import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/chat_message.dart';

/// Nhận tin realtime qua STOMP (subscribe `/user/queue/messages`).
/// Client KHÔNG gửi qua WS — chỉ subscribe để nhận; gửi tin đi qua REST.
class ChatSocket {
  final String wsUrl; // ApiConfig.wsUrl: ws://10.0.2.2:8080/ws-native
  final Future<String?> Function() tokenProvider;
  StompClient? _client;

  ChatSocket({required this.wsUrl, required this.tokenProvider});

  /// [destination] mặc định là hàng đợi của khách; admin truyền '/topic/support'.
  Future<void> connect(
    void Function(ChatMessage) onMessage, {
    String destination = '/user/queue/messages',
  }) async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) return;

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        // Authorization PHẢI ở STOMP CONNECT header (interceptor BE đọc native header).
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        onConnect: (StompFrame frame) {
          _client?.subscribe(
            destination: destination,
            callback: (StompFrame f) {
              if (f.body == null) return;
              onMessage(ChatMessage.fromJson(
                  jsonDecode(f.body!) as Map<String, dynamic>));
            },
          );
        },
        onStompError: (f) => debugPrint('[WS] STOMP error: ${f.headers['message']}'),
        onWebSocketError: (e) => debugPrint('[WS] error: $e'),
      ),
    );
    _client?.activate();
  }

  void disconnect() => _client?.deactivate();
}
