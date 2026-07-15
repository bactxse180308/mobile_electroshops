import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/api_config.dart';

/// Service trung tâm để giao tiếp với Spring Boot backend.
class ApiService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api/v1';

  static const Duration _timeout = Duration(seconds: 15);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Token helper ─────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Refresh token mechanism to handle access token expiration (401 Unauthorized)
  bool _isRefreshing = false;
  Future<String?>? _refreshTokenFuture;

  Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) {
      debugPrint('[API] Waiting for existing token refresh operation...');
      return _refreshTokenFuture;
    }

    _isRefreshing = true;
    final completer = Completer<String?>();
    _refreshTokenFuture = completer.future;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) {
        debugPrint('[API] Refresh token not found in storage.');
        completer.complete(null);
        return null;
      }

      final uri = Uri.parse('$baseUrl/auth/refresh');
      debugPrint('[API] Refreshing access token...');
      final response = await http.post(
        uri,
        headers: _baseHeaders(),
        body: json.encode({'refreshToken': refreshToken}),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = json.decode(body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String?;

        await prefs.setString('access_token', newAccessToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', newRefreshToken);
        }
        
        debugPrint('[API] Access token refreshed successfully.');
        completer.complete(newAccessToken);
      } else {
        debugPrint('[API] Failed to refresh token: ${response.statusCode}');
        // Clear expired tokens so the user is forced to log in again
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        completer.complete(null);
      }
    } catch (e) {
      debugPrint('[API] Error during token refresh: $e');
      completer.complete(null);
    } finally {
      _isRefreshing = false;
      _refreshTokenFuture = null;
    }

    return completer.future;
  }

  Map<String, String> _baseHeaders({String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── HTTP Helpers ──────────────────────────────────────────────────────────
  
  Future<Map<String, dynamic>> get(String path, {Map<String, String?>? params}) async {
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final String url = path.startsWith('http')
        ? path
        : (path.startsWith('/api/v1/') || !path.startsWith('/api/')
            ? '$baseUrl$path'
            : '${ApiConfig.baseUrl}$path');
    final uri = Uri.parse(url).replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] GET $uri');
    return _send(http.get(uri, headers: _baseHeaders()), path);
  }

  Future<Map<String, dynamic>> authGet(String path, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] GET(auth) $uri');
    try {
      return await _send(http.get(uri, headers: _baseHeaders(token: token)), path);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying GET(auth) $uri with new token');
          return await _send(http.get(uri, headers: _baseHeaders(token: newToken)), path);
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> authPost(String path, Map<String, dynamic> body, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] POST(auth) $uri');
    try {
      return await _send(
        http.post(uri, headers: _baseHeaders(token: token), body: json.encode(body)),
        path,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying POST(auth) $uri with new token');
          return await _send(
            http.post(uri, headers: _baseHeaders(token: newToken), body: json.encode(body)),
            path,
          );
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> authPatch(String path, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] PATCH(auth) $uri');
    try {
      return await _send(http.patch(uri, headers: _baseHeaders(token: token)), path);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying PATCH(auth) $uri with new token');
          return await _send(http.patch(uri, headers: _baseHeaders(token: newToken)), path);
        }
      }
      rethrow;
    }
  }

  Future<void> authDelete(String path, {Map<String, String?>? params}) async {
    final token = await _getToken();
    final cleanParams = <String, String>{};
    params?.forEach((k, v) { if (v != null) cleanParams[k] = v; });
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: cleanParams.isEmpty ? null : cleanParams,
    );
    debugPrint('[API] DELETE(auth) $uri');

    Future<void> sendRequest(String? currentToken) async {
      try {
        final response = await http
            .delete(uri, headers: _baseHeaders(token: currentToken))
            .timeout(_timeout);
        debugPrint('[API] ${response.statusCode} ← $path');
        if (response.statusCode >= 200 && response.statusCode < 300) return;
        final body = utf8.decode(response.bodyBytes);
        debugPrint('[API] Error body: $body');
        throw ApiException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode}',
        );
      } on SocketException catch (e) {
        throw ApiException(statusCode: 0, message: 'Không thể kết nối server: $e');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException(statusCode: 0, message: e.toString());
      }
    }

    try {
      await sendRequest(token);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final newToken = await _refreshAccessToken();
        if (newToken != null) {
          debugPrint('[API] Retrying DELETE(auth) $uri with new token');
          await sendRequest(newToken);
          return;
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _send(Future<http.Response> req, String path) async {
    try {
      final response = await req.timeout(_timeout);
      debugPrint('[API] ${response.statusCode} ← $path');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = utf8.decode(response.bodyBytes);
        return json.decode(body) as Map<String, dynamic>;
      }
      final body = utf8.decode(response.bodyBytes);
      debugPrint('[API] Error body: $body');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    } on SocketException catch (e) {
      debugPrint('[API] SocketException: $e → $path');
      throw ApiException(
        statusCode: 0,
        message: 'Không thể kết nối server. Kiểm tra BE đang chạy.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: e.message);
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[API] Unknown error: $e');
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }
}


// ── Exception ────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
