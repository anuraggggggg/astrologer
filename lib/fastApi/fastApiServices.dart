import 'dart:convert';
import 'dart:io';
import 'package:astrowaypartner/fastApi/fastApiEndPoints.dart';
import 'package:astrowaypartner/fastApi/sessionController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

import '../models/fastApi/transaction_model.dart'; // For basename()

class FastApiServices {
  final String baseUrl = "https://fastapi.jyotishionline.com/api/v1";
  final SessionController sessionController = Get.find<SessionController>();
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
        "username": "jincyt@example.com",
        "password": "jincy1",
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
    required String status, // "accepted" | "declined" | "pending"
  }) async {
    // API allows "pending" too per docs; keep a guard to avoid typos
    const allowed = {'accepted', 'declined', 'pending'};
    if (!allowed.contains(status)) {
      throw Exception("Status must be one of: ${allowed.join(', ')}");
    }

    // Load token (your API likely requires it for astrologer routes)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    // Build URL exactly like the docs: https://fastapi.jyotishionline.com/api/v1/{id}
    final String baseUrl = "https://fastapi.jyotishionline.com/api/v1";
    final url = Uri.parse("$baseUrl/$requestId");

    final headers = <String, String>{
      "accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
    final body = jsonEncode({"status": status});

    debugPrint("📤 [PATCH] $url");
    debugPrint("🧾 Headers: $headers");
    debugPrint("📦 Body: $body");

    try {
      final res = await http.patch(url, headers: headers, body: body);
      debugPrint("⬅️ Status: ${res.statusCode}");
      debugPrint("⬅️ Body: ${res.body}");

      if (res.statusCode == 200) {
        debugPrint("✅ Request $requestId updated to '$status'");
        return true;
      }

      // Helpful diagnostics for 404s/401s
      if (res.statusCode == 404) {
        debugPrint(
            "❌ 404 Not Found — check requestId ($requestId) exists, and URL is exactly /api/v1/{id}");
      } else if (res.statusCode == 401) {
        debugPrint("❌ 401 Unauthorized — missing/invalid token?");
      }
      return false;
    } catch (e) {
      debugPrint("🔥 respondToRequest exception: $e");
      return false;
    }
  }

  // FastApiServices.dart

  static Future<String?> getAstroId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("astro_id");
  }

  static Future<(String astroId, String token)> requireAstroIdAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    final astroId = prefs.getString("astro_id");
    final token = prefs.getString("access_token");
    if (astroId == null || astroId.isEmpty) {
      throw Exception("Astrologer ID not found. Please login again.");
    }
    if (token == null || token.isEmpty) {
      throw Exception("Access token missing. Please login again.");
    }
    return (astroId, token);
  }

// In FastApiServices

  Future<Map<String, dynamic>> getChatHistoryForAstrologerSelf({
    required String
        otherUserId, // currently you pass astrologer id (self) due to backend quirk
    int page = 1,
    int size = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    // Build URL using your Endpoints util or inline:
    final Uri url = Uri.parse(
      FastApiEndpoints.chatHistoryOther(otherUserId, page: page, size: size),
      // If you don't have FastApiEndpoints.chatHistoryOther:
      // Uri.parse("https://fastapi.jyotishionline.com/chat/history/$otherUserId?page=$page&size=$size"),
    );

    // DEBUG: Log everything we’re about to send
    debugPrint("🛰️ [CHAT_HISTORY_REQ]");
    debugPrint(
        "   • otherUserId: $otherUserId  (NOTE: passing astrologer/self id due to backend quirk)");
    debugPrint("   • page: $page, size: $size");
    debugPrint("   • URL: $url");
    debugPrint("   • Token present: ${token != null && token.isNotEmpty}");
    if (token != null && token.isNotEmpty) {
      final tail =
          token.length > 12 ? token.substring(token.length - 12) : token;
      debugPrint("   • Token tail: ...$tail");
    }

    final headers = <String, String>{
      "accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
    debugPrint("   • Headers: $headers");

    try {
      final resp = await http.get(url, headers: headers);
      debugPrint("⬅️ [CHAT_HISTORY_RES] status=${resp.statusCode}");
      debugPrint("⬅️ Body: ${resp.body}");

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        // quick sanity counters
        final msgs = (decoded['messages'] as List?)?.length ?? 0;
        debugPrint(
            "✅ Parsed OK. messages=$msgs page=${decoded['page']} size=${decoded['size']} total=${decoded['total']}");
        return decoded;
      } else {
        throw Exception("History failed ${resp.statusCode}: ${resp.body}");
      }
    } catch (e, st) {
      debugPrint("🔥 [CHAT_HISTORY_ERR] $e");
      debugPrint("$st");
      rethrow;
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

  Future<Map<String, dynamic>?> balanceAmountAstro(String walletId) async {
    final prefs = await SharedPreferences.getInstance();
    final astroId = prefs.getString("astro_id");
    final token = prefs.getString("access_token");

    if (astroId == null || token == null) {
      throw Exception("Astro ID or token not found. Please login first.");
    }

    final url = Uri.parse(FastApiEndpoints.amountBalanceAstrologer + astroId);
    print("🌐 Wallet Balance URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
            'Full Response:\n${const JsonEncoder.withIndent('  ').convert(data)}');
        return data; // ✅ Return full JSON
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching wallet data: $e');
      return null;
    }
  }

  static Future<List<TransactionModel>> transactionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final astrologerId = prefs.getString('astro_id');

    if (astrologerId == null || astrologerId.isEmpty) {
      throw Exception('Astrologer ID not found in SharedPreferences');
    }

    final url =
        Uri.parse('${FastApiEndpoints.transactionHistory}$astrologerId');

    final response =
        await http.get(url, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load transaction history');
    }
  }

  static Future<Map<String, dynamic>> registerFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    final astrologerId = prefs.getString('astro_id');
    final fcmToken = prefs.getString('fcm_token');

    if (astrologerId == null || astrologerId.isEmpty) {
      throw Exception('Astrologer ID not found in SharedPreferences');
    }

    if (fcmToken == null || fcmToken.isEmpty) {
      throw Exception('FCM Token not found in SharedPreferences');
    }

    final url = Uri.parse(FastApiEndpoints.registerFcmTokenUrl);

    final body = jsonEncode({
      "astrologer_id": astrologerId,
      "fcm_token": fcmToken,
    });

    print("📤 Registering FCM token for Astrologer ID: $astrologerId");
    print("🔗 URL: $url");

    final response = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    print("📡 Response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to register FCM token: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> startAgoraLive({
    int ttlSeconds = 7200,
    String? overrideToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = overrideToken ??
        prefs.getString('access_token') ??
        prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception('Missing access token. Please log in again.');
    }

    final res = await http.post(
      Uri.parse(FastApiEndpoints.startAgoraLive),
      headers: {
        'accept': 'application/json',
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      // Backend expects a raw JSON number (not an object)
      body: jsonEncode(ttlSeconds),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    // Bubble up server detail when possible
    try {
      final err = jsonDecode(res.body);
      throw Exception('Live start failed (${res.statusCode}): $err');
    } catch (_) {
      throw Exception('Live start failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<Map<String, dynamic>> endAgoraLive({String? overrideToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = overrideToken ??
        prefs.getString('access_token') ??
        prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception('Missing access token. Please log in again.');
    }

    final res = await http.post(
      Uri.parse(FastApiEndpoints.endAgoraLive),
      headers: {
        'accept': 'application/json',
        'authorization': 'Bearer $token',
        // NOTE: No body and no content-type required!
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    // Bubble server errors nicely just like your start method
    try {
      final err = jsonDecode(res.body);
      throw Exception('Live end failed (${res.statusCode}): $err');
    } catch (_) {
      throw Exception('Live end failed (${res.statusCode}): ${res.body}');
    }
  }
}
