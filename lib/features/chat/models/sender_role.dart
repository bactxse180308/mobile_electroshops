/// Ai gửi tin nhắn: khách hàng hay nhân viên ElectroShop.
enum SenderRole { customer, staff }

SenderRole senderRoleFromApi(String value) =>
    value.toUpperCase() == 'STAFF' ? SenderRole.staff : SenderRole.customer;
