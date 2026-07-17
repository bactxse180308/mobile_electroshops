import 'package:flutter/material.dart';
import '../models/models.dart';

String _img(String seed) => 'https://picsum.photos/seed/$seed/600/600';
List<String> _gallery(String seed) => [1, 2, 3, 4].map((i) => _img('$seed-$i')).toList();

const categories = <Category>[
  Category(id: 'ram', name: 'RAM', icon: Icons.memory),
  Category(id: 'ssd', name: 'SSD', icon: Icons.storage),
  Category(id: 'keyboard', name: 'Bàn phím', icon: Icons.keyboard_alt),
  Category(id: 'mouse', name: 'Chuột', icon: Icons.mouse),
  Category(id: 'headphone', name: 'Tai nghe', icon: Icons.headset),
  Category(id: 'speaker', name: 'Loa', icon: Icons.speaker),
  Category(id: 'gaming', name: 'Gaming Gear', icon: Icons.sports_esports),
];

const brands = <Brand>[
  Brand(id: 'kingston', name: 'Kingston', color: Color(0xFFC8102E)),
  Brand(id: 'samsung', name: 'Samsung', color: Color(0xFF1428A0)),
  Brand(id: 'logitech', name: 'Logitech', color: Color(0xFF00B8FC)),
  Brand(id: 'sony', name: 'Sony', color: Color(0xFF000000)),
  Brand(id: 'razer', name: 'Razer', color: Color(0xFF44D62C)),
  Brand(id: 'corsair', name: 'Corsair', color: Color(0xFFFACC15)),
  Brand(id: 'wd', name: 'WD', color: Color(0xFF0073E6)),
  Brand(id: 'msi', name: 'MSI', color: Color(0xFFFF0000)),
  Brand(id: 'jbl', name: 'JBL', color: Color(0xFFFF6600)),
];

final products = <Product>[
  Product(
    id: 'p1', name: 'RAM Kingston Fury Beast DDR5 16GB 5200MHz',
    brand: 'Kingston', category: 'ram', price: 1290000, oldPrice: 1690000,
    rating: 4.8, reviews: 1240, sold: 3450, stock: 25, images: _gallery('p1'),
    description: 'RAM hiệu năng cao DDR5 cho gaming và sáng tạo. Bộ nhớ Kingston Fury Beast mang đến tốc độ vượt trội với độ ổn định cao.',
    specs: {'Dung lượng': '16GB', 'Bus': '5200MHz', 'Loại': 'DDR5 DIMM', 'Bảo hành': 'Trọn đời'},
    badge: '-24%', freeShip: true, installment: true,
  ),
  Product(
    id: 'p2', name: 'SSD Samsung 980 Pro 1TB NVMe Gen4',
    brand: 'Samsung', category: 'ssd', price: 2490000, oldPrice: 3290000,
    rating: 4.9, reviews: 2310, sold: 5120, stock: 18, images: _gallery('p2'),
    description: 'SSD NVMe Gen4 hàng đầu Samsung 980 Pro với tốc độ đọc lên đến 7000 MB/s.',
    specs: {'Dung lượng': '1TB', 'Đọc': '7000 MB/s', 'Ghi': '5000 MB/s', 'Chuẩn': 'PCIe 4.0 x4 NVMe'},
    badge: 'Bán chạy', freeShip: true, installment: true,
  ),
  Product(
    id: 'p3', name: 'Bàn phím cơ Logitech G Pro X TKL Wireless',
    brand: 'Logitech', category: 'keyboard', price: 4990000, oldPrice: 5990000,
    rating: 4.7, reviews: 890, sold: 1820, stock: 12, images: _gallery('p3'),
    description: 'Bàn phím cơ không dây tenkeyless dành cho game thủ chuyên nghiệp, switch GX có thể hoán đổi.',
    specs: {'Switch': 'GX Clicky', 'Layout': 'TKL', 'Kết nối': 'Lightspeed 2.4GHz / Bluetooth', 'Pin': '50 giờ'},
    badge: '-17%', freeShip: true, installment: true,
  ),
  Product(
    id: 'p4', name: 'Tai nghe Sony WH-1000XM5 Wireless',
    brand: 'Sony', category: 'headphone', price: 7990000, oldPrice: 9490000,
    rating: 4.9, reviews: 3450, sold: 6200, stock: 30, images: _gallery('p4'),
    description: 'Tai nghe chống ồn hàng đầu Sony với chất âm tham chiếu và pin 30 giờ.',
    specs: {'Driver': '30mm', 'Pin': '30 giờ', 'Chống ồn': 'Dual Noise Sensor', 'Kết nối': 'Bluetooth 5.2'},
    freeShip: true, installment: true,
  ),
  Product(
    id: 'p5', name: 'Chuột gaming Logitech G Pro X Superlight 2',
    brand: 'Logitech', category: 'mouse', price: 3290000, oldPrice: 3990000,
    rating: 4.8, reviews: 1560, sold: 2890, stock: 22, images: _gallery('p5'),
    description: 'Chuột không dây siêu nhẹ 60g dành cho game thủ esports chuyên nghiệp.',
    specs: {'DPI': '32000', 'Trọng lượng': '60g', 'Pin': '95 giờ', 'Switch': 'Hybrid Optical-Mechanical'},
    badge: 'Mới', freeShip: true,
  ),
  Product(
    id: 'p6', name: 'Loa Bluetooth JBL Charge 5 Portable',
    brand: 'JBL', category: 'speaker', price: 3490000, oldPrice: 4290000,
    rating: 4.7, reviews: 980, sold: 1450, stock: 15, images: _gallery('p6'),
    description: 'Loa di động chống nước IP67, pin 20 giờ, âm bass mạnh mẽ.',
    specs: {'Công suất': '40W', 'Pin': '20 giờ', 'Chống nước': 'IP67', 'Kết nối': 'Bluetooth 5.1'},
    freeShip: true,
  ),
  Product(
    id: 'p7', name: 'RAM Corsair Vengeance RGB DDR5 32GB 6000MHz',
    brand: 'Corsair', category: 'ram', price: 3890000, oldPrice: 4590000,
    rating: 4.8, reviews: 670, sold: 1230, stock: 8, images: _gallery('p7'),
    description: 'Kit RAM RGB hiệu năng cao cho gaming PC cao cấp.',
    specs: {'Dung lượng': '32GB (2x16GB)', 'Bus': '6000MHz', 'Loại': 'DDR5 DIMM RGB', 'Bảo hành': 'Trọn đời'},
    freeShip: true, installment: true,
  ),
  Product(
    id: 'p8', name: 'SSD Western Digital Black SN850X 2TB',
    brand: 'Western Digital', category: 'ssd', price: 4990000, oldPrice: 5990000,
    rating: 4.8, reviews: 540, sold: 980, stock: 6, images: _gallery('p8'),
    description: 'SSD NVMe Gen4 cho game thủ với tốc độ đọc 7300 MB/s.',
    specs: {'Dung lượng': '2TB', 'Đọc': '7300 MB/s', 'Ghi': '6600 MB/s', 'Chuẩn': 'PCIe 4.0 NVMe'},
    freeShip: true, installment: true,
  ),
  Product(
    id: 'p9', name: 'Bàn phím cơ Razer Huntsman V3 Pro TKL',
    brand: 'Razer', category: 'keyboard', price: 5490000, oldPrice: 6490000,
    rating: 4.6, reviews: 420, sold: 760, stock: 14, images: _gallery('p9'),
    description: 'Bàn phím analog optical switch dành cho game thủ chuyên nghiệp.',
    specs: {'Switch': 'Analog Optical Gen-2', 'Layout': 'TKL', 'Polling': '8000Hz', 'Đèn': 'Chroma RGB'},
    freeShip: true, installment: true,
  ),
  Product(
    id: 'p10', name: 'Chuột Razer DeathAdder V3 Pro Wireless',
    brand: 'Razer', category: 'mouse', price: 3690000, oldPrice: 4290000,
    rating: 4.8, reviews: 1120, sold: 2340, stock: 19, images: _gallery('p10'),
    description: 'Chuột esports không dây 63g với cảm biến Focus Pro 30K.',
    specs: {'DPI': '30000', 'Trọng lượng': '63g', 'Pin': '90 giờ', 'Polling': '4000Hz'},
    freeShip: true,
  ),
  Product(
    id: 'p11', name: 'Tai nghe Razer BlackShark V2 Pro 2023',
    brand: 'Razer', category: 'headphone', price: 4290000, oldPrice: 4990000,
    rating: 4.7, reviews: 680, sold: 1180, stock: 0, images: _gallery('p11'),
    description: 'Tai nghe gaming không dây với driver TriForce Titanium 50mm.',
    specs: {'Driver': '50mm TriForce', 'Pin': '70 giờ', 'Mic': 'HyperClear Super-Wideband', 'Kết nối': '2.4GHz / Bluetooth'},
    freeShip: true,
  ),
  Product(
    id: 'p12', name: 'Loa MSI GV60 Bluetooth 5.0 RGB',
    brand: 'MSI', category: 'speaker', price: 1990000, oldPrice: 2490000,
    rating: 4.5, reviews: 320, sold: 580, stock: 11, images: _gallery('p12'),
    description: 'Loa Bluetooth RGB cho setup gaming với âm thanh stereo 2.0.',
    specs: {'Công suất': '20W', 'Đèn': 'RGB Mystic Light', 'Kết nối': 'Bluetooth 5.0', 'Pin': '12 giờ'},
    freeShip: true,
  ),
];

List<Product> get flashSale => products.sublist(0, 6);
List<Product> get bestSellers => [products[1], products[3], products[2], products[5]];
List<Product> get newArrivals => [products[4], products[8], products[9], products[7]];
List<Product> get recentlyViewed => [products[2], products[5], products[7], products[0]];

const stores = <Store>[
  Store(id: 's1', name: 'ElectroShop Quận 1', address: '123 Nguyễn Huệ, P. Bến Nghé, Q.1, TP.HCM', district: 'Quận 1', city: 'TP.HCM', distance: '1.2 km', hours: '08:30 - 22:00', phone: '0901234567', lat: 10.776, lng: 106.701),
  Store(id: 's2', name: 'ElectroShop Quận 10', address: '456 Cách Mạng Tháng 8, P.12, Q.10, TP.HCM', district: 'Quận 10', city: 'TP.HCM', distance: '3.8 km', hours: '08:30 - 22:00', phone: '0901234568', lat: 10.773, lng: 106.667),
  Store(id: 's3', name: 'ElectroShop Cầu Giấy', address: '78 Trần Thái Tông, Cầu Giấy, Hà Nội', district: 'Cầu Giấy', city: 'Hà Nội', distance: 'Hà Nội', hours: '09:00 - 21:30', phone: '0241234567', lat: 21.030, lng: 105.787),
  Store(id: 's4', name: 'ElectroShop Đống Đa', address: '215 Tây Sơn, Đống Đa, Hà Nội', district: 'Đống Đa', city: 'Hà Nội', distance: 'Hà Nội', hours: '09:00 - 21:30', phone: '0241234568', lat: 21.005, lng: 105.825),
];

List<NotifModel> get initialNotifications => [
  NotifModel(id: 'n1', type: NotifType.promo, title: 'Flash Sale 24h', body: 'Giảm đến 50% RAM & SSD - chỉ trong hôm nay!', time: '5 phút trước', unread: true),
  NotifModel(id: 'n2', type: NotifType.order, title: 'Đơn hàng #ES2025001', body: 'Đơn hàng của bạn đang được giao', time: '1 giờ trước', unread: true),
  NotifModel(id: 'n3', type: NotifType.product, title: 'Sản phẩm mới', body: 'Razer DeathAdder V3 Pro vừa về kho', time: '3 giờ trước', unread: false),
  NotifModel(id: 'n4', type: NotifType.system, title: 'Cập nhật ứng dụng', body: 'Phiên bản 2.4.0 đã sẵn sàng', time: 'Hôm qua', unread: false),
  NotifModel(id: 'n5', type: NotifType.order, title: 'Đơn hàng #ES2024998', body: 'Đã giao thành công - đánh giá ngay', time: '2 ngày trước', unread: false),
];

Product? findProduct(String id) {
  try {
    return products.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
