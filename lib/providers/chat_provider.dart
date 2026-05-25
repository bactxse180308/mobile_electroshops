import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/seed_data.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = List.from(chatSeed);
  bool _typing = false;

  List<ChatMessage> get messages => _messages;
  bool get typing => _typing;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final id = now.millisecondsSinceEpoch.toString();

    _messages.add(ChatMessage(id: id, from: ChatFrom.me, text: text, time: timeStr));
    _typing = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 1400), () {
      _typing = false;
      _messages.add(ChatMessage(
        id: '${id}r',
        from: ChatFrom.staff,
        text: 'Dạ shop sẽ kiểm tra và phản hồi ngay ạ!',
        time: timeStr,
      ));
      notifyListeners();
    });
  }
}
