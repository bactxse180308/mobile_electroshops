/// Tóm tắt một hội thoại hỗ trợ.
/// Dùng cho cả phía khách (chỉ cần unreadCount) lẫn phía admin (danh sách hội thoại).
class Conversation {
  final int id;
  final String status;
  final int unreadCount;
  final String? customerName; // tên khách — hiển thị ở inbox admin
  final DateTime? lastMessageAt;

  const Conversation({
    required this.id,
    required this.status,
    required this.unreadCount,
    this.customerName,
    this.lastMessageAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as int,
        status: json['status'] as String,
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        customerName: json['customerName'] as String?,
        lastMessageAt: json['lastMessageAt'] != null
            ? DateTime.tryParse(json['lastMessageAt'] as String)
            : null,
      );

  Conversation copyWith({int? unreadCount, DateTime? lastMessageAt}) => Conversation(
        id: id,
        status: status,
        unreadCount: unreadCount ?? this.unreadCount,
        customerName: customerName,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );
}
