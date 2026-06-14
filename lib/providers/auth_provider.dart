import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'cart_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  CartProvider? _cartProvider;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  
  int? _userId;
  String? _email;
  String? _fullName;
  String? _role;
  String? _accessToken;
  String? _errorMessage;

  /// Inject CartProvider để tự động load/reset cart
  void setCartProvider(CartProvider cartProvider) {
    _cartProvider = cartProvider;
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  
  int? get userId => _userId;
  String? get email => _email;
  String? get fullName => _fullName;
  String? get role => _role;
  String? get accessToken => _accessToken;
  String? get errorMessage => _errorMessage;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      await _saveAuthData(data);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String fullName, String email, String phoneNumber, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(fullName, email, phoneNumber, password);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendOtp(email);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyOtp(email, otp);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Không lấy được Google ID Token.');
      }

      final data = await _authService.loginWithGoogle(idToken);
      await _saveAuthData(data);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('email');
    await prefs.remove('full_name');
    await prefs.remove('role');
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _fullName = null;
    _role = null;
    _accessToken = null;
    _errorMessage = null;

    // Reset giỏ hàng khi logout
    _cartProvider?.reset();
    
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('access_token')) {
      return false;
    }

    _accessToken = prefs.getString('access_token');
    _userId = prefs.getInt('user_id');
    _email = prefs.getString('email');
    _fullName = prefs.getString('full_name');
    _role = prefs.getString('role');
    _isAuthenticated = true;

    notifyListeners();

    // Load giỏ hàng sau auto-login
    if (_userId != null) {
      _cartProvider?.loadCart(_userId!);
    }
    return true;
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    _userId = data['userId'];
    _email = data['email'];
    _fullName = data['fullName'];
    _role = data['role'];
    _accessToken = data['accessToken'];
    _isAuthenticated = true;

    await prefs.setInt('user_id', _userId!);
    await prefs.setString('email', _email!);
    await prefs.setString('full_name', _fullName!);
    await prefs.setString('role', _role!);
    await prefs.setString('access_token', _accessToken!);
    if (data['refreshToken'] != null) {
      await prefs.setString('refresh_token', data['refreshToken']);
    }

    // Load giỏ hàng ngay sau khi đăng nhập
    if (_userId != null) {
      _cartProvider?.loadCart(_userId!);
    }
  }
}
