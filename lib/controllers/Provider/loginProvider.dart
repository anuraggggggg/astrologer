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

  // /// 🔹 Step 2: Verify OTP and store token
  //   Future<void> verifyOtp({
  //   required String contactNo,
  //   required String countryCode,
  //   required String otp,
  // }) async {
  //   try {
  //     isLoading = true;
  //     notifyListeners();

  //     final response = await FastApiServices.verifyOtp(
  //       contactNo: contactNo,
  //       countryCode: countryCode,
  //       otp: otp,
  //     );

  //     // ✅ Store token or user info
  //     accessToken = response["access_token"];
  //     print("✅ Access Token: $accessToken");

  //     // You can also store user details if needed
  //     // final astro = response["astro"];

  //   } catch (e) {
  //     print("❌ [AuthProvider] OTP verification failed: $e");
  //     rethrow; // Let UI handle error message
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

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
