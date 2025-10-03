// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/splashController.dart';
import 'package:astrowaypartner/views/Authentication/login_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'package:astrowaypartner/utils/global.dart' as global;
import '../BaseRoute/baseRoute.dart';

class SplashScreen extends BaseRoute {
  SplashScreen({super.key, a, o});

  final customerController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    // Run check after build
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkLoginStatus(context);
    });

    return Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/splash_background.jpg"),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.h,
                backgroundImage:
                    const AssetImage('assets/images/astrologer_splash.jpeg'),
              ),
              const SizedBox(height: 15),
              global.appName != ""
                  ? Text(
                      global.appName,
                      style: Get.textTheme.headlineSmall,
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Checks if user is already logged in
  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    final astroId = prefs.getString("astro_id");

    print("🔍 [SplashScreen] Token: $token");
    print("🔍 [SplashScreen] Astro ID: $astroId");

    if (token != null && astroId != null) {
      // ✅ User is already logged in → go to Home
      Get.offAll(() => const HomeScreen());
    } else {
      // ❌ No login data → go to Login
      Get.offAll(() => const LoginScreen());
    }
  }
}
