import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/chat_message.dart';

/// Thời gian gửi + trạng thái (đã gửi / đã đọc) — chỉ tin cuối của khách mới hiện trạng thái.
class MessageMeta extends StatelessWidget {
  final ChatMessage message;
  final bool showStatus;
  const MessageMeta({super.key, required this.message, this.showStatus = false});

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(message.createdAt);
    final label = showStatus
        ? '$time · ${message.read ? AppStrings.chatStatusRead : AppStrings.chatStatusSent}'
        : time;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
