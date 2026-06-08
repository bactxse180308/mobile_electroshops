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
        return NotifModel(
          id: item['notificationId'].toString(),
          title: item['title'] ?? '',
          body: item['body'] ?? '',
          type: _parseType(item['type'] ?? 'system'),
          time: _formatDateTime(item['createdAt'] ?? ''),
          unread: !(item['isRead'] ?? false),
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
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return "Hôm nay, $hour:$minute";
      }
      return "$hour:$minute - $day/$month";
    } catch (_) {
      return dateTimeStr;
    }
  }
}
