import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_electroshops/core/utils/format_utils.dart';
import 'package:mobile_electroshops/models/chat_message.dart';
import 'package:mobile_electroshops/models/models.dart';

void main() {
  group('Formatting Utils Unit Tests', () {
    test('formatVND should format currency correctly', () {
      expect(formatVND(1000), '1.000 ₫');
      expect(formatVND(1250000), '1.250.000 ₫');
      expect(formatVND(0), '0 ₫');
    });

    test('formatVNDShort should format large currency correctly', () {
      expect(formatVNDShort(500), '500 ₫');
      expect(formatVNDShort(15000), '15k ₫');
      expect(formatVNDShort(1000000), '1tr ₫');
      expect(formatVNDShort(1500000), '1.5 tr ₫');
    });

    test('formatSold should format counts correctly', () {
      expect(formatSold(120), '120');
      expect(formatSold(1500), '1.5k');
      expect(formatSold(22000), '22.0k');
    });
  });

  group('Product Model Unit Tests', () {
    test('Product model should instantiate correctly', () {
      final product = Product(
        id: '1',
        name: 'Bàn phím cơ',
        brand: 'Logitech',
        category: 'Keyboards',
        price: 1500000,
        oldPrice: 1800000,
        rating: 4.8,
        reviews: 24,
        sold: 150,
        stock: 10,
        images: ['https://example.com/keyboard.png'],
        description: 'Bàn phím cơ đỉnh cao',
        specs: const {},
        freeShip: true,
        installment: true,
        badge: 'Mới',
      );

      expect(product.id, '1');
      expect(product.name, 'Bàn phím cơ');
      expect(product.brand, 'Logitech');
      expect(product.category, 'Keyboards');
      expect(product.price, 1500000);
      expect(product.oldPrice, 1800000);
      expect(product.rating, 4.8);
      expect(product.reviews, 24);
      expect(product.sold, 150);
      expect(product.stock, 10);
      expect(product.images.first, 'https://example.com/keyboard.png');
      expect(product.description, 'Bàn phím cơ đỉnh cao');
      expect(product.freeShip, isTrue);
      expect(product.installment, isTrue);
      expect(product.badge, 'Mới');
    });
  });

  group('Chat Message Model Unit Tests', () {
    test('ChatMessage parses live order fields from backend response', () {
      final message = ChatMessage.fromJson({
        'id': 1,
        'conversationId': 2,
        'senderRole': 'CUSTOMER',
        'content': '',
        'read': false,
        'createdAt': '2026-07-18T10:00:00',
        'orderId': 42,
        'orderStatus': 'DELIVERED',
        'orderTotal': 1250000,
        'orderDate': '2026-07-17T09:30:00',
      });

      expect(message.hasOrder, isTrue);
      expect(message.orderId, 42);
      expect(message.orderStatus, 'DELIVERED');
      expect(message.orderTotal, 1250000);
      expect(message.orderDate, DateTime(2026, 7, 17, 9, 30));
    });
  });
}
