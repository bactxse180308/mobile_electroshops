import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotifModel> _items = [];
  bool _isLoading = false;

  List<NotifModel> get items => _items;
  List<NotifModel> get unread => _items.where((n) => n.unread).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _notificationService.fetchNotifications();
      _items = list.map((item) {
        final title = item['title'] ?? '';
        final body = item['body'] ?? '';
        final type = _parseType(item['type'] ?? 'system');

        String? orderId;
        if (type == NotifType.order) {
          final match = RegExp(r'#(\d+)').firstMatch('$title $body');
          if (match != null) {
            orderId = match.group(1);
          }
        }

        return NotifModel(
          id: item['notificationId'].toString(),
          title: title,
          body: body,
          type: type,
          time: _formatDateTime(item['createdAt'] ?? ''),
          unread: !(item['isRead'] ?? false),
          orderId: orderId,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    final itemIndex = _items.indexWhere((n) => n.id == id);
    if (itemIndex == -1) return;

    // Optimistic UI update
    _items[itemIndex].unread = false;
    notifyListeners();

    try {
      await _notificationService.markAsRead(id);
    } catch (e) {
      if (kDebugMode) print('Error marking notification as read: $e');
      // Revert if error
      _items[itemIndex].unread = true;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    // Optimistic UI update
    for (final item in _items) {
      item.unread = false;
    }
    notifyListeners();

    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      if (kDebugMode) print('Error marking all notifications as read: $e');
      // Re-fetch to sync with backend if error
      await fetchNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    final itemIndex = _items.indexWhere((n) => n.id == id);
    if (itemIndex == -1) return;

    final deletedItem = _items[itemIndex];
    
    // Optimistic UI update
    _items.removeAt(itemIndex);
    notifyListeners();

    try {
      await _notificationService.deleteNotification(id);
    } catch (e) {
      if (kDebugMode) print('Error deleting notification: $e');
      // Revert if error
      _items.insert(itemIndex, deletedItem);
      notifyListeners();
    }
  }

  NotifType _parseType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'promo':
        return NotifType.promo;
      case 'order':
        return NotifType.order;
      case 'product':
        return NotifType.product;
      case 'system':
      default:
        return NotifType.system;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.isNegative || difference.inSeconds < 60) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays == 1 || 
                 (difference.inDays == 2 && dt.day == now.subtract(const Duration(days: 1)).day)) {
        return 'Hôm qua';
      } else {
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final year = dt.year;
        return '$day/$month/$year';
      }
    } catch (_) {
      return dateTimeStr;
    }
  }
}
