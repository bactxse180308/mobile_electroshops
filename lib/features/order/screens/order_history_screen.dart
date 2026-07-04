import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/top_app_bar.dart';
import '../../../models/api_models.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';
import '../widgets/order_history_card.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadOrders(refresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.accessToken;
    final userId = authProvider.userId;

    if (token == null ||
        userId == null ||
        !orderProvider.hasMore ||
        orderProvider.isLoadingMore ||
        orderProvider.isLoading) {
      return;
    }

    orderProvider.fetchMyOrders(token, userId);
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.accessToken;
    final userId = authProvider.userId;

    if (token == null || userId == null) {
      return;
    }

    await context
        .read<OrderProvider>()
        .fetchMyOrders(token, userId, refresh: refresh);
  }

  void _openOrderDetail(OrderResponse order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order.orderId.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: const ElectroAppBar(title: AppStrings.myOrders),
      body: RefreshIndicator(
        onRefresh: () => _loadOrders(refresh: true),
        child: _buildBody(orderProvider),
      ),
    );
  }

  Widget _buildBody(OrderProvider orderProvider) {
    final orders = orderProvider.orders;

    if (orderProvider.isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const _OrderHistoryEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.p12),
      itemCount: orders.length + (orderProvider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.p12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final order = orders[index];
        return OrderHistoryCard(
          order: order,
          onTap: () => _openOrderDetail(order),
        );
      },
    );
  }
}

class _OrderHistoryEmptyState extends StatelessWidget {
  const _OrderHistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: AppColors.muted,
              ),
              SizedBox(height: AppSizes.p16),
              Text(
                'Không có đơn hàng nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(height: AppSizes.p8),
              Text(
                'Hãy mua sắm sản phẩm công nghệ ngay!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
