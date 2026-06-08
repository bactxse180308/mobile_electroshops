import 'package:flutter/material.dart';
import 'api_models.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  const Category({required this.id, required this.name, required this.icon});

  /// Tạo Category từ API response.
  factory Category.fromApi(ApiCategoryResponse r) {
    return Category(
      id: r.categoryId.toString(),
      name: r.categoryName,
      icon: _iconForCategory(r.categoryName),
    );
  }

  static IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('ram') || lower.contains('bộ nhớ')) return Icons.memory;
    if (lower.contains('ssd') || lower.contains('ổ cứng') || lower.contains('storage')) return Icons.storage;
    if (lower.contains('bàn phím') || lower.contains('keyboard')) return Icons.keyboard_alt;
    if (lower.contains('chuột') || lower.contains('mouse')) return Icons.mouse;
    if (lower.contains('tai nghe') || lower.contains('headphone') || lower.contains('headset')) return Icons.headset;
    if (lower.contains('loa') || lower.contains('speaker')) return Icons.speaker;
    if (lower.contains('gaming') || lower.contains('game')) return Icons.sports_esports;
    if (lower.contains('màn hình') || lower.contains('monitor')) return Icons.monitor;
    if (lower.contains('cpu') || lower.contains('processor')) return Icons.developer_board;
    if (lower.contains('gpu') || lower.contains('card')) return Icons.videogame_asset;
    if (lower.contains('nguồn') || lower.contains('power')) return Icons.power;
    if (lower.contains('case') || lower.contains('vỏ máy')) return Icons.computer;
    if (lower.contains('mạng') || lower.contains('network')) return Icons.wifi;
    return Icons.devices_other;
  }
}

class Brand {
  final String id;
  final String name;
  final Color color;
  const Brand({required this.id, required this.name, required this.color});

  /// Tạo Brand từ API response.
  /// Màu được gán theo tên thương hiệu nổi tiếng.
  factory Brand.fromApi(ApiBrandResponse r) {
    return Brand(
      id: r.brandId.toString(),
      name: r.brandName,
      color: _colorForBrand(r.brandName),
    );
  }

  static Color _colorForBrand(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('kingston')) return const Color(0xFFC8102E);
    if (lower.contains('samsung')) return const Color(0xFF1428A0);
    if (lower.contains('logitech')) return const Color(0xFF00B8FC);
    if (lower.contains('sony')) return const Color(0xFF1A1A1A);
    if (lower.contains('razer')) return const Color(0xFF44D62C);
    if (lower.contains('corsair')) return const Color(0xFFFACC15);
    if (lower.contains('wd') || lower.contains('western')) return const Color(0xFF0073E6);
    if (lower.contains('msi')) return const Color(0xFFDB0000);
    if (lower.contains('jbl')) return const Color(0xFFFF6600);
    if (lower.contains('asus')) return const Color(0xFF00539B);
    if (lower.contains('acer')) return const Color(0xFF83B81A);
    if (lower.contains('intel')) return const Color(0xFF0071C5);
    if (lower.contains('amd')) return const Color(0xFFED1C24);
    if (lower.contains('nvidia')) return const Color(0xFF76B900);
    if (lower.contains('seagate')) return const Color(0xFF009BDE);
    if (lower.contains('hyperx')) return const Color(0xFFE12227);
    if (lower.contains('steelseries')) return const Color(0xFFFF6600);
    if (lower.contains('aula')) return const Color(0xFF8B5CF6);
    if (lower.contains('sanDisk') || lower.contains('sandisk')) return const Color(0xFFFFBE00);
    // Màu mặc định dựa vào hash tên
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFFEC4899),
      const Color(0xFF14B8A6), const Color(0xFFF59E0B), const Color(0xFF10B981),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final int price;
  final int oldPrice;
  final double rating;
  final int reviews;
  final int sold;
  final int stock;
  final List<String> images;
  final String description;
  final Map<String, String> specs;
  final String? badge;
  final bool freeShip;
  final bool installment;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.reviews,
    required this.sold,
    required this.stock,
    required this.images,
    required this.description,
    required this.specs,
    this.badge,
    this.freeShip = false,
    this.installment = false,
  });

  /// Tạo Product từ API response.
  /// Giữ đúng interface Product để ProductCard hoạt động không cần thay đổi.
  factory Product.fromApi(ApiProductResponse r) {
    final priceInt = r.price.round();
    final oldPriceInt = r.originalPrice?.round() ?? priceInt;
    final hasDiscount = oldPriceInt > priceInt;
    final discountPct = r.discountPercent ?? 0;

    String? badge;
    if (discountPct >= 20) {
      badge = '-$discountPct%';
    } else if (r.soldCount != null && r.soldCount! > 3000) {
      badge = 'Bán chạy';
    }

    return Product(
      id: r.productId.toString(),
      name: r.productName,
      brand: r.brandName ?? '',
      category: r.categoryId?.toString() ?? '',
      price: priceInt,
      oldPrice: hasDiscount ? oldPriceInt : (priceInt * 1.2).round(),
      rating: r.rating ?? 4.5,
      reviews: r.soldCount ?? 0,
      sold: r.soldCount ?? 0,
      stock: r.quantity,
      images: r.allImages,
      description: r.descriptionDetails ?? 'Sản phẩm chính hãng ${r.brandName ?? ""} từ ElectroShop.',
      specs: {},
      badge: badge,
      freeShip: priceInt >= 500000,
      installment: priceInt >= 3000000,
    );
  }
}

class Store {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String hours;
  final String phone;
  final double lat;
  final double lng;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.hours,
    required this.phone,
    required this.lat,
    required this.lng,
  });
}

enum NotifType { promo, order, product, system }

class NotifModel {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  bool unread;

  NotifModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });
}

enum ChatFrom { me, staff, system }

class ChatMessage {
  final String id;
  final ChatFrom from;
  final String text;
  final String time;

  const ChatMessage({
    required this.id,
    required this.from,
    required this.text,
    required this.time,
  });
}

class CartItem {
  final String id;
  int qty;
  bool selected;

  CartItem({required this.id, required this.qty, required this.selected});
}
