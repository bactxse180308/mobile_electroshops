import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/seed_data.dart';
import '../models/models.dart';
import '../providers/cart_provider.dart';
import '../utils/format_utils.dart';
import '../widgets/product_card.dart';
import '../widgets/app_button.dart';
import 'chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imgIndex = 0;
  int _qty = 1;
  String _tab = 'specs';

  @override
  Widget build(BuildContext context) {
    final p = findProduct(widget.productId);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sản phẩm')),
        body: const Center(child: Text('Không tìm thấy sản phẩm', style: TextStyle(color: AppColors.mutedForeground))),
      );
    }
    final discount = ((p.oldPrice - p.price) / p.oldPrice * 100).round();
    final related = products.where((x) => x.category == p.category && x.id != p.id).take(6).toList();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Image gallery
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          p.images[_imgIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.muted),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 12,
                        child: _CircleBtn(icon: Icons.chevron_left, onTap: () => Navigator.pop(context)),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 12,
                        child: Row(
                          children: [
                            _CircleBtn(icon: Icons.favorite_border, onTap: () {}),
                            const SizedBox(width: 8),
                            _CircleBtn(icon: Icons.share_outlined, onTap: () {}),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(p.images.length, (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _imgIndex ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _imgIndex ? AppColors.primary : Colors.white70,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                  // Thumbnail strip
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: p.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => setState(() => _imgIndex = i),
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: i == _imgIndex ? AppColors.primary : Colors.transparent, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(p.images[i], fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Price + name card
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(formatVND(p.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                            if (discount > 0) ...[
                              const SizedBox(width: 8),
                              Text(formatVND(p.oldPrice), style: AppTextStyles.priceOld.copyWith(fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                                child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(p.name, style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(p.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                            Text(' (${p.reviews})', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
                            Text('Đã bán ${p.sold.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
                            Text(p.stock > 0 ? 'Còn hàng' : 'Hết hàng', style: TextStyle(fontSize: 12, color: p.stock > 0 ? AppColors.success : AppColors.destructive, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Shipping info
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        _InfoRow(icon: Icons.local_shipping_outlined, text: 'Giao 2h tại nội thành · Miễn phí từ 500.000 ₫'),
                        const Divider(height: 12, color: AppColors.border),
                        _InfoRow(icon: Icons.verified_user_outlined, text: 'Bảo hành chính hãng ${p.specs['Bảo hành'] ?? '12 tháng'}'),
                        const Divider(height: 12, color: AppColors.border),
                        const _InfoRow(icon: Icons.replay_outlined, text: 'Đổi trả trong 7 ngày'),
                      ],
                    ),
                  ),

                  // Quantity
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        const Text('Số lượng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                        const Spacer(),
                        _QtyBtn(icon: Icons.remove, onTap: _qty > 1 ? () => setState(() => _qty--) : null),
                        const SizedBox(width: 12),
                        SizedBox(width: 32, child: Text('$_qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.secondary))),
                        const SizedBox(width: 12),
                        _QtyBtn(icon: Icons.add, onTap: () => setState(() => _qty++)),
                      ],
                    ),
                  ),

                  // Tabs
                  _Card(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _TabBtn(label: 'Thông số', active: _tab == 'specs', onTap: () => setState(() => _tab = 'specs')),
                            _TabBtn(label: 'Mô tả', active: _tab == 'desc', onTap: () => setState(() => _tab = 'desc')),
                            _TabBtn(label: 'Đánh giá (${p.reviews})', active: _tab == 'rev', onTap: () => setState(() => _tab = 'rev')),
                          ],
                        ),

                        const Divider(height: 1, color: AppColors.border),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _TabContent(tab: _tab, product: p),
                        ),
                      ],
                    ),
                  ),

                  // Related products
                  if (related.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Align(alignment: Alignment.centerLeft, child: Text('Sản phẩm liên quan', style: AppTextStyles.h3)),
                    ),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: related.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => ProductCard(
                          product: related[i],
                          variant: ProductCardVariant.horizontal,
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(productId: related[i].id),
                          )),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primary),
                        Text('Chat', style: TextStyle(fontSize: 9, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Vào giỏ',
                    variant: AppButtonVariant.secondary,
                    disabled: p.stock == 0,
                    onPressed: () {
                      context.read<CartProvider>().add(p.id, qty: _qty);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: AppColors.success, duration: Duration(seconds: 2)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Mua ngay',
                    variant: AppButtonVariant.gradient,
                    disabled: p.stock == 0,
                    onPressed: () {
                      context.read<CartProvider>().add(p.id, qty: _qty);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  const _Card({required this.child, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 20, color: AppColors.secondary),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.secondary))),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? AppColors.muted : Colors.transparent,
        ),
        child: Icon(icon, size: 16, color: onTap == null ? AppColors.mutedForeground : AppColors.secondary),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? AppColors.primary : Colors.transparent, width: 2)),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? AppColors.primary : AppColors.mutedForeground))),
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final String tab;
  final Product product;
  const _TabContent({required this.tab, required this.product});

  @override
  Widget build(BuildContext context) {
    if (tab == 'specs') {
      return Column(
        children: product.specs.entries.map((e) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(
            children: [
              SizedBox(width: 110, child: Text(e.key, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground))),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary))),
            ],
          ),
        )).toList(),
      );
    }
    if (tab == 'desc') {
      return Text(product.description, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.6));
    }
    // Reviews tab
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < product.rating.round() ? AppColors.accent : AppColors.border))),
                const SizedBox(height: 4),
                Text('${product.reviews} đánh giá', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$s', style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: s == 5 ? 0.7 : s == 4 ? 0.2 : s == 3 ? 0.07 : 0.02,
                            backgroundColor: AppColors.muted,
                            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...[
          ('Minh Tuấn', 'Hàng chính hãng, đóng gói cẩn thận. Chạy mượt hơn hẳn RAM cũ.', 5),
          ('Quang Anh', 'Shop tư vấn nhiệt tình, giao nhanh trong ngày.', 5),
          ('Phương Linh', 'Sản phẩm tốt, giá hợp lý. Sẽ ủng hộ shop tiếp.', 4),
        ].map((r) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: AppColors.border),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(r.$1[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                      Row(children: List.generate(5, (i) => Icon(Icons.star, size: 11, color: i < r.$3 ? AppColors.accent : AppColors.border))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(r.$2, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
            ],
          ),
        )),
      ],
    );
  }
}
