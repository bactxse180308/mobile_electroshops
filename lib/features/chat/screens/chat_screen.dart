import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/models.dart';
import '../../../providers/chat_provider.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_list.dart';

/// Màn hình hỗ trợ / chat của KHÁCH.
/// Dùng [ChatProvider] toàn cục (đăng ký ở main) — vào màn thì đánh dấu đã đọc,
/// rời màn chỉ ngừng "đang xem" chứ KHÔNG ngắt socket (để vẫn đếm badge).
class ChatScreen extends StatefulWidget {
  /// Nếu mở từ trang sản phẩm → tự đính kèm card sản phẩm vào hội thoại.
  final Product? attachProduct;
  final int? attachOrderId;
  final String? initialMessage;
  const ChatScreen({
    super.key,
    this.attachProduct,
    this.attachOrderId,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatProvider? _chatProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ChatProvider>();
      _chatProvider = provider;
      await provider.enterChat();
      final p = widget.attachProduct;
      if (p != null && mounted) {
        final pid = int.tryParse(p.id);
        if (pid != null) await provider.sendMessage('', productId: pid);
      }
      final orderId = widget.attachOrderId;
      if (orderId != null && mounted) {
        try {
          await provider.sendMessage('', orderId: orderId);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.orderAttachmentSendError),
              ),
            );
          }
        }
      }
      final initialMessage = widget.initialMessage?.trim();
      if (initialMessage != null && initialMessage.isNotEmpty && mounted) {
        try {
          await provider.sendMessage(initialMessage);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.chatSendError)),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _chatProvider?.leaveChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ChatAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: MessageList()),
            ChatInputBar(),
          ],
        ),
      ),
    );
  }
}
