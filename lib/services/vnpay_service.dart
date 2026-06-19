import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class VNPayReturnParams {
  final String? responseCode;
  final String? transactionStatus;
  final String? txnRef;
  final String? amount;
  final Uri uri;
  final String fullUrl;

  const VNPayReturnParams({
    required this.uri,
    required this.fullUrl,
    this.responseCode,
    this.transactionStatus,
    this.txnRef,
    this.amount,
  });

  bool get isSuccess => responseCode == '00' && (transactionStatus == null || transactionStatus == '00');

  factory VNPayReturnParams.fromUri(Uri uri) {
    final query = uri.queryParameters;
    return VNPayReturnParams(
      uri: uri,
      fullUrl: uri.toString(),
      responseCode: query['vnp_ResponseCode'],
      transactionStatus: query['vnp_TransactionStatus'],
      txnRef: query['vnp_TxnRef'],
      amount: query['vnp_Amount'],
    );
  }
}

class VNPayService {
  static const Duration _timeout = Duration(seconds: 20);

  Future<String> createPaymentUrl(int orderId) async {
    final token = await _getToken();

    try {
      return await _postCreatePaymentUrl(
        '/payments/vnpay/create/$orderId',
        token: token,
      );
    } on ApiException catch (e) {
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      debugPrint('[VNPAY] Falling back to query-param create endpoint: $e');
    }

    return _postCreatePaymentUrl(
      '/payments/vnpay/create',
      token: token,
      queryParameters: {
        'orderId': orderId.toString(),
        'type': 'NORMAL',
      },
    );
  }

  VNPayReturnParams? parseReturnUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final isReturnPath = uri.path.contains('/payment/vnpay/return') ||
        uri.path.contains('/payments/vnpay/return');
    final hasVNPayResult = uri.queryParameters.containsKey('vnp_ResponseCode');
    if (!isReturnPath && !hasVNPayResult) return null;

    return VNPayReturnParams.fromUri(uri);
  }

  Future<void> confirmReturn(String fullReturnUrl, String token) async {
    final returnUri = Uri.tryParse(fullReturnUrl);
    if (returnUri == null) {
      throw const ApiException(statusCode: 0, message: 'Invalid VNPay return URL');
    }
    if (returnUri.query.isEmpty) {
      throw const ApiException(statusCode: 0, message: 'VNPay return URL has no query string');
    }

    final backendReturnUri = Uri.parse(
      '${ApiService.baseUrl}/payments/vnpay/return?${returnUri.query}',
    );

    print('[VNPAY] Calling backend return endpoint...');
    print('[VNPAY] Backend return URL: $backendReturnUri');

    try {
      final response = await http
          .get(
            backendReturnUri,
            headers: _headers(token),
          )
          .timeout(_timeout);

      final body = utf8.decode(response.bodyBytes);
      print('[VNPAY] Backend return response: ${response.statusCode} $body');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Backend VNPay return failed: ${response.reasonPhrase}',
        );
      }
    } on SocketException catch (e) {
      throw ApiException(statusCode: 0, message: 'Cannot call backend VNPay return endpoint: $e');
    } on TimeoutException {
      throw const ApiException(statusCode: 0, message: 'Backend VNPay return endpoint timed out');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String> _postCreatePaymentUrl(
    String path, {
    required String? token,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}$path').replace(
      queryParameters: queryParameters,
    );
    debugPrint('[VNPAY] POST $uri');

    try {
      final response = await http
          .post(
            uri,
            headers: _headers(token),
            body: jsonEncode(<String, dynamic>{}),
          )
          .timeout(_timeout);

      debugPrint('[VNPAY] ${response.statusCode} <- $uri');
      final body = utf8.decode(response.bodyBytes);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[VNPAY] Error body: $body');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final paymentUrl = data['paymentUrl'] as String?;
        if (paymentUrl != null && paymentUrl.isNotEmpty) return paymentUrl;
      }
      final paymentUrl = decoded['paymentUrl'] as String?;
      if (paymentUrl != null && paymentUrl.isNotEmpty) return paymentUrl;

      throw const ApiException(
        statusCode: 0,
        message: 'VNPay response does not contain paymentUrl',
      );
    } on SocketException catch (e) {
      throw ApiException(statusCode: 0, message: 'Cannot connect to backend: $e');
    } on TimeoutException {
      throw const ApiException(statusCode: 0, message: 'VNPay create payment request timed out');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
