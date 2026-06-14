import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/login');
    final headers = await ApiConfig.getHeaders(requireAuth: false);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && responseData['status'] == 200) {
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'Đăng nhập thất bại');
    }
  }

  Future<void> register(String fullName, String email, String phoneNumber, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/register');
    final headers = await ApiConfig.getHeaders(requireAuth: false);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 201 && responseData['status'] != 200) {
      throw Exception(responseData['message'] ?? 'Đăng ký thất bại');
    }
  }

  Future<void> sendOtp(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/otp/send');
    final headers = await ApiConfig.getHeaders(requireAuth: false);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'email': email}),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200 || responseData['status'] != 200) {
      throw Exception(responseData['message'] ?? 'Không thể gửi mã OTP');
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/otp/verify');
    final headers = await ApiConfig.getHeaders(requireAuth: false);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode != 200 || responseData['status'] != 200) {
      throw Exception(responseData['message'] ?? 'Mã OTP không chính xác hoặc đã hết hạn.');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/v1/auth/oauth2/google');
    final headers = await ApiConfig.getHeaders(requireAuth: false);
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'token': idToken}),
    );

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && responseData['status'] == 200) {
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'Đăng nhập Google thất bại');
    }
  }
}
