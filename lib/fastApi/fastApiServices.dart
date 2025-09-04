import 'dart:convert';
import 'package:astrowaypartner/fastApi/fastApiEndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FastApiServices {
  final String baseUrl = "https://fastapi.jyotishionline.com/api/v1/astro";
  String? _accessToken;

  // ---------------- LOGIN & TOKEN ----------------
  Future<void> loginAndGetToken() async {
    final url = Uri.parse(FastApiEndpoints.login);
    print("🔑 Logging in user...");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": "Jincy@gmail.com",
        "password": "Jincy@12345",
      },
    );

    print("📡 Login Status: ${response.statusCode}");
    print("📩 Login Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("🔍 Login Response JSON: $data");

      _accessToken = data["access_token"];
      if (_accessToken == null) {
        throw Exception("❌ access_token not found in API response!");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", _accessToken!);

      print("✅ Token saved successfully: $_accessToken");
    } else {
      throw Exception("🚨 Failed to login: ${response.body}");
    }
  }

  /// Helper to get saved token from SharedPreferences
  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  /// Get token or auto-login if missing
  Future<String> _getOrLoginToken() async {
    String? token = await _getSavedToken();

    if (token == null) {
      print("⚠️ No token found, attempting auto-login...");
      await loginAndGetToken();
      token = await _getSavedToken();

      if (token == null) {
        throw Exception("🚨 Auto-login failed. No token received.");
      }
    }

    return token;
  }

  /// Create Astrologer API Call
  Future<Map<String, dynamic>> createAstrologer(
      Map<String, dynamic> body) async {
    try {
      final token = await _getOrLoginToken();
      final url = Uri.parse("$baseUrl/astrologers");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("📡 Create Astrologer Status: ${response.statusCode}");
      print("📩 Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        // Token might be expired, try logging in again once
        print("🔄 Token expired, retrying login...");
        await loginAndGetToken();
        return await createAstrologer(body); // Retry once
      } else {
        return {
          "success": false,
          "error": "HTTP ${response.statusCode}: ${response.body}",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
