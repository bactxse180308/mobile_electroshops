import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/chat_provider.dart';
import 'shipped_order_picker_sheet.dart';

const _quickReplies = [
  AppStrings.quickReplyStock,
  AppStrings.quickReplyShipping,
  AppStrings.quickReplyWarranty,
  AppStrings.quickReplyReturn,
];

/// Ô nhập + nút gửi (text only). Có validate rỗng, disable khi đang gửi, báo lỗi thân thiện.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send({String? preset, int? orderId}) async {
    final text = orderId == null ? (preset ?? _controller.text).trim() : '';
    if ((text.isEmpty && orderId == null) || _sending) return;
    setState(() => _sending = true);
    if (preset == null && orderId == null) _controller.clear();
    try {
      await context.read<ChatProvider>().sendMessage(
            text,
            orderId: orderId,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderId == null
                  ? AppStrings.chatSendError
                  : AppStrings.orderAttachmentSendError,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _selectShippedOrder() async {
    if (_sending) return;
    final orderId = await showShippedOrderPicker(context);
    if (!mounted || orderId == null) return;
    await _send(orderId: orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => GestureDetector(
                onTap: _sending ? null : () => _send(preset: _quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(_quickReplies[i],
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: AppStrings.attachShippedOrder,
                onPressed: _sending ? null : _selectShippedOrder,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
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
                    color: _sending
                        ? AppColors.mutedForeground
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
