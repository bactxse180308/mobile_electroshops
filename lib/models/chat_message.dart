import 'sender_role.dart';

/// 1 tin nhắn text trong hội thoại hỗ trợ.
/// Dùng chung cho cả REST response lẫn payload WebSocket (cùng schema BE).
class ChatMessage {
  final int id;
  final int conversationId;
  final SenderRole senderRole;
  final String? senderName; // tên nhân viên (hiển thị bên trái)
  final String? senderAvatarUrl; // avatar nhân viên
  final String content;
  final bool read; // phía đối diện đã đọc tin này chưa
  final DateTime createdAt;

  // Sản phẩm đính kèm (snapshot) — null nếu tin không đính kèm sản phẩm.
  final int? productId;
  final String? productName;
  final String? productImageUrl;
  final num? productPrice;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderRole,
    required this.content,
    required this.read,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
    this.productId,
    this.productName,
    this.productImageUrl,
    this.productPrice,
  });

  bool get isFromCustomer => senderRole == SenderRole.customer;

  bool get hasProduct => productId != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int,
        conversationId: json['conversationId'] as int,
        senderRole: senderRoleFromApi(json['senderRole'] as String),
        senderName: json['senderName'] as String?,
        senderAvatarUrl: json['senderAvatarUrl'] as String?,
        content: (json['content'] as String?) ?? '',
        read: (json['read'] as bool?) ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        productId: json['productId'] as int?,
        productName: json['productName'] as String?,
        productImageUrl: json['productImageUrl'] as String?,
        productPrice: json['productPrice'] as num?,
      );

  ChatMessage copyWith({bool? read}) => ChatMessage(
        id: id,
        conversationId: conversationId,
        senderRole: senderRole,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
        content: content,
        read: read ?? this.read,
        createdAt: createdAt,
        productId: productId,
        productName: productName,
        productImageUrl: productImageUrl,
        productPrice: productPrice,
      );
}
