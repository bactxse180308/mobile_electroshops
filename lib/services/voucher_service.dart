import '../models/api_models.dart';
import 'api_service.dart';

class VoucherService {
  final ApiService _api = ApiService();

  Future<ApiVoucherResponse> getByCode(String code) async {
    final res = await _api.authGet('/vouchers/code/$code');
    if (res['data'] != null) {
      return ApiVoucherResponse.fromJson(res['data']);
    }
    throw const ApiException(statusCode: 0, message: 'Mã giảm giá không tồn tại');
  }

  Future<bool> validateVoucher(String code, int userId) async {
    final res = await _api.authGet('/vouchers/validate', params: {
      'code': code,
      'userId': userId.toString(),
    });
    if (res['data'] != null) {
      return res['data'] as bool;
    }
    return false;
  }

  Future<ApiVoucherResponse> validateAndGetVoucher(String code, int userId, double orderTotal) async {
    final res = await _api.authGet('/vouchers/validate-details', params: {
      'code': code,
      'userId': userId.toString(),
      'orderTotal': orderTotal.toStringAsFixed(0), // BE probably expects integer or double as string
    });
    if (res['data'] != null) {
      return ApiVoucherResponse.fromJson(res['data']);
    }
    throw const ApiException(statusCode: 0, message: 'Mã giảm giá không hợp lệ hoặc không đủ điều kiện');
  }
}
