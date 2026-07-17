import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/admin_chat_provider.dart';
import '../../../providers/chat_provider.dart' show ChatStatus;
import '../../../models/chat_message.dart';
import '../widgets/message_bubble.dart';

/// Màn admin trả lời 1 hội thoại của khách.
class AdminChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String customerName;
  const AdminChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.customerName,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _lastBottomMessageId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminChatProvider>().openConversation(widget.conversationId);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 60) {
      context.read<AdminChatProvider>().loadOlder();
    }
  }

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

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      await context.read<AdminChatProvider>().sendReply(text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.chatSendError)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    context.read<AdminChatProvider>().leaveConversation();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminChatProvider>();
    final messages = provider.messages;
    final lastOwnId = provider.lastStaffMessageId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customerName.isNotEmpty
              ? widget.customerName
              : AppStrings.adminCustomerFallback,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(provider, messages, lastOwnId)),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AdminChatProvider provider, List<ChatMessage> messages, int? lastOwnId) {
    switch (provider.activeStatus) {
      case ChatStatus.initial:
      case ChatStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ChatStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(provider.errorMessage ?? AppStrings.chatLoadError,
                textAlign: TextAlign.center),
          ),
        );
      case ChatStatus.empty:
        return const Center(child: Text('Chưa có tin nhắn'));
      case ChatStatus.success:
        _maybeAutoScroll(messages);
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return MessageBubble(
              message: message,
              mine: !message.isFromCustomer, // admin = nhân viên → tin staff bên phải
              showStatus: message.id == lastOwnId,
            );
          },
        );
    }
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: AppStrings.chatInputHint,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _sending ? AppColors.mutedForeground : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
