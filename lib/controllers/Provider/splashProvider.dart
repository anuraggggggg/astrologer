import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/views/Authentication/login_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewSplashProvider extends ChangeNotifier {
  final FastApiServices apiService = FastApiServices();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  NewSplashProvider() {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      final astroId = prefs.getString("astro_id");

      if (token != null && astroId != null) {
        print("🔑 Token & Astro ID found, verifying profile...");

        try {
          final profile = await apiService.getAstrologerById();
          print("✅ Profile Verified: ${profile['name'] ?? 'No Name'}");

          // Navigate to HomeScreen after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            _navigateToHome();
          });
        } catch (e) {
          print("⚠️ Token invalid or profile fetch failed: $e");
          await FastApiServices.clearUserData();
          _navigateToLogin();
        }
      } else {
        print("⚠️ No token found. Navigate to LoginScreen.");
        _navigateToLogin();
      }
    } catch (e) {
      print("🚨 Exception in NewSplashProvider: $e");
      _navigateToLogin();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(GlobalContext.context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(GlobalContext.context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }
}

// Helper to access navigator context anywhere
class GlobalContext {
  static late BuildContext context;
}
