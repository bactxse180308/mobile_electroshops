import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import 'home_screen.dart';
import '../../product/screens/categories_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // Filter state cho CategoriesScreen khi navigate từ Home
  int? _filterCategoryId;
  String? _filterCategoryName;
  int? _filterBrandId;
  String? _filterBrandQuery;
  // Key thay đổi mỗi khi filter thay đổi → buộc CategoriesScreen rebuild
  int _categoriesKey = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  void _onTabTap(int index) {
    if (index != 1) {
      // Khi người dùng tự nhấn tab Categories → xóa filter (hiển thị tất cả)
      setState(() {
        _currentIndex = index;
        _filterCategoryId = null;
        _filterCategoryName = null;
        _filterBrandId = null;
        _filterBrandQuery = null;
      });
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _navigateToCategories({
    int? categoryId,
    String? categoryName,
    int? brandId,
    String? brandQuery,
  }) {
    setState(() {
      _currentIndex = 1;
      _filterCategoryId = categoryId;
      _filterCategoryName = categoryName;
      _filterBrandId = brandId;
      _filterBrandQuery = brandQuery;
      _categoriesKey++; // Force rebuild với filter mới
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigate: (index) {
              // Được gọi bởi callback thông thường (onNavigate(1))
              // Xử lý ở _onTabTap
              _onTabTap(index);
            },
            onNavigateToCategories: _navigateToCategories,
          ),
          CategoriesScreen(
            key: ValueKey(_categoriesKey),
            initialCategoryId: _filterCategoryId,
            initialCategoryName: _filterCategoryName,
            initialBrandId: _filterBrandId,
            initialQuery: _filterBrandQuery,
          ),
          CartScreen(onNavigate: _onTabTap),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
