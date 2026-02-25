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
    print("🔍 Checking existing token...");

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");

    print("📦 Previously saved token (key: 'access_token'): $token");

    if (token == null || token.isEmpty) {
      throw Exception("❌ No existing token found. Please verify OTP again.");
    }

    _accessToken = token;

    print("🔐 Using access_token: $_accessToken");
    print("==============================\n");
  }




  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString("token");
    print("🔍 Retrieved Saved Token: ${savedToken ?? "❌ No token found"}");
    return savedToken;
  }


  Future<Map<String, dynamic>> getAstrologerById() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch astro_id only
    final astroId = prefs.getString("astro_id");

    print("🔍 SharedPreferences Data:");
    print("   astro_id: ${astroId ?? "❌ Not Found"}");

    if (astroId == null) {
      throw Exception("Missing astro_id. Please login again.");
    }

    final url = Uri.parse("$baseUrl/astro/astrologers/$astroId");
    print("🌐 Constructed URL: $url");

    try {
      print("📡 Sending GET request (No Authorization)...");

      final response = await http.get(
        url,
        headers: {
          "accept": "application/json",
        },
      );

      print("⬅️ Response received");
      print("   Status Code: ${response.statusCode}");
      print("   Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Successfully fetched astrologer data:");
        print(const JsonEncoder.withIndent('  ').convert(data));
        return data;
      } else if (response.statusCode == 404) {
        throw Exception("Astrologer not found");
      } else {
        throw Exception(
            "Failed to fetch astrologer details (HTTP ${response.statusCode})");
      }
    } catch (e, stackTrace) {
      print("🚨 Exception during API call: $e");
      print("📄 Stack trace:\n$stackTrace");
      rethrow;
    }
  }

  /// ---------------- SESSION TIMER CHECK ----------------
/// Returns:
/// {
///   request_id: int,
///   status: String,
///   remaining_seconds: int,
///   is_expired: bool
/// }
Future<Map<String, dynamic>?> checkSessionTimer(int requestId) async {
  try {
    final url = Uri.parse(
      "$baseUrl/session-request/$requestId/start-timer",
    );

    print("⏱ Checking session timer → $url");

    final response = await http.get(
      url,
      headers: {
        "accept": "application/json",
      },
    );

    print("⬅️ Timer Status: ${response.statusCode}");
    print("⬅️ Timer Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } else {
      print("❌ Timer API failed");
      return null;
    }
  } catch (e) {
    print("🔥 checkSessionTimer error: $e");
    return null;
  }
}


  // ---------------- FETCH ASTROLOGER REQUESTS ----------------
  Future<List<Map<String, dynamic>>> getAstrologerRequests(
      String astrologerId) async {
    final url = Uri.parse(FastApiEndpoints.getAstrologerRequests(astrologerId));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
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

    // ✅ Remove '+' if present
    final formattedCountryCode =
    countryCode.startsWith('+') ? countryCode.substring(1) : countryCode;

    // ✅ SMS ONLY
    const bool sendWhatsapp = false;
    const bool sendSms = true;

    print("➡️ Sending OTP (SMS only)");
    print("📦 contactNo=$contactNo, countryCode=$formattedCountryCode");

    try {
      final response = await http
          .post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "accept": "application/json",
        },
        body: {
          "contactNo": contactNo,
          "countryCode": formattedCountryCode,
          "send_whatsapp": sendWhatsapp.toString(), // "false"
          "send_sms": sendSms.toString(),           // "true"
        },
      )
          .timeout(const Duration(seconds: 10)); // ✅ prevent hanging

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['detail'] ?? 'Failed to request OTP');
      }
    } catch (e) {
      print("🚨 OTP SMS Error: $e");
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
    final url = Uri.parse("$baseUrl/res_accept/$requestId");

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
    required String otherUserId,
    int page = 1,
    int size = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final Uri url = Uri.parse(
      FastApiEndpoints.chatHistoryOther(
        otherUserId,
        page: page,
        size: size,
      ),
    );

    debugPrint("════════ CHAT HISTORY REQUEST ════════");
    debugPrint("📨 otherUserId : $otherUserId");
    debugPrint("📄 page        : $page");
    debugPrint("📦 size        : $size");
    debugPrint("🌐 url         : $url");
    debugPrint("🔐 token       : ${token != null && token.isNotEmpty}");

    final headers = <String, String>{
      "accept": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };

    try {
      final resp = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      debugPrint("⬅️ statusCode : ${resp.statusCode}");

      if (resp.statusCode != 200) {
        debugPrint("❌ ERROR BODY : ${resp.body}");
        throw Exception(
          "Chat history failed (${resp.statusCode})",
        );
      }

      final decoded = jsonDecode(resp.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid response format");
      }

      final messages = decoded['messages'];
      final int msgCount =
      messages is List ? messages.length : 0;

      debugPrint("✅ messages    : $msgCount");
      debugPrint("📄 resp page  : ${decoded['page']}");
      debugPrint("📦 resp size  : ${decoded['size']}");
      debugPrint("📊 total      : ${decoded['total']}");
      debugPrint("══════════════════════════════════════");

      return decoded;
    } on SocketException {
      debugPrint("🌐 No internet connection");
      rethrow;
    } catch (e, st) {
      debugPrint("🔥 CHAT HISTORY EXCEPTION: $e");
      debugPrint(st.toString());
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

      // ✅ Save token & user details
      final prefs = await SharedPreferences.getInstance();
      final token = data["access_token"];
      final astro = data["astro"];

      if (token != null && astro != null) {
        await prefs.setString("access_token", token);
        await prefs.setString("token", token);
        await prefs.setString("auth_token", token);



        await prefs.setString("token_type", data["token_type"] ?? "");


        String? savedToken = prefs.getString("access_token");

// Print confirmed saved token
        print("🔐 access_token for pooji (from SharedPreferences): $savedToken");

        // ✅ Store all astro details
      //  await prefs.setString("user_id", astro["user_id"] ?? "");
        await prefs.setString("astro_id", astro["astro_id"] ?? "");
        await prefs.setString("user_id", astro["user_id"] ?? "");
        await prefs.setString("contactNo", astro["contactNo"] ?? "");
        await prefs.setString("countryCode", astro["countryCode"] ?? "");
        await prefs.setString("name", astro["name"] ?? "");
        await prefs.setString("profileImage", astro["profileImage"] ?? "");

        print("✅ Saved User Data:");
        // print("   user_id: ${astro["user_id"]}");
        print("   astro_id: ${astro["astro_id"]}");
        print("   token saved: $token");
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
  // inside FastApiServices class - replace your editProfile implementation with this

  // Import already present: dart:io, dart:convert, package:http/http.dart' as http, package:path/path.dart
  Future<Map<String, dynamic>> editProfile({
    required Map<String, dynamic> formFields,
    File? profileImage,
    Map<String, File?>? extraFiles, // <-- added parameter
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final astroId = prefs.getString("astro_id") ?? prefs.getString("user_id") ?? '';
      final token = prefs.getString("access_token") ?? '';

      print("🔧 editProfile called. astroId='$astroId' tokenPresent=${token.isNotEmpty}");

      if (astroId.isEmpty || token.isEmpty) {
        return {'success': false, 'error': 'Astro ID or access token missing.'};
      }

      final String urlString = '$baseUrl/astro/astrologers/$astroId/update';
      final Uri uri = Uri.parse(urlString);
      print("🌐 Target URL: $urlString");

      Future<Map<String, dynamic>> sendMultipart(String method) async {
        final request = http.MultipartRequest(method, uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['accept'] = 'application/json';

        // Add fields (include keys with empty string if provided)
        formFields.forEach((key, value) {
          if (value == null) return;
          request.fields[key] = value.toString();
        });

        // Attach profileImage if exists
        if (profileImage != null && profileImage.existsSync()) {
          final multipartFile = await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            filename: basename(profileImage.path),
          );
          request.files.add(multipartFile);
        }

        // Attach extraFiles map entries (use map key as field name)
        if (extraFiles != null && extraFiles.isNotEmpty) {
          for (final entry in extraFiles.entries) {
            final fieldName = entry.key;
            final file = entry.value;
            if (file == null) continue;
            if (!file.existsSync()) {
              print("⚠️ extraFiles: file for '$fieldName' does not exist: ${file.path}");
              continue;
            }
            try {
              final f = await http.MultipartFile.fromPath(
                fieldName,
                file.path,
                filename: basename(file.path),
              );
              request.files.add(f);
            } catch (e) {
              print("❌ Failed to attach file for '$fieldName': $e");
            }
          }
        }

        print('📤 [$method] Headers: ${request.headers}');
        print('📤 [$method] Fields: ${request.fields.keys.toList()}');
        if (request.files.isNotEmpty) print('📤 [$method] Files: ${request.files.map((f) => f.filename).toList()}');

        final streamed = await request.send();
        final resp = await http.Response.fromStream(streamed);

        print('⬅️ [$method] status=${resp.statusCode}');
        print('⬅️ [$method] body=${resp.body}');

        // try decode
        dynamic decoded;
        try {
          decoded = jsonDecode(resp.body);
        } catch (_) {
          decoded = resp.body;
        }

        return {
          'statusCode': resp.statusCode,
          'body': decoded,
          'raw': resp.body,
        };
      }

      // 1) Try PUT first
      final putRes = await sendMultipart('PUT');
      if (putRes['statusCode'] >= 200 && putRes['statusCode'] < 300) {
        final body = putRes['body'];
        if (body is Map<String, dynamic>) return body;
        return {'success': true, 'raw': putRes['raw']};
      }

      // 2) If PUT returned 405/404 try PATCH
      if (putRes['statusCode'] == 405 || putRes['statusCode'] == 404) {
        print("⚠️ PUT returned ${putRes['statusCode']}. Trying PATCH...");
        final patchRes = await sendMultipart('PATCH');
        if (patchRes['statusCode'] >= 200 && patchRes['statusCode'] < 300) {
          final body = patchRes['body'];
          if (body is Map<String, dynamic>) return body;
          return {'success': true, 'raw': patchRes['raw']};
        }

        // 3) Last resort: try POST
        if (patchRes['statusCode'] == 405 || patchRes['statusCode'] == 404) {
          print("⚠️ PATCH returned ${patchRes['statusCode']}. Trying POST...");
          final postRes = await sendMultipart('POST');
          if (postRes['statusCode'] >= 200 && postRes['statusCode'] < 300) {
            final body = postRes['body'];
            if (body is Map<String, dynamic>) return body;
            return {'success': true, 'raw': postRes['raw']};
          } else {
            return {
              'success': false,
              'statusCode': postRes['statusCode'],
              'error': postRes['body'] ?? postRes['raw'],
              'raw': postRes['raw']
            };
          }
        } else {
          return {
            'success': false,
            'statusCode': patchRes['statusCode'],
            'error': patchRes['body'] ?? patchRes['raw'],
            'raw': patchRes['raw']
          };
        }
      }

      // If PUT failed with another status (401, 422, etc) return it
      return {
        'success': false,
        'statusCode': putRes['statusCode'],
        'error': putRes['body'] ?? putRes['raw'],
        'raw': putRes['raw']
      };
    } catch (e, st) {
      print('🚨 Exception in editProfile: $e\n$st');
      return {'success': false, 'error': e.toString()};
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
    required String astrologerId,
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

    // 👇 Query params in URL
    final url = Uri.parse(
      "${FastApiEndpoints.startAgoraLive}?astrologer_id=$astrologerId&ttlSeconds=$ttlSeconds",
    );

    final res = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    print('🔹 Response Code: ${res.statusCode}');
    print('🔹 Response Body: ${res.body}');

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    try {
      final err = jsonDecode(res.body);
      throw Exception('Live start failed (${res.statusCode}): $err');
    } catch (_) {
      throw Exception('Live start failed (${res.statusCode}): ${res.body}');
    }
  }

  Future<Map<String, dynamic>> endAgoraLive({String? overrideToken}) async {
    final prefs = await SharedPreferences.getInstance();

    // token from shared preferences
    final token = overrideToken ??
        prefs.getString('access_token') ??
        prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      throw Exception('Missing access token. Please log in again.');
    }

    // astrologer_id from shared preferences
    final astrologerId = prefs.getString('astro_id');
    if (astrologerId == null || astrologerId.isEmpty) {
      throw Exception('Missing astrologer_id in SharedPreferences.');
    }

    // full URL with query param
    final url = '${FastApiEndpoints.endAgoraLive}?astrologer_id=$astrologerId';

    final res = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    try {
      final err = jsonDecode(res.body);
      throw Exception('Live end failed (${res.statusCode}): $err');
    } catch (_) {
      throw Exception('Live end failed (${res.statusCode}): ${res.body}');
    }
  }

  // ----------------------------------------------------------
  // 🚀 Auto Register FCM Token on App Start
  // ----------------------------------------------------------
  Future<void> autoRegisterAstrologerFcmToken(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fcm_token", fcmToken);
      print("💾 Saved FCM token locally: $fcmToken");

      final astroId = prefs.getString("astro_id");
      if (astroId == null || astroId.isEmpty) {
        print("🚨 Cannot register FCM token — Astrologer ID missing.");
        return;
      }

      final url = Uri.parse(
          "https://fastapi.jyotishionline.com/Astrologer_notification/register-token");

      final body = jsonEncode({
        "astrologer_id": astroId,
        "fcm_token": fcmToken,
      });

      print("📡 Registering FCM Token to FastAPI...");
      print("🔗 URL: $url");
      print("🧾 Body: $body");

      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("⬅️ Response Status: ${response.statusCode}");
      print("⬅️ Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ FCM Token Registered Successfully!");
        print("   🔹 Message: ${data["message"] ?? "Success"}");
      } else {
        print("❌ Failed to register FCM token: ${response.body}");
      }
    } catch (e, stack) {
      print("🔥 Exception while registering FCM token: $e");
      print(stack);
    }
  }


  // ----------------------------------------------------------
// 🚀 SEND NOTIFICATION TO CUSTOMER (Chat / Audio / Video Accepted)
// ----------------------------------------------------------
Future<bool> sendCustomerNotification({
  required String userId,
  required String title,
  required String body,
  required String type,   // e.g. "chat_accept", "audio_accept", "video_accept"
  required String screen, // e.g. "ChatScreen", "AudioCallPage"
  Map<String, dynamic>? data,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("access_token");

  if (token == null || token.isEmpty) {
    throw Exception("Token missing. Please login again.");
  }

  final url = Uri.parse(
      "https://fastapi.jyotishionline.com/Customer_notification/send-notification");

  final payload = {
    "user_id": userId,
    "title": title,
    "body": body,
    "type": type,
    "screen": screen,
    "data": data ?? {}, // optional
  };

  print("📤 Sending Customer Notification...");
  print("🔗 URL: $url");
  print("🧾 Body: ${jsonEncode(payload)}");

  try {
    final res = await http.post(
      url,
      headers: {
        "accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    print("⬅️ Status: ${res.statusCode}");
    print("⬅️ Body: ${res.body}");

    if (res.statusCode == 200) {
      print("✅ Customer Notification Sent Successfully!");
      return true;
    } else {
      print("❌ Failed: ${res.body}");
      return false;
    }
  } catch (e) {
    print("🔥 Exception sendCustomerNotification: $e");
    return false;
  }
}


  final String baseHost = "fastapi.jyotishionline.com"; // NOTE: host only, we use Uri.https below

  /// Sets astrologer online/offline. Returns true on success.
  /// Uses FastApiEndpoints.fastApiBaseUrl to ensure the same base URL is used everywhere.
  Future<bool> setOnlineStatus(String astroId, bool isOnline) async {
    try {
      final base = FastApiEndpoints.fastApiBaseUrl; // "https://fastapi.jyotishionline.com"

      // Build the full URL exactly like the curl you shared.
      // Using Uri.parse is straightforward because base already contains scheme.
      final uriString =
          '$base/astro_online/astrologer/online-status?astro_id=${Uri.encodeComponent(astroId)}&isOnline=${Uri.encodeComponent(isOnline.toString())}';
      final uri = Uri.parse(uriString);

      // debug print the URI so you can copy/paste to curl and compare
      debugPrint('>>> setOnlineStatus: uri=$uri');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final headers = <String, String>{
        'accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // Send POST with empty body to match your curl example
      final response = await http.post(uri, headers: headers, body: '');

      debugPrint('<<< setOnlineStatus: status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      } else {
        // helpful debug information if non-200
        debugPrint('setOnlineStatus failed. status=${response.statusCode}');
        return false;
      }
    } catch (e, st) {
      debugPrint('Exception in setOnlineStatus: $e\n$st');
      return false;
    }
  }


  Future<Map<String, dynamic>?> getWithdrawHistoryPaged({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) return null;

      final base = FastApiEndpoints.fastApiBaseUrl;

      final uri = Uri.parse(
        '$base/api/v1/astro/withdrawals'
            '?page=$page'
            '&size=$size'
            '&order_by=created_at'
            '&order_dir=desc',
      );

      debugPrint('📤 Withdraw API → $uri');

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
          '📥 Withdraw status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e, st) {
      debugPrint('❌ getWithdrawHistoryPaged error: $e\n$st');
      return null;
    }
  }



  /// Get withdraw history for logged-in astrologer
  Future<List<Map<String, dynamic>>?> getWithdrawHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final base = FastApiEndpoints.fastApiBaseUrl; // https://fastapi.jyotishionline.com

      // Correct API path from your docs
      final uri = Uri.parse('$base/api/v1/astro/withdrawals');

      // debug print full URI for quick verification
      debugPrint('getWithdrawHistory: uri=$uri');
      if (token == null || token.isEmpty) {
        debugPrint('getWithdrawHistory: access_token missing in SharedPreferences');
        // return null or throw based on how you want to handle auth missing
        return null;
      }

      final headers = <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);

      debugPrint('getWithdrawHistory: status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          // return list of maps (each map is a withdraw object)
          return List<Map<String, dynamic>>.from(body);
        } else if (body is Map && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        } else {
          debugPrint('getWithdrawHistory: unexpected body format');
          return null;
        }
      } else {
        // helpful logging for 401/403/404 etc
        debugPrint('getWithdrawHistory failed. status=${response.statusCode}');
        return null;
      }
    } catch (e, st) {
      debugPrint('Exception getWithdrawHistory: $e\n$st');
      return null;
    }
  }









}
