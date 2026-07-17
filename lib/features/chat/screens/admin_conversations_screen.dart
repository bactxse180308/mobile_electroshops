import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/admin_chat_provider.dart';
import '../../../providers/chat_provider.dart' show ChatStatus;
import '../../../models/conversation.dart';
import 'admin_chat_detail_screen.dart';

/// Inbox admin: danh sách hội thoại của khách, có badge tin chưa đọc.
class AdminConversationsScreen extends StatefulWidget {
  const AdminConversationsScreen({super.key});

  @override
  State<AdminConversationsScreen> createState() => _AdminConversationsScreenState();
}

class _AdminConversationsScreenState extends State<AdminConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminChatProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminChatTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminChatProvider>().loadConversations(),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(AdminChatProvider provider) {
    switch (provider.listStatus) {
      case ChatStatus.initial:
      case ChatStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ChatStatus.error:
        return _centered(provider.errorMessage ?? AppStrings.chatLoadError);
      case ChatStatus.empty:
        return _centered(AppStrings.adminEmptyConversations);
      case ChatStatus.success:
        final items = provider.conversations;
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, i) => _ConversationTile(conversation: items[i]),
        );
    }
  }

  // ListView cần cuộn được để RefreshIndicator hoạt động khi rỗng.
  Widget _centered(String text) => ListView(
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(text, textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      );
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final name = (conversation.customerName != null && conversation.customerName!.isNotEmpty)
        ? conversation.customerName!
        : AppStrings.adminCustomerFallback;
    final initial = name[0].toUpperCase();
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(initial,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      title: Text(name,
          style: TextStyle(
              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.secondary)),
      subtitle: Text(
        'Hội thoại #${conversation.id}',
        style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_formatTime(conversation.lastMessageAt),
              style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.destructive,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminChatDetailScreen(
            conversationId: conversation.id,
            customerName: name,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final sameDay = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}
