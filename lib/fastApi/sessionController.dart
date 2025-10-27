import 'dart:ui';
import 'package:astrowaypartner/views/Authentication/login_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionController extends GetxController {
  final box = GetStorage();

  RxString token = ''.obs;
  RxString userId = ''.obs;
  RxString astroId = ''.obs;

  // ---------------- LOAD SESSION ----------------
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Use keys consistent with FastApiServices
    token.value =
        prefs.getString("access_token") ?? box.read("access_token") ?? "";
    userId.value = prefs.getString("user_id") ?? box.read("user_id") ?? "";
    astroId.value = prefs.getString("astro_id") ?? box.read("astro_id") ?? "";

    print("🔍 [SessionController] Loaded Session:");
    print("   token: ${token.value.isEmpty ? "❌ Empty" : token.value}");
    print("   userId: ${userId.value.isEmpty ? "❌ Empty" : userId.value}");
    print("   astroId: ${astroId.value.isEmpty ? "❌ Empty" : astroId.value}");
  }

  // ---------------- SAVE SESSION ----------------
  Future<void> saveSession({
    required String tokenValue,
    required String userIdValue,
    required String astroIdValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ Save using consistent keys
    await prefs.setString("access_token", tokenValue);
    await prefs.setString("user_id", userIdValue);
    await prefs.setString("astro_id", astroIdValue);

    // Backup to GetStorage
    box.write("access_token", tokenValue);
    box.write("user_id", userIdValue);
    box.write("astro_id", astroIdValue);

    token.value = tokenValue;
    userId.value = userIdValue;
    astroId.value = astroIdValue;

    print("💾 [SessionController] Saved Session:");
    print("   token: $tokenValue");
    print("   userId: $userIdValue");
    print("   astroId: $astroIdValue");
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await box.erase();

    token.value = "";
    userId.value = "";
    astroId.value = "";

    print("🧹 [SessionController] Cleared all session data.");

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
