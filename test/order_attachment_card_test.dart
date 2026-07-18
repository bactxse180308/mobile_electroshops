import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_electroshops/core/constants/app_strings.dart';
import 'package:mobile_electroshops/core/utils/format_utils.dart';
import 'package:mobile_electroshops/features/chat/widgets/order_attachment_card.dart';
import 'package:mobile_electroshops/models/chat_message.dart';
import 'package:mobile_electroshops/models/sender_role.dart';

void main() {
  testWidgets('Order attachment card renders live order fields',
      (tester) async {
    final message = ChatMessage(
      id: 1,
      conversationId: 2,
      senderRole: SenderRole.customer,
      content: '',
      read: false,
      createdAt: DateTime(2026, 7, 18, 10),
      orderId: 42,
      orderStatus: 'SHIPPED',
      orderTotal: 1250000,
      orderDate: DateTime(2026, 7, 17, 9, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderAttachmentCard(message: message),
        ),
      ),
    );

    expect(find.text('${AppStrings.orderPrefix}42'), findsOneWidget);
    expect(find.text('Đang giao hàng'), findsOneWidget);
    expect(find.text(formatVND(1250000)), findsOneWidget);
    expect(find.text('17/07/2026'), findsOneWidget);
  });
}
