import 'dart:convert';
import 'package:astrowaypartner/fastApi/fastApiEndPoints.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FastApiServices {
  final String baseUrl = "https://fastapi.jyotishionline.com/api/v1";
  String? _accessToken;

  // ---------------- LOGIN & TOKEN ----------------
  Future<void> loginAndGetToken() async {
    print("🔑 Starting Login Process...");
    final url = Uri.parse(FastApiEndpoints.login);
    print("🌐 Login URL: $url");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": "Jincy@gmail.com",
        "password": "Jincy@12345",
      },
    );

    print("📡 Login Status Code: ${response.statusCode}");
    print("📩 Login Raw Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Login JSON Parsed: $data");

      _accessToken = data["access_token"];
      if (_accessToken == null) {
        throw Exception("❌ access_token not found in API response!");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", _accessToken!);
      print("✅ Token Saved Successfully: $_accessToken");
      print("==============================\n");
    } else {
      print("🚨 Login Failed with Status ${response.statusCode}");
      throw Exception("🚨 Failed to login: ${response.body}");
    }
  }

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString("access_token");
    print("🔍 Retrieved Saved Token: ${savedToken ?? "❌ No token found"}");
    return savedToken;
  }

  Future<String> _getOrLoginToken() async {
    print("\n==============================");
    print("🔑 Checking for Existing Token...");
    String? token = await _getSavedToken();

    if (token == null) {
      print("⚠️ No token found, performing Auto-Login...");
      await loginAndGetToken();
      token = await _getSavedToken();

      if (token == null) {
        throw Exception("🚨 Auto-login failed. No token received.");
      }
    }

    print("✅ Using Token: $token");
    return token;
  }

  // ---------------- ASTROLOGER ----------------
  Future<Map<String, dynamic>> createAstrologer(
      Map<String, dynamic> body) async {
    try {
      print("\n==============================");
      print("🚀 CREATE ASTROLOGER API CALLED");
      print("📝 Request Body:");
      print(const JsonEncoder.withIndent('  ').convert(body));

      final token = await _getOrLoginToken();
      final url = Uri.parse("$baseUrl/users/signup/astrologer");
      print("🌐 API URL: $url");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("📡 Status Code: ${response.statusCode}");
      print("📩 Raw Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = jsonDecode(response.body);
        print("✅ Parsed Response:");
        print(const JsonEncoder.withIndent('  ').convert(parsed));
        print("==============================\n");
        return {"success": true, "data": parsed};
      } else {
        print("❌ ERROR HTTP ${response.statusCode}");
        print("==============================\n");
        return {
          "success": false,
          "error": "HTTP ${response.statusCode}: ${response.body}",
        };
      }
    } catch (e) {
      print("🚨 Exception Occurred: $e");
      print("==============================\n");
      return {"success": false, "error": e.toString()};
    }
  }

  // ---------------- ASTRO LOGIN & OTP ----------------
  /// Hard-coded OTP request exactly as per API documentation
  Future<Map<String, dynamic>> astroLogin({
    required String contactNo,
    required String countryCode,
  }) async {
    final url = Uri.parse("$baseUrl/auth/astro-login");

    // ✅ Remove '+' sign if present
    final formattedCountryCode =
        countryCode.startsWith('+') ? countryCode.substring(1) : countryCode;

    final sendWhatsapp = true;
    final sendSms = true;

    print("➡️ Sending OTP request to $url");
    print(
        "📦 Body: contactNo=$contactNo, countryCode=$formattedCountryCode, send_whatsapp=$sendWhatsapp, send_sms=$sendSms");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "accept": "application/json",
        },
        body: {
          "contactNo": contactNo,
          "countryCode": formattedCountryCode, // ✅ FIXED
          "send_whatsapp": sendWhatsapp.toString(),
          "send_sms": sendSms.toString(),
        },
      );

      print("⬅️ Response status: ${response.statusCode}");
      print("⬅️ Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to request OTP: ${response.body}");
      }
    } catch (e) {
      print("🚨 Exception occurred: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String contactNo,
    required String countryCode,
    required String otp,
  }) async {
    final url = Uri.parse("$baseUrl/auth/verify-otp");

    print("➡️ Verifying OTP at $url");
    print("📦 Body: contactNo=$contactNo, countryCode=$countryCode, otp=$otp");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "contactNo": contactNo,
        "countryCode": countryCode,
        "otp": otp,
      },
    );

    print("⬅️ Response status: ${response.statusCode}");
    print("⬅️ Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("OTP verification failed: ${response.body}");
    }
  }
}
