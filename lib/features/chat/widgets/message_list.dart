import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/chat_provider.dart';
import '../models/chat_message.dart';
import 'message_bubble.dart';

/// Khung chat: lịch sử tin nhắn + cuộn lên tải tin cũ + loading/empty/error.
class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();
  int? _lastBottomMessageId; // id tin đáy lần build trước → phát hiện tin mới để auto-scroll

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Cuộn gần đỉnh → tải tin cũ hơn.
    if (_scrollController.position.pixels <= 60) {
      context.read<ChatProvider>().loadOlder();
    }
  }

  // Tự cuộn xuống đáy khi có tin mới ở đáy (mở màn / gửi / nhận realtime).
  // Tải tin cũ chỉ chèn ở đầu → tin đáy không đổi → KHÔNG cuộn (tránh giật ngược).
  void _maybeAutoScroll(List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    final bottomId = messages.last.id;
    if (bottomId == _lastBottomMessageId) return;
    _lastBottomMessageId = bottomId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    switch (provider.status) {
      case ChatStatus.initial:
      case ChatStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ChatStatus.error:
        return _CenterText(text: provider.errorMessage ?? AppStrings.chatLoadError);
      case ChatStatus.empty:
        return const _CenterText(text: AppStrings.chatEmpty);
      case ChatStatus.success:
        final messages = provider.messages;
        final lastOwnId = provider.lastCustomerMessageId;
        _maybeAutoScroll(messages);
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return MessageBubble(
              message: message,
              mine: message.isFromCustomer,
              showStatus: message.id == lastOwnId,
            );
          },
        );
    }
  }
}

class _CenterText extends StatelessWidget {
  final String text;
  const _CenterText({required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ),
      );
}
