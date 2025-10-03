import 'dart:ui';

import 'package:astrowaypartner/views/Authentication/login_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionController extends GetxController {
  RxString token = ''.obs;
  RxString userName = ''.obs;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString("authToken") ?? "";
    userName.value = prefs.getString("userName") ?? "";
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token.value = "";
    userName.value = "";

    Get.offAll(() => const LoginScreen());

    Get.snackbar(
      "Logged Out",
      "You have been successfully logged out.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      colorText: const Color.fromARGB(255, 255, 255, 255),
      duration: const Duration(seconds: 2),
    );
  }
}
