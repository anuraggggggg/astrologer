import 'dart:convert';
import 'dart:io';
import 'package:astrowaypartner/fastApi/fastApiEndPoints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart'; // For basename()


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
        "username": "jinu@example.com",
        "password": "123456",
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

  Future<Map<String, dynamic>> getAstrologerById() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch saved astro_id and token
    final astroId = prefs.getString("astro_id"); // keep dashes
    final token = prefs.getString("access_token");
    final userId = prefs.getString("user_id");

    print("🔍 SharedPreferences Data:");
    print("   astro_id: ${astroId ?? "❌ Not Found"}");
    print("   access_token: ${token ?? "❌ Not Found"}");
    print("   user_id: ${userId ?? "❌ Not Found"}");

    if (astroId == null || token == null) {
      throw Exception("Missing astro_id or token. Please login again.");
    }

    final url = Uri.parse("$baseUrl/astro/astrologers/$astroId");
    print("🌐 Constructed URL: $url");

    // Print headers
    final headers = {
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };
    print("📝 Request Headers:");
    headers.forEach((key, value) => print("   $key: $value"));

    try {
      print("📡 Sending GET request to fetch astrologer details...");
      final response = await http.get(url, headers: headers);

      print("⬅️ Response received");
      print("   Status Code: ${response.statusCode}");
      print("   Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Successfully fetched profile data:");
        print(const JsonEncoder.withIndent('  ').convert(data));
        return data;
      } else if (response.statusCode == 401) {
        print("🚨 Unauthorized: Invalid token");
        await prefs.remove("access_token");
        throw Exception("Unauthorized: Invalid token. Please login again.");
      } else if (response.statusCode == 404) {
        print("⚠️ Not Found: Check if astro_id is correct and exists in API");
        throw Exception("Astrologer not found: ${response.body}");
      } else {
        print("❌ Failed to fetch astrologer details");
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🚨 Exception during API call: $e");
      print("📄 Stack trace:\n$stackTrace");
      rethrow;
    }
  }

  // ---------------- FETCH ASTROLOGER REQUESTS ----------------
  Future<List<Map<String, dynamic>>> getAstrologerRequests(
      String astrologerId) async {
    final url = Uri.parse(FastApiEndpoints.getAstrologerRequests(astrologerId));
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch requests: ${response.body}");
    }
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
          "countryCode": formattedCountryCode,
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

  Future<bool> respondToRequest({
    required int requestId,
    required String status, // "accepted" or "declined"
  }) async {
    if (status != "accepted" && status != "declined") {
      throw Exception("Status must be either 'accepted' or 'declined'");
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    if (token == null) {
      throw Exception("No access token found. Please login again.");
    }

    final url = Uri.parse("$baseUrl/$requestId");

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode == 200) {
      print("✅ Request $requestId $status successfully.");
      return true;
    } else {
      print("❌ Failed to respond: ${response.body}");
      return false;
    }
  }

  // ---------------- VERIFY OTP & SAVE USER ----------------
  static Future<Map<String, dynamic>> verifyOtp({
    required String contactNo,
    required String countryCode,
    required String otp,
  }) async {
    final url = Uri.parse(
        "https://fastapi.jyotishionline.com/api/v1/auth/astro-verify-otp");

    final formattedCountryCode = countryCode.replaceAll('+', '');

    print(
        "📩 [FastApiServices] Verifying OTP for $contactNo with country code $formattedCountryCode, OTP: $otp");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "contactNo": contactNo,
        "countryCode": formattedCountryCode,
        "otp": otp,
      },
    );

    print("⬅️ Response status: ${response.statusCode}");
    print("⬅️ Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Save token & user details in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = data["access_token"];
      final astro = data["astro"];

      if (token != null && astro != null) {
        await prefs.setString("access_token", token);
        await prefs.setString("token_type", data["token_type"] ?? "");

        // ✅ Store all astro details safely
        await prefs.setString("user_id", astro["user_id"] ?? "");
        await prefs.setString("astro_id", astro["astro_id"] ?? "");
        await prefs.setString("contactNo", astro["contactNo"] ?? "");
        await prefs.setString("countryCode", astro["countryCode"] ?? "");
        await prefs.setString("name", astro["name"] ?? "");
        await prefs.setString("profileImage", astro["profileImage"] ?? "");

        print("✅ Saved User Data:");
        print("   user_id: ${astro["user_id"]}");
        print("   astro_id: ${astro["astro_id"]}");
        print("   token: $token");
      } else {
        print("⚠️ Missing token or astro details in response.");
      }

      return data;
    } else {
      throw Exception("OTP verification failed: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAstrologerRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final astroId = prefs.getString("astro_id");
    final token = prefs.getString("access_token");

    if (astroId == null || token == null) {
      throw Exception("Astro ID or token not found. Please login first.");
    }

    // Using endpoint from FastApiEndpoints
    final url = Uri.parse(FastApiEndpoints.getAstrologerRequests(astroId));
    final headers = {
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };

    print("🌐 Fetching astrologer requests from: $url");
    print("📝 Headers: $headers");

    final response = await http.get(url, headers: headers);

    print("⬅️ Response Status: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception(
          "Failed to fetch requests: ${response.statusCode} ${response.body}");
    }
  }




  // ---------------- HELPERS ----------------
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("🧹 Cleared all saved user data.");
  }



//Edit Profile
   Future<Map<String, dynamic>> editProfile({
    required String contactNo,
    required String currentCity,
    required int experienceInYears,
    required int audioCallCharge,
    required String name,
    required String languageKnown,
    required int chatCharge,
    required int videoCallCharge,
    required String primarySkill,
    File? profileImage, // optional image
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final astroId = prefs.getString("astro_id");
    final token = prefs.getString("access_token");

    if (astroId == null || token == null) {
      throw Exception("Astro ID or token not found. Please login first.");
    }

    final url = Uri.parse(FastApiEndpoints.editAstrolgerProfile + astroId);
    print("🌐 EditProfile URL: $url");

// Multipart request
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = 'application/json';

// Add text fields
    request.fields['contactNo'] = contactNo;
    request.fields['currentCity'] = currentCity;
    request.fields['experienceInYears'] = experienceInYears.toString();
    request.fields['audioCallCharge'] = audioCallCharge.toString();
    request.fields['name'] = name;
    request.fields['languageKnown'] = languageKnown;
    request.fields['chatCharge'] = chatCharge.toString();
    request.fields['videoCallCharge'] = videoCallCharge.toString();
    request.fields['primarySkill'] = primarySkill;

// Add profile image if provided
    if (profileImage != null && profileImage.existsSync()) {
      var stream = http.ByteStream(profileImage.openRead());
      var length = await profileImage.length();
      request.files.add(
        http.MultipartFile(
          'profileImage',
          stream,
          length,
          filename: basename(profileImage.path),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("⬅️ Status Code: ${response.statusCode}");
      print("⬅️ Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {"success": false, "error": response.body};
      }
    } catch (e) {
      print("🚨 Exception in editProfile: $e");
      return {"success": false, "error": e.toString()};
    }
  }





}




