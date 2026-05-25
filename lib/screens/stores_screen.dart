import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/seed_data.dart';
import '../widgets/app_button.dart';
import '../widgets/top_app_bar.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  String _selectedId = stores[0].id;

  @override
  Widget build(BuildContext context) {
    stores.firstWhere((s) => s.id == _selectedId);

    return Scaffold(
      appBar: ElectroAppBar(
        title: 'Cửa hàng của chúng tôi',
        right: IconButton(
          icon: const Icon(Icons.search, size: 22, color: AppColors.secondary),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: [
          // Map visualization
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Stylized map background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE0F2FE), Color(0xFFF0FDF4), Color(0xFFFEF3C7)],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _MapPainter(),
                    child: Container(),
                  ),
                ),
                // Store pins
                ...stores.asMap().entries.map((e) {
                  final i = e.key;
                  final s = e.value;
                  final active = s.id == _selectedId;
                  final positions = [
                    const Offset(0.25, 0.25),
                    const Offset(0.65, 0.45),
                    const Offset(0.40, 0.65),
                    const Offset(0.75, 0.75),
                  ];
                  final pos = positions[i];
                  return Positioned(
                    left: pos.dx * MediaQuery.of(context).size.width - 18,
                    top: pos.dy * (MediaQuery.of(context).size.height * 0.38) - 36,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedId = s.id),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: active ? (Matrix4.identity()..scale(1.25, 1.25)) : Matrix4.identity(),
                            transformAlignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (active)
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active ? AppColors.primary : AppColors.card,
                                    boxShadow: AppShadows.lift,
                                  ),
                                  child: Icon(
                                    active ? Icons.location_on : Icons.location_on_outlined,
                                    size: 20,
                                    color: active ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 0, height: 0,
                            decoration: BoxDecoration(
                              border: Border(
                                left: const BorderSide(width: 6, color: Colors.transparent),
                                right: const BorderSide(width: 6, color: Colors.transparent),
                                top: BorderSide(width: 8, color: active ? AppColors.primary : AppColors.card),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom sheet
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x20000000), blurRadius: 20, offset: Offset(0, -4))],
              ),
              child: Column(
                children: [
                  Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text('${stores.length} cửa hàng', style: AppTextStyles.h3),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stores.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final s = stores[i];
                        final active = s.id == _selectedId;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedId = s.id),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: active ? AppColors.primary : AppColors.border, width: active ? 1.5 : 1),
                              color: active ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary))),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                                child: const Text('Mở cửa', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(s.address, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, size: 12, color: AppColors.mutedForeground),
                                              const SizedBox(width: 4),
                                              Text(s.hours, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                              const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
                                              Text(s.distance, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (active) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          variant: AppButtonVariant.secondary,
                                          size: AppButtonSize.sm,
                                          fullWidth: true,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [Icon(Icons.phone_outlined, size: 14), SizedBox(width: 4), Text('Gọi')],
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppButton(
                                          size: AppButtonSize.sm,
                                          fullWidth: true,
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [Icon(Icons.near_me_outlined, size: 14), SizedBox(width: 4), Text('Chỉ đường')],
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.5);
    path1.quadraticBezierTo(size.width * 0.5, size.height * 0.35, size.width, size.height * 0.35);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.25, 0);
    path2.quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.35, size.height);
    canvas.drawPath(path2, roadPaint..color = const Color(0xFF10B981).withOpacity(0.25)..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_) => false;
}
