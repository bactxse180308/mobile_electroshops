import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/seed_data.dart';

class NotificationProvider extends ChangeNotifier {
  late List<NotifModel> _items;

  NotificationProvider() : _items = initialNotifications;

  List<NotifModel> get items => _items;
  List<NotifModel> get unread => _items.where((n) => n.unread).toList();

  void markRead(String id) {
    final item = _items.cast<NotifModel?>().firstWhere(
      (n) => n!.id == id,
      orElse: () => null,
    );
    if (item != null) {
      item.unread = false;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final item in _items) {
      item.unread = false;
    }
    notifyListeners();
  }
}
