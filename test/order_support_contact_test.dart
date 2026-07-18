import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_electroshops/core/constants/app_strings.dart';
import 'package:mobile_electroshops/features/order/screens/order_detail_screen.dart';
import 'package:mobile_electroshops/models/api_models.dart';
import 'package:mobile_electroshops/providers/auth_provider.dart';
import 'package:mobile_electroshops/providers/chat_provider.dart';
import 'package:mobile_electroshops/providers/order_provider.dart';
import 'package:mobile_electroshops/services/chat_api.dart';
import 'package:mobile_electroshops/services/chat_socket.dart';
import 'package:provider/provider.dart';

class _FakeAuthProvider extends AuthProvider {
  @override
  String? get accessToken => 'test-token';

  @override
  String? get role => 'CUSTOMER';
}

class _FakeOrderProvider extends OrderProvider {
  final OrderResponse order;

  _FakeOrderProvider(this.order);

  @override
  OrderResponse? get currentOrder => order;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<OrderResponse?> fetchOrderById(int id, String token) async => order;
}

class _RecordingChatProvider extends ChatProvider {
  _RecordingChatProvider()
      : super(
          api: ChatApi(),
          socket: ChatSocket(
            wsUrl: 'ws://unused',
            tokenProvider: () async => null,
          ),
        );

  String? sentText;
  int? sentOrderId;

  @override
  Future<void> enterChat() async {}

  @override
  void leaveChat() {}

  @override
  Future<void> sendMessage(
    String text, {
    int? productId,
    int? orderId,
  }) async {
    sentText = text;
    sentOrderId = orderId;
  }
}

void main() {
  testWidgets('Pending order sends the order attachment', (tester) async {
    final chatProvider = await _openSupportChat(
      tester,
      orderStatus: 'PENDING',
      buttonLabel: AppStrings.askAboutThisOrder,
    );

    expect(chatProvider.sentText, isEmpty);
    expect(chatProvider.sentOrderId, 42);
  });

  testWidgets('Ask about shipped order sends the order attachment',
      (tester) async {
    final chatProvider = await _openSupportChat(
      tester,
      orderStatus: 'SHIPPED',
      buttonLabel: AppStrings.askAboutThisOrder,
    );

    expect(chatProvider.sentText, isEmpty);
    expect(chatProvider.sentOrderId, 42);
  });
}

Future<_RecordingChatProvider> _openSupportChat(
  WidgetTester tester, {
  required String orderStatus,
  required String buttonLabel,
}) async {
  final order = OrderResponse(
    orderId: 42,
    userId: 7,
    orderStatus: orderStatus,
    paymentMethod: 'BANK',
    paymentStatus: 'PENDING',
    totalAmount: 8991000,
    discountAmount: 0,
    finalAmount: 8991000,
    orderItems: const [],
  );
  final chatProvider = _RecordingChatProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: _FakeAuthProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>.value(
          value: _FakeOrderProvider(order),
        ),
        ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
      ],
      child: const MaterialApp(
        home: OrderDetailScreen(orderId: '42'),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final contactButton = find.text(buttonLabel);
  await tester.ensureVisible(contactButton);
  await tester.pumpAndSettle();
  await tester.tap(contactButton);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));

  return chatProvider;
}
