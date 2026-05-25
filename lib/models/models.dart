import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  const Category({required this.id, required this.name, required this.icon});
}

class Brand {
  final String id;
  final String name;
  final Color color;
  const Brand({required this.id, required this.name, required this.color});
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
