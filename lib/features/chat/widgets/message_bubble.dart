import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../product/screens/product_detail_screen.dart';
import '../../../models/chat_message.dart';
import 'message_meta.dart';
import 'order_attachment_card.dart';
import 'staff_avatar.dart';

/// Bong bóng tin nhắn.
/// [mine] = tin của phía đang xem (căn phải, xanh). Ngược lại căn trái + tên + avatar.
/// Dùng chung cho cả màn khách (mine = tin khách) lẫn màn admin (mine = tin nhân viên).
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  final bool showStatus; // chỉ true ở tin cuối của phía mình
  const MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    this.showStatus = false,
  });

  static const double _maxWidthFactor = 0.78;

  @override
  Widget build(BuildContext context) {
    return mine
        ? _MineBubble(message: message, showStatus: showStatus)
        : _OtherBubble(message: message);
  }
}

class _MineBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showStatus;
  const _MineBubble({required this.message, required this.showStatus});

  @override
  Widget build(BuildContext context) {
    final maxWidth =
        MediaQuery.of(context).size.width * MessageBubble._maxWidthFactor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.hasProduct) _ProductCard(message: message),
          if (message.hasOrder) OrderAttachmentCard(message: message),
          if (message.content.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(message.content,
                    style: const TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
          MessageMeta(message: message, showStatus: showStatus),
        ],
      ),
    );
  }
}

class _OtherBubble extends StatelessWidget {
  final ChatMessage message;
  const _OtherBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final maxWidth =
        MediaQuery.of(context).size.width * MessageBubble._maxWidthFactor;
    final hasName =
        message.senderName != null && message.senderName!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaffAvatar(
              name: message.senderName, avatarUrl: message.senderAvatarUrl),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasName)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 2),
                    child: Text(message.senderName!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary)),
                  ),
                if (message.hasProduct) _ProductCard(message: message),
                if (message.hasOrder) OrderAttachmentCard(message: message),
                if (message.content.isNotEmpty)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: AppShadows.card,
                      ),
                      child: Text(message.content,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.secondary)),
                    ),
                  ),
                MessageMeta(message: message, showStatus: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card sản phẩm đính kèm trong tin nhắn (ảnh + tên + giá). Bấm để mở chi tiết.
class _ProductCard extends StatelessWidget {
  final ChatMessage message;
  const _ProductCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final price = message.productPrice;
    final imageUrl = message.productImageUrl;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(productId: '${message.productId}'),
        ),
      ),
      child: Container(
        width: 230,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgFallback())
                    : _imgFallback(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.productName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary)),
                  const SizedBox(height: 4),
                  if (price != null)
                    Text(formatVND(price.round()),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: AppColors.muted,
        child: const Icon(Icons.image_outlined,
            color: AppColors.mutedForeground, size: 24),
      );
}
