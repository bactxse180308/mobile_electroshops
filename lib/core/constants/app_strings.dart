class AppStrings {
  // Common
  static const String appName = 'ElectroShop';
  static const String error = 'Đã xảy ra lỗi';
  static const String errCannotLoadData = 'Không thể tải dữ liệu';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String retry = 'Thử lại';
  static const String continueText = 'Tiếp tục';
  static const String searchHint = 'Tìm RAM, SSD, bàn phím…';
  static const String searchProductHint = 'Tìm sản phẩm…';
  static const String loading = 'Đang tải…';
  static const String locationLabel = 'Giao đến: Q.1, TP.HCM';

  // Splash & Onboarding
  static const String splashTagline = 'Thế giới công nghệ trong tay bạn';
  static const String next = 'Tiếp theo';
  static const String start = 'Bắt đầu ngay';
  static const String onboarding1Title = 'Sản phẩm chính hãng';
  static const String onboarding1Sub = 'Cam kết sản phẩm công nghệ chất lượng cao, bảo hành dài hạn.';
  static const String onboarding2Title = 'Giao hàng cực nhanh';
  static const String onboarding2Sub = 'Dịch vụ giao hàng hỏa tốc trong 2 giờ tại nội thành.';
  static const String onboarding3Title = 'Hỗ trợ 24/7';
  static const String onboarding3Sub = 'Đội ngũ hỗ trợ chuyên nghiệp, tận tâm luôn sẵn sàng giúp đỡ bạn.';

  // Auth
  static const String loginTitle = 'Chào mừng trở lại';
  static const String loginSubtitle = 'Đăng nhập để tiếp tục mua sắm';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Mật khẩu';
  static const String confirmPasswordLabel = 'Xác nhận mật khẩu';
  static const String fullNameLabel = 'Họ và tên';
  static const String phoneLabel = 'Số điện thoại';
  static const String addressLabel = 'Địa chỉ';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String loginButton = 'Đăng nhập';
  static const String registerButton = 'Đăng ký';
  static const String orText = 'hoặc';
  static const String googleLogin = 'Tiếp tục với Google';
  static const String dontHaveAccount = 'Chưa có tài khoản? ';
  static const String alreadyHaveAccount = 'Đã có tài khoản? ';

  // Auth Validation & Errors
  static const String errEmptyFields = 'Vui lòng nhập đầy đủ thông tin.';
  static const String errInvalidEmail = 'Email không đúng định dạng.';
  static const String errPasswordLength = 'Mật khẩu phải từ 6 ký tự trở lên.';
  static const String errPasswordNotMatch = 'Mật khẩu xác nhận không khớp.';
  static const String errEmptyLogin = 'Vui lòng nhập đầy đủ email và mật khẩu.';
  static const String errUnverifiedAccount = 'Tài khoản chưa được kích hoạt. Đã gửi mã OTP xác thực tới email của bạn.';
  static const String errCannotSendOtp = 'Tài khoản chưa kích hoạt. Không thể gửi mã OTP: ';
  static const String errGoogleLoginFailed = 'Đăng nhập Google thất bại: ';

  // Google Login Simulation
  static const String simGoogleTitle = 'Mô phỏng Google Login';
  static const String simGoogleActualErr = 'Lỗi thực tế: ';
  static const String simGoogleInfo = 'Do cấu hình Google Sign-In yêu cầu thiết lập tệp cấu hình SHA-1 & Google Services trên Firebase. Bạn có thể sử dụng chế độ giả lập này để test nhanh API Google Login của Backend.';
  static const String simGoogleEmail = 'Email Google giả lập';
  static const String simGoogleName = 'Tên hiển thị Google';

  // OTP Verification
  static const String otpTitle = 'Xác thực OTP';
  static const String otpSubtitle = 'Mã xác thực đã được gửi đến';
  static const String otpEnterCode = 'Nhập mã OTP gồm 6 chữ số';
  static const String otpVerifyButton = 'Xác thực';
  static const String otpResendCode = 'Gửi lại mã';
  static const String otpResendIn = 'Gửi lại sau';
  static const String otpSuccess = 'Xác thực tài khoản thành công!';
  static const String otpFailed = 'Xác thực OTP thất bại: ';

  // Forgot Password
  static const String forgotTitle = 'Quên mật khẩu';
  static const String forgotSubtitle = 'Nhập email của bạn để nhận liên kết khôi phục';
  static const String forgotSendButton = 'Gửi yêu cầu';
  static const String forgotSuccess = 'Liên kết đặt lại mật khẩu đã được gửi đến email của bạn.';

  // Home Screen
  static const String sectionFlashSale = 'Khuyến mãi Hot';
  static const String sectionBestSellers = 'Bán chạy nhất';
  static const String sectionNewArrivals = 'Sản phẩm mới';
  static const String sectionRecentlyViewed = 'Đã xem gần đây';
  static const String viewAll = 'Xem tất cả';

  // Product Detail
  static const String productDetailTitle = 'Chi tiết sản phẩm';
  static const String errLoadProduct = 'Không thể tải sản phẩm';
  static const String errProductNotFound = 'Không tìm thấy sản phẩm';
  static const String filterEmptyMsg = 'Thử tìm với từ khoá khác hoặc bỏ bớt bộ lọc.';
  static const String stockIn = 'Còn hàng';
  static const String stockOut = 'Hết hàng';
  static const String soldCount = 'Đã bán';
  static const String freeShip = 'FREE SHIP';
  static const String installment0 = 'Trả góp 0%';
  static const String hotBadge = 'HOT';
  static const String ship2h = 'Giao 2h tại nội thành · Miễn phí từ 500.000 ₫';
  static const String warranty12m = 'Bảo hành chính hãng 12 tháng';
  static const String return7d = 'Đổi trả trong 7 ngày';
  static const String quantity = 'Số lượng';
  static const String tabDesc = 'Mô tả';
  static const String tabSpecs = 'Thông số';
  static const String tabReviews = 'Đánh giá';
  static const String specsPlaceholder = 'Thông số kỹ thuật chi tiết sẽ được cập nhật sớm.';
  static const String reviewsEmpty = 'Chưa có đánh giá nào cho sản phẩm này.';
  static const String relatedProducts = 'Sản phẩm liên quan';
  static const String chat = 'Chat';
  static const String addToCart = 'Vào giỏ';
  static const String buyNow = 'Mua ngay';
  static const String loginRequiredForCart = 'Vui lòng đăng nhập để thêm vào giỏ hàng';
  static const String addToCartSuccess = 'Đã thêm vào giỏ hàng ✓';
  static const String addToCartFailed = 'Không thể thêm vào giỏ: ';

  // Cart & Checkout
  static const String cartTitle = 'Giỏ hàng';
  static const String cartEmpty = 'Giỏ hàng trống';
  static const String selectAll = 'Chọn tất cả';
  static const String confirmClearCart = 'Xoá tất cả?';
  static const String confirmClearCartMsg = 'Bạn có chắc muốn xoá toàn bộ giỏ hàng?';
  static const String delete = 'Xoá';

  static const String checkoutTitle = 'Thanh toán';
  static const String selectItemsToCheckout = 'Chọn sản phẩm để thanh toán';
  static const String stepAddress = 'Địa chỉ';
  static const String stepPayment = 'Thanh toán';
  static const String stepConfirm = 'Xác nhận';
  static const String methodCod = 'Thanh toán khi nhận hàng';
  static const String methodCodSub = 'Kiểm tra hàng trước khi thanh toán';
  static const String methodBank = 'Chuyển khoản ngân hàng';
  static const String methodBankSub = 'Vietcombank · ACB · Techcombank';
  static const String methodVnpay = 'Ví VNPay';
  static const String methodVnpaySub = 'Quét QR thanh toán nhanh';
  static const String orderNotes = 'Ghi chú đơn hàng';
  static const String orderNotesHint = 'Lời nhắn cho shop (tuỳ chọn)';
  static const String subtotal = 'Tạm tính';
  static const String shipping = 'Vận chuyển';
  static const String free = 'Miễn phí';
  static const String totalPayable = 'Tổng cộng';
  static const String total = 'Tổng';
  static const String placeOrder = 'Đặt hàng';
  static const String freeShipNote = 'Đơn hàng ≥ 500.000đ được miễn ship';

  static const String orderDetailTitle = 'Chi tiết đơn hàng';
  static const String orderIdLabel = 'Mã đơn:';
  static const String orderTimeLabel = 'Đặt lúc:';
  static const String orderStatusLabel = 'Trạng thái:';
  static const String orderPaymentLabel = 'Thanh toán:';
  static const String deliveryInfoTitle = 'Thông tin giao nhận';
  static const String recipientLabel = 'Người nhận:';
  static const String orderPhoneLabel = 'Số điện thoại:';
  static const String orderAddressLabel = 'Địa chỉ:';
  static const String paymentMethodLabel = 'Phương thức:';
  static const String paymentMethod = 'Phương thức thanh toán';
  static const String productsTitle = 'Sản phẩm';
  static const String orderSummaryTitle = 'Tổng chi phí';
  static const String productsSubtotal = 'Tạm tính sản phẩm';
  static const String payableTotal = 'Tổng thanh toán';
  static const String orderTracking = 'Theo dõi đơn hàng';
  static const String discount = 'Giảm giá';
  static const String contact = 'Liên hệ';
  static const String askAboutThisOrder = 'Hỏi về đơn này';
  static const String cancelOrder = 'Huỷ đơn';
  static const String orderConfirmed = 'Đã xác nhận';
  static const String orderShipping = 'Đang giao';
  static const String orderDelivered = 'Đã giao';

  static const String orderSuccessTitle = 'Đặt hàng thành công!';
  static const String orderSuccessMsg = 'Cảm ơn bạn đã mua sắm tại ElectroShop. Đơn hàng của bạn đang được xử lý.';
  static const String viewOrderButton = 'Xem đơn hàng';
  static const String backHomeButton = 'Về trang chủ';
  static const String orderCode = 'Mã đơn hàng';
  static const String continueShopping = 'Tiếp tục mua sắm';

  // Product Filter & Categories
  static const String sortPopular = 'Phổ biến';
  static const String sortPriceAsc = 'Giá tăng dần';
  static const String sortPriceDesc = 'Giá giảm dần';
  static const String sortNewest = 'Mới nhất';
  static const String sortRatingDesc = 'Đánh giá cao';
  static const String filterTitle = 'Bộ lọc';
  static const String priceRange = 'Khoảng giá';
  static const String priceUnder1m = 'Dưới 1tr';
  static const String price1to3m = '1tr - 3tr';
  static const String price3to5m = '3tr - 5tr';
  static const String priceOver5m = 'Trên 5tr';
  static const String filterCategories = 'Danh mục';
  static const String filterBrands = 'Thương hiệu';
  static const String featuredBrands = 'Thương hiệu nổi bật';
  static const String minRating = 'Đánh giá tối thiểu';
  static const String all = 'Tất cả';
  static const String clearFilter = 'Xoá bộ lọc';
  static const String applyFilter = 'Áp dụng';
  static const String apply = 'Áp dụng';
  static const String enterCoupon = 'Nhập mã giảm giá';

  // Profile
  static const String guest = 'Khách';
  static const String notLoggedIn = 'Chưa đăng nhập';
  static const String goldMember = 'Thành viên Vàng';
  static const String orderCount = 'Đơn hàng';
  static const String favCount = 'Yêu thích';
  static const String myOrders = 'Đơn hàng của tôi';
  static const String pendingOrders = '3 đang xử lý';
  static const String shippingAddress = 'Địa chỉ giao hàng';
  static const String coupons = 'Mã giảm giá';
  static const String voucher = 'Voucher';
  static const String favoriteProducts = 'Sản phẩm yêu thích';
  static const String myReviews = 'Đánh giá của tôi';
  static const String nearbyStores = 'Cửa hàng gần bạn';
  static const String settings = 'Cài đặt';
  static const String helpCenter = 'Trung tâm trợ giúp';
  static const String logout = 'Đăng xuất';

  // Chat & Notifications & Stores & Profile
  static const String chatTitle = 'Hỗ trợ trực tuyến';
  static const String notificationsTitle = 'Thông báo';
  static const String readAll = 'Đánh dấu tất cả đã đọc';
  static const String tabAll = 'Tất cả';
  static const String tabUnread = 'Chưa đọc';
  static const String noNotifTitle = 'Bạn chưa có thông báo nào';
  static const String noNotifSub = 'Bạn sẽ nhận được thông báo về đơn hàng và khuyến mãi tại đây.';

  static const String storesTitle = 'Cửa hàng';
  static const String ourStores = 'Cửa hàng của chúng tôi';
  static const String storesCount = 'cửa hàng';
  static const String openStatus = 'Mở cửa';
  static const String callButton = 'Gọi';
  static const String directionsButton = 'Chỉ đường';

  static const String profileTitle = 'Tài khoản';

  // Onboarding
  static const String skipButton = 'Bỏ qua';
  static const String continueButton = 'Tiếp tục';
  static const String startShoppingButton = 'Bắt đầu mua sắm';

  // Extra strings from screens
  static const String errGoogleSimFailed = 'Mô phỏng Google thất bại: ';
  static const String errOtpDigits = 'Mã OTP phải gồm 6 chữ số.';
  static const String otpVerifySuccess = 'Xác thực tài khoản thành công! Bây giờ bạn có thể đăng nhập.';
  static const String otpResendSuccess = 'Đã gửi lại mã OTP mới. Vui lòng kiểm tra email.';
  static const String otpNotReceived = 'Không nhận được mã OTP?';
  static const String otpInstructionPrefix = 'Một mã OTP 6 số đã được gửi đến hòm thư ';
  static const String otpInstructionSuffix = '. Vui lòng nhập mã để kích hoạt tài khoản của bạn.';
  static const String errInvalidPhone = 'Số điện thoại phải từ 10 đến 15 chữ số.';
  static const String registerSuccessMsg = 'Đăng ký thành công! Vui lòng kiểm tra hòm thư để nhận mã OTP.';
  static const String registerPromoMsg = 'Tham gia ElectroShop để nhận ưu đãi thành viên';
  static const String agreePrefix = 'Tôi đồng ý với ';
  static const String termsOfService = 'Điều khoản dịch vụ';
  static const String agreeAnd = ' và ';
  static const String privacyPolicy = 'Chính sách bảo mật';
  static const String agreeSuffix = ' của ElectroShop';
  static const String createAccountTitle = 'Tạo tài khoản';
  static const String orderShippingStatus = 'Đang giao hàng';
  static const String estDelivery = 'Dự kiến 15/06';
  static const String supportAgentName = 'ElectroShop Support';
  static const String activeStatus = 'Đang hoạt động';
  static const String freeBadge = 'FREE';
  static const String chatInputHint = 'Nhập tin nhắn…';
  static const String quickReplyStock = 'Còn hàng không?';
  static const String quickReplyShipping = 'Phí ship?';
  static const String quickReplyWarranty = 'Bảo hành?';
  static const String quickReplyReturn = 'Đổi trả';
  static const String chatStatusSent = 'Đã gửi';
  static const String chatStatusRead = 'Đã đọc';
  static const String chatEmpty = 'Chào bạn 👋 Hãy gửi tin nhắn để được ElectroShop hỗ trợ.';
  static const String chatLoadError = 'Không thể tải tin nhắn. Vui lòng thử lại.';
  static const String chatSendError = 'Gửi tin nhắn thất bại. Vui lòng thử lại.';
  static const String attachShippedOrder = 'Đính kèm đơn đang giao';
  static const String shippedOrdersTitle = 'Chọn đơn đang giao';
  static const String noShippedOrders = 'Không có đơn đang giao';
  static const String noShippedOrdersSubtitle =
      'Chỉ đơn có trạng thái Đang giao mới có thể đính kèm.';
  static const String orderAttachmentLoadError = 'Không thể tải đơn đang giao.';
  static const String orderAttachmentSendError =
      'Không thể gửi đơn hàng. Vui lòng thử lại.';
  static const String orderStatusUpdating = 'Đang cập nhật';
  static const String orderTotalLabel = 'Tổng tiền';
  static const String orderPlacedDateLabel = 'Đặt ngày';
  static const String orderSupportMessagePrefix = 'Tôi cần hỗ trợ đơn #';
  static const String adminChatTitle = 'Tin nhắn khách hàng';
  static const String adminEmptyConversations = 'Chưa có hội thoại nào';
  static const String adminCustomerFallback = 'Khách hàng';
  static const String cartLoginPrompt = 'Đăng nhập để xem và quản lý giỏ hàng của bạn.';
  static const String cartEmptyPrompt = 'Khám phá sản phẩm và thêm vào giỏ của bạn.';
  static const String productUnit = 'sản phẩm';
  static const String searchInPrefix = 'Tìm trong ';
  static const String orderPrefix = 'Đơn #';
  static const String mockUserName = 'Nguyễn Minh Tuấn';
  static const String mockUserPhone = '0901 234 567';
  static const String mockUserAddress = '123 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM';
  static const String mockUserNamePhone = 'Nguyễn Minh Tuấn · 0901 234 567';
  static const String mockOrderCode = '#ES2025002847';
  static const String errInvalidProductId = 'ID sản phẩm không hợp lệ';
  static const String navHome = 'Trang chủ';
  static const String navCategory = 'Danh mục';
  static const String navMe = 'Tôi';
}
