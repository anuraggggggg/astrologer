import 'package:flutter/material.dart';
import '../../fastApi/fastApiServices.dart';

class AuthProvider with ChangeNotifier {
  final FastApiServices apiService;

  AuthProvider(this.apiService);

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _accessToken;
  String? _userId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get accessToken => _accessToken;
  String? get userId => _userId;
  bool get isAuthenticated => _accessToken != null;

  /// ✅ Clear error message manually (useful for dialogs/snackbars)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ✅ Clear success message manually
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// 🔹 Step 1: Request OTP
  Future<bool> requestOtp({
    required String contactNo,
    required String countryCode,
  }) async {
    _setLoading(true);

    try {
      print(
          "📩 [AuthProvider] Requesting OTP for $contactNo with country code $countryCode");

      final response = await apiService.astroLogin(
        contactNo: contactNo, // <--- This must match the input
        countryCode: countryCode,
      );

      _successMessage = response['message'] ?? 'OTP sent successfully!';
      return true;
    } catch (e) {
      _errorMessage = "Failed to send OTP: $e";
      print("🚨 Exception occurred: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 Step 2: Verify OTP and store token
  Future<bool> verifyOtp({
    required String contactNo,
    required String countryCode,
    required String otp,
  }) async {
    _setLoading(true);
    print(
        "📩 [AuthProvider] Verifying OTP for $contactNo with country code $countryCode, OTP: $otp");

    try {
      final response = await apiService.verifyOtp(
        contactNo: contactNo,
        countryCode: countryCode,
        otp: otp,
      );

      print("✅ [AuthProvider] OTP verification response: $response");

      _accessToken = response['access_token'];
      _userId = response['astro']?['id'];
      _successMessage = "OTP verified successfully!";
      return true;
    } catch (e, stackTrace) {
      print("❌ [AuthProvider] OTP verification failed!");
      print("🛑 Error: $e");
      print("📜 StackTrace: $stackTrace");
      _errorMessage = "OTP verification failed: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ Helper to manage loading state
  void _setLoading(bool value) {
    _isLoading = value;
    print("⏳ [AuthProvider] isLoading: $_isLoading");
    notifyListeners();
  }

  /// ✅ Logout user (clear token and data)
  void logout() {
    _accessToken = null;
    _userId = null;
    _successMessage = null;
    _errorMessage = null;
    print("🔓 [AuthProvider] User logged out, data cleared");
    notifyListeners();
  }
}
