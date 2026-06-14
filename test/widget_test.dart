import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_electroshops/core/constants/app_strings.dart';
import 'package:mobile_electroshops/core/constants/app_routes.dart';
import 'package:mobile_electroshops/features/auth/screens/login_screen.dart';
import 'package:mobile_electroshops/providers/auth_provider.dart';

class FakeAuthProvider extends AuthProvider {
  bool _mockIsAuthenticated = false;
  bool _mockIsLoading = false;
  String? _mockErrorMessage;

  @override
  bool get isAuthenticated => _mockIsAuthenticated;

  @override
  bool get isLoading => _mockIsLoading;

  @override
  String? get errorMessage => _mockErrorMessage;

  @override
  Future<void> login(String email, String password) async {
    _mockIsLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    if (email == 'unverified@gmail.com') {
      _mockIsLoading = false;
      notifyListeners();
      throw Exception('Email not verified. Please check your inbox.');
    } else if (email == 'fail@gmail.com') {
      _mockIsLoading = false;
      notifyListeners();
      throw Exception('Wrong password');
    }
    _mockIsAuthenticated = true;
    _mockIsLoading = false;
    notifyListeners();
  }

  @override
  Future<void> loginWithGoogle() async {
    _mockIsLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    _mockIsLoading = false;
    notifyListeners();
    throw Exception('sign_in_failed');
  }

  @override
  Future<void> loginWithGoogleSimulation(String email, String name) async {
    _mockIsLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10));
    _mockIsAuthenticated = true;
    _mockIsLoading = false;
    notifyListeners();
  }

  @override
  Future<void> sendOtp(String email) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(AuthProvider authProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          AppRoutes.main: (_) => const Scaffold(body: Text('Main Screen')),
          AppRoutes.register: (_) => const Scaffold(body: Text('Register Screen')),
          AppRoutes.forgotPassword: (_) => const Scaffold(body: Text('Forgot Password Screen')),
          AppRoutes.verifyOtp: (_) => const Scaffold(body: Text('OTP Verification Screen')),
        },
      ),
    );
  }

  testWidgets('LoginScreen renders all fields and buttons', (WidgetTester tester) async {
    final fakeAuth = FakeAuthProvider();
    await tester.pumpWidget(createTestWidget(fakeAuth));

    // Verify title and subtitle are present
    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.loginSubtitle), findsOneWidget);

    // Verify input fields are present
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);

    // Verify forgot password text
    expect(find.text(AppStrings.forgotPassword), findsOneWidget);

    // Verify buttons
    expect(find.text(AppStrings.loginButton), findsOneWidget);
    expect(find.text(AppStrings.googleLogin), findsOneWidget);
    expect(find.text(AppStrings.dontHaveAccount), findsOneWidget);
  });

  testWidgets('Shows error SnackBar when empty email/password login is submitted', (WidgetTester tester) async {
    final fakeAuth = FakeAuthProvider();
    await tester.pumpWidget(createTestWidget(fakeAuth));

    // Tap login button
    await tester.tap(find.text(AppStrings.loginButton));
    await tester.pumpAndSettle();

    // Verify validation snackbar shows up
    expect(find.text(AppStrings.errEmptyLogin), findsOneWidget);
  });

  testWidgets('Performs successful email login and navigates to main', (WidgetTester tester) async {
    final fakeAuth = FakeAuthProvider();
    await tester.pumpWidget(createTestWidget(fakeAuth));

    // Enter email
    final emailField = find.byType(TextField).at(0);
    await tester.enterText(emailField, 'test@gmail.com');

    // Enter password
    final passwordField = find.byType(TextField).at(1);
    await tester.enterText(passwordField, 'password123');

    // Tap login button
    await tester.tap(find.text(AppStrings.loginButton));
    await tester.pump(); // Start navigation/loading
    await tester.pump(const Duration(milliseconds: 50)); // Advance fake delayed future
    await tester.pumpAndSettle();

    // Verify navigation occurred to Main Screen
    expect(find.text('Main Screen'), findsOneWidget);
    expect(fakeAuth.isAuthenticated, isTrue);
  });

  testWidgets('Tapping Google Login triggers simulation dialog when native login fails', (WidgetTester tester) async {
    final fakeAuth = FakeAuthProvider();
    await tester.pumpWidget(createTestWidget(fakeAuth));

    // Tap Google Login
    await tester.tap(find.text(AppStrings.googleLogin));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50)); // Advance fake delayed future
    await tester.pumpAndSettle();

    // Verify Google Simulation Dialog is shown
    expect(find.text(AppStrings.simGoogleTitle), findsOneWidget);
    expect(find.text(AppStrings.simGoogleInfo), findsOneWidget);

    // Tap Cancel on Simulation Dialog
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.text(AppStrings.simGoogleTitle), findsNothing);
  });

  testWidgets('Allows proceeding in Google Simulation Dialog', (WidgetTester tester) async {
    final fakeAuth = FakeAuthProvider();
    await tester.pumpWidget(createTestWidget(fakeAuth));

    // Tap Google Login
    await tester.tap(find.text(AppStrings.googleLogin));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50)); // Advance fake delayed future
    await tester.pumpAndSettle();

    // Dialog shown, tap Continue/Tiếp tục
    await tester.tap(find.text(AppStrings.continueText));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50)); // Advance simulation future
    await tester.pumpAndSettle();

    // Should navigate to Main Screen
    expect(find.text('Main Screen'), findsOneWidget);
    expect(fakeAuth.isAuthenticated, isTrue);
  });
}
