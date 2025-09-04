//flutter
// ignore_for_file: file_names, avoid_print, prefer_interpolation_to_compose_strings, prefer_null_aware_operators, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
//models
import 'package:astrowaypartner/models/Notification/storytextmodel.dart';
import 'package:astrowaypartner/models/imageModel.dart';
import 'package:astrowaypartner/models/viewStoryModel.dart';
import 'package:astrowaypartner/views/HomeScreen/FloatingButton/FreeKundli/kundlichartModel.dart';
import 'package:http_parser/http_parser.dart'; // Import MediaType class

import 'package:astrowaypartner/controllers/dailyHoroscopeController.dart';
import 'package:astrowaypartner/models/Master%20Table%20Model/get_master_table_list_model.dart';
import 'package:astrowaypartner/models/Notification/notification_model.dart';
import 'package:astrowaypartner/models/app_review_model.dart';
import 'package:astrowaypartner/models/astrologerAssistant_model.dart';
import 'package:astrowaypartner/models/call_model.dart';
import 'package:astrowaypartner/models/chat_model.dart';
import 'package:astrowaypartner/models/customerReview_model.dart';
import 'package:astrowaypartner/models/dailyHororscopeModelVedic.dart';
import 'package:astrowaypartner/models/device_detail_model.dart';
import 'package:astrowaypartner/models/following_model.dart';
import 'package:astrowaypartner/models/hororScopeSignModel.dart';
import 'package:astrowaypartner/models/kundliBasicModel.dart';
import 'package:astrowaypartner/models/kundliModel.dart';
import 'package:astrowaypartner/models/product_category_list_model.dart';
import 'package:astrowaypartner/models/product_model.dart';
import 'package:astrowaypartner/models/report_model.dart';
import 'package:astrowaypartner/models/systemFlagModel.dart';
import 'package:astrowaypartner/models/user_model.dart';
import 'package:astrowaypartner/models/wallet_model.dart';
import 'package:astrowaypartner/models/withdrawOptionModel.dart';
import 'package:astrowaypartner/services/apiResult.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/callAvailability_controller.dart';
import '../controllers/chatAvailability_controller.dart';
import '../models/amount_model.dart';
import '../models/assistant_chat_request_model.dart';
import '../models/astrology_blog_model.dart';
import '../models/intake_model.dart';
import '../models/kundlimodelAdd.dart';
import '../models/language.dart';
import '../models/live_users_model.dart';
import '../models/video_model.dart';
import '../models/wait_list_model.dart';
import '../utils/config.dart';

//packages

String screen = 'apiHelper.dart';
final callControlleronline = Get.find<CallAvailabilityController>();
final chatControlleronline = Get.find<ChatAvailabilityController>();

final dailyhoroscopeController = Get.find<DailyHoroscopeController>();

class APIHelper {
  //bind you api result using it
  dynamic getAPIResult<T>(final response, T recordList) {
    try {
      print("jkanskjdn");
      print("apiresult response-> ${json.decode(response.body)}");
      print("recordlist-> $recordList");


      APIResult result;
      result = APIResult.fromJson(json.decode(response.body), recordList);

      return result;
    } catch (e) {
      log("Exception1: $screen - getAPIResult " + e.toString());
    }
  }

  Future<dynamic> logoutapi() async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}logout'),
        headers: await global.getApiHeaders(true),
      );
      debugPrint('headers : ${global.getApiHeaders(true)}');

      debugPrint('logout : ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      debugPrint("Exception in acceptChat : -" + e.toString());
    }
  }

  Future<String?> getPrivacyUrl() async {
    try {
      final response = await http.post(
        Uri.parse("https://astroway.diploy.in/admin/privacy-policy"),
      );
      debugPrint('privacy- ${response.body}');
      String? privacyUrl;
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        privacyUrl = responseData['response'];
      } else {
        privacyUrl = null;
      }
      return privacyUrl;
    } catch (e) {
      debugPrint('Exception in getPrivacyUrl(): $e');
      return null; // Handle the exception by returning null or throwing an error
    }
  }

  Future<dynamic> getPdfPrice() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}pdf/price"),
        headers: await global.getApiHeaders(true),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = response.body;
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      debugPrint('Exception in getKundli():' + e.toString());
    }
  }

  Future<dynamic> addAmountInWallet({
    required double amount,
    required double cashback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}addpayment'),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "userId": global.user.id!,
          'amount': amount,
          'cashback_amount': cashback
        }),
      );
      log('add money response:- ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Exception:- in addAmountInWallet ' + e.toString());
    }
  }

  Future getWalletinformations() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}withdrawlmethod/get"),
      );
      debugPrint('asd ${appParameters[appMode]['apiUrl']}/withdrawlmethod/get');
      debugPrint('getWalletinformations body : ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = withdrawOptionModelFromJson(response.body).recordList;
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      debugPrint(
          "Exception: api_helper.dart - getpaymentAmount(): " + e.toString());
    }
  }

  Future getpaymentAmount() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getRechargeAmount"),
      );
      debugPrint(
          'asd ${appParameters[appMode]['apiUrl']}/getRechargeAmount'); //! error when no money in wallet still want to connect to guru add dialog to show no money and recharge
      debugPrint('recharge body : ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<AmountModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => AmountModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      debugPrint(
          "Exception: api_helper.dart - getpaymentAmount(): " + e.toString());
    }
  }

  //Signup astrologer
  Future<dynamic> signUp(CurrentUser user) async {
    try {
      print('${appParameters[appMode]['apiUrl']}astrologer/add');
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}astrologer/add"),
        headers: await global.getApiHeaders(false),
        body: json.encode(user.toJson()),
      );
      log("${appParameters[appMode]['apiUrl']}astrologer/add");
      log('Response code : ${response.statusCode}');
      log('response : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        recordList =
            CurrentUser.fromJson(json.decode(response.body)["recordList"]);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - signUp(): " + e.toString());
    }
  }

  Future<dynamic> validateSession() async {
    try {
      print(
          'validate seesion url-> ${appParameters[appMode]['apiUrl']}validateSessionForAstrologer');
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}validateSessionForAstrologer"),
        headers: await global.getApiHeaders(true),
      );
      print('validate resp : ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList =
            CurrentUser.fromJson(json.decode(response.body)["recordList"]);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception - validateSession(): " + e.toString());
    }
  }

  Future<dynamic> setRemoteId(int astroId, int remoteId) async {
    try {
      print('${appParameters[appMode]['apiUrl']}addAstrohost');
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}addAstrohost"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": "$astroId",
          "hostId": "$remoteId",
        }),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - setRemoteId(): " + e.toString());
    }
  }

//Update astrologer
  Future astrologerUpdate(CurrentUser user) async {
    try {
      print("${appParameters[appMode]['apiUrl']}astrologer/update");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}astrologer/update"),
        headers: await global.getApiHeaders(true),
        body: json.encode(user.toJson()),
      );
      print("Edit profile body ${user.toJson()}");
      log('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        recordList =
            CurrentUser.fromJson(json.decode(response.body)["recordList"]);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - astrologerUpdate(): " + e.toString());
    }
  }

//Check conatct number is exist
  Future<dynamic> checkExistContactNumber(String contactNo) async {
    try {
      print('${appParameters[appMode]['apiUrl']}checkContactNoExist');
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}checkContactNoExist"),
        headers: await global.getApiHeaders(false),
        body: json.encode({
          'contactNo': contactNo,
        }),
      );
      print('Status Code: ${response.statusCode}');
      print('done : ${response.body}');
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - checkExistContactNumber(): " + e.toString());
    }
  }

//Login api
  Future<dynamic> login(String? contactNo, String? email,
      DeviceInfoLoginModel userDeviceDetails) async {
    try {
      print('${appParameters[appMode]['apiUrl']}loginAppAstrologer');
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}loginAppAstrologer"),
        headers: await global.getApiHeaders(false),
        body: json.encode({
          "contactNo": contactNo,
          'email': email,
          'userDeviceDetails': userDeviceDetails
        }),
      );
      log('--login--');
      log('${appParameters[appMode]['apiUrl']}loginAppAstrologer');
      log('${await global.getApiHeaders(false)}');
      log(json.encode(
          {"contactNo": contactNo, 'userDeviceDetails': userDeviceDetails}));
      log('login email  : ${json.encode({
        "contactNo": contactNo,
        'email': email,
        'userDeviceDetails': userDeviceDetails
      })}');
      log('responselogin:- ${response.body}');
      dynamic recordList;

      if (response.statusCode == 200) {
        log('login response:- ${response.body}');
        recordList =
            CurrentUser.fromJson(json.decode(response.body)["recordList"][0]);
        recordList.token = json.decode(response.body)["token"];
        recordList.tokenType = json.decode(response.body)["token_type"];
      } else if (response.statusCode == 400) {
        recordList = json.decode(response.body)["message"];
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - login(): " + e.toString());
    }
  }

  //Delete astrologer account
  Future<dynamic> astrologerDelete(int id) async {
    try {
      print("${appParameters[appMode]['apiUrl']}astrologer/delete");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}astrologer/delete"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"id": id}),
      );
      log('delete account : ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - astrologerDelete(): " + e.toString());
    }
  }

//Master table
  Future getMasterTableData() async {
    try {
      log("rsponse- > ${appParameters[appMode]['apiUrl']}getMasterAstrologer");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getMasterAstrologer"),
        headers: await global.getApiHeaders(false),
      );
      log("${global.getApiHeaders(false)}");

      print('done : ${response.statusCode}');
      print('body : ${response.body}');

      print(json.decode(response.body));
      dynamic recordList;
      if (response.statusCode == 200) {
        print("akjsndkjnksjd");
        log("Response : ${json.decode(response.body)['status']}");
        print(json.decode(response.body));
        recordList =
            GetMasterTableDataModel.fromJson(json.decode(response.body));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - getMasterTableData(): " + e.toString());
    }
  }

//-------------------------------- Profile details ---------------------------//

//get profile
  Future<dynamic> getAstrologerProfile(
      int id, int startIndex, int record) async {
    debugPrint('id is $id and startIndex is $startIndex and record is $record');
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getAstrologerById"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          "startIndex": startIndex,
          "fetchRecord": record
        }),
      );
      // log('getAstrologerProfile api= ${response.body}');
      dynamic recordList;
      debugPrint('HISTORY-RESPONSE ${response.body}');
      debugPrint('HISTORY-RESPONSE code ${response.statusCode}');
      if (response.statusCode == 200) {
        recordList = List<CurrentUser>.from(json
            .decode(response.body)["recordList"]
            .map((x) => CurrentUser.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getAstrologerProfile():-' + e.toString());
    }
  }

//--------------------------------Chat ---------------------------//
  //get chat request
  Future<dynamic> getchatRequest(int id, int startIndex, int record) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}chatRequest/get"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          "startIndex": startIndex,
          "fetchRecord": record
        }),
      );
      log('chat request api= ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<ChatModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => ChatModel.fromJson(x)));
        log('chat request api 2= ${response.body}');
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getchatRequest(): ' + e.toString());
    }
  }

  //get chat reject
  Future<dynamic> chatReject(int chatId) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}chatRequest/reject"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"chatId": chatId}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - chatReject(): ' + e.toString());
    }
  }

  Future<dynamic> acceptChatRequest(int chatId) async {
    const String screen = 'ApiHelper - acceptChatRequest';
    try {
      final url = "${appParameters[appMode]['apiUrl']}chatRequest/accept";
      final headers = await global.getApiHeaders(true);
      final body = json.encode({"chatId": chatId});

      debugPrint('🔁 [POST] $url');
      debugPrint('📩 Request Headers: $headers');
      debugPrint('📨 Request Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Uncomment this if needed later:
        // final recordList = List<ChatModel>.from(decoded["recordList"].map((x) => ChatModel.fromJson(x)));
        return getAPIResult(response, null);
      } else {
        debugPrint('❌ Server returned error: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      debugPrint('🚨 Exception at $screen');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stack');
      return null;
    }
  }


  Future<dynamic> getChatId() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}chatRequest/accept"),
        headers: await global.getApiHeaders(true),
        //body: {'chatId': '$chatId'},
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        //recordList = List<ChatModel>.from(json.decode(response.body)["recordList"].map((x) => ChatModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getChatId(): ' + e.toString());
    }
  }

  Future<dynamic> addChatId(int userId, int partnerId, int chatId) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}chatRequest/storeChatId"),
        headers: await global.getApiHeaders(true),
        body: json.encode(
            {"userId": userId, "partnerId": partnerId, "chatId": chatId}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
        //recordList = List<ChatModel>.from(json.decode(response.body)["recordList"].map((x) => ChatModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - addChatId(): ' + e.toString());
    }
  }

  Future<dynamic> addChatToken(
      String token, String channelName, int chatId) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}chatRequest/storeToken"),
        headers: await global.getApiHeaders(true),
        body: json.encode(
            {"token": token, "channelName": channelName, "chatId": chatId}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - addChatToken():-' + e.toString());
    }
  }

//-------------------------- Call --------------------------------------//
  //get call request
  Future<dynamic> getCallRequest(int id, int startIndex, int record) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}callRequest/get"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          "startIndex": startIndex,
          "fetchRecord": record
        }),
      );
      log('call list before reponse --API_HELPER_SCREEN--> ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<CallModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => CallModel.fromJson(x)));
      } else {
        recordList = null;
      }

      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getCallRequest(): ' + e.toString());
    }
  }

  Future<dynamic> acceptCallRequest(int callId) async {
    print('callid $callId');
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}callRequest/accept"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"callId": callId}),
      );
      print('call respones ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        //recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - acceptCallRequest():-' + e.toString());
    }
  }

  Future<dynamic> acceptVideoCallRequest(int callId) async {
    print('callid $callId');
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}callRequest/accept"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"callId": callId}),
      );
      print('call respones ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        //recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - acceptCallRequest():-' + e.toString());
    }
  }

  Future<dynamic> rejectCallRequest(int callId) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}callRequest/reject"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"callId": callId}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - rejectCallRequest():-' + e.toString());
    }
  }

  Future<dynamic> addCallToken(
      String token, String channelName, int callId) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}callRequest/storeToken"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "token": token,
          "channelName": channelName,
          "callId": callId,
        }),
      );
      log('live astrologer repsonse ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - addCallToken():-' + e.toString());
    }
  }

//----------------------------- report ----------------------------------//

  Future<dynamic> getReportRequest(int id, int startIndex, int record) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getUserReport"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          "startIndex": startIndex,
          "fetchRecord": record
        }),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<ReportModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => ReportModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getReportRequest():-' + e.toString());
    }
  }

  //Upload a report file
  Future sendReport(int id, String reportFile) async {
    try {
      print("${appParameters[appMode]['apiUrl']}userreport/add");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}userreport/add"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"id": id, "reportFile": reportFile}),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        if (json.decode(response.body)["recordList"] != null) {
          recordList =
              ReportModel.fromJson(json.decode(response.body)["recordList"]);
        }
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - sendReport(): " + e.toString());
    }
  }

//----------------------------------------Astromall-----------------------------------//
  Future addAstromallProdcut(ProductModel productModel) async {
    try {
      print("${appParameters[appMode]['apiUrl']}astromallProduct/add");
      final response = await http.post(
          Uri.parse(
              "${appParameters[appMode]['apiUrl']}api/getproductCategory"),
          headers: await global.getApiHeaders(true),
          body: json.encode(productModel));
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
      } else {}
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - addAstromallProdcut(): " + e.toString());
    }
  }

  Future getproductCategory() async {
    try {
      print("${appParameters[appMode]['apiUrl']}getproductCategory");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getproductCategory"),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        recordList = List<ProductCategoryListModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => ProductCategoryListModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - getproductCategory(): " + e.toString());
    }
  }

//----------------------------------------Astrologer assistant-----------------------------------//

//Add an astrologer assistant
  Future<dynamic> astrologerAssistantAdd(
      AstrologerAssistantModel assistantmodel) async {
    try {
      print("${appParameters[appMode]['apiUrl']}astrologerAssistant/add");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}astrologerAssistant/add"),
        headers: await global.getApiHeaders(true),
        body: json.encode(assistantmodel.toJson()),
      );
      print(assistantmodel.toJson());
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        if (json.decode(response.body)["recordList"] != null) {
          recordList = AstrologerAssistantModel.fromJson(
              json.decode(response.body)["recordList"]);
        }
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - astrologerAssistantAdd(): " + e.toString());
    }
  }

//get astrologer asssistant
  Future<dynamic> getAstrologerAssistant(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getAstrologerAssistant"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"astrologerId": id}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<AstrologerAssistantModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => AstrologerAssistantModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getAstrologerAssistant():-' + e.toString());
    }
  }

//Update astrologer assistant
  Future astrologerAssistantUpdate(
      AstrologerAssistantModel assistantmodel) async {
    try {
      print("${appParameters[appMode]['apiUrl']}astrologerAssistant/update");
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}astrologerAssistant/update"),
        headers: await global.getApiHeaders(true),
        body: json.encode(assistantmodel.toJson()),
      );

      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        if (json.decode(response.body)["recordList"] != null) {
          recordList = AstrologerAssistantModel.fromJson(
              json.decode(response.body)["recordList"]);
        }
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print(
          "Exception: $screen - astrologerAssistantUpdate(): " + e.toString());
    }
  }

  //get astrologer assistant chat request
  Future getAssistantChatRequest(int astrologerId) async {
    try {
      print("${appParameters[appMode]['apiUrl']}getAssistantChatRequest");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getAssistantChatRequest"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"astrologerId": astrologerId}),
      );

      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        if (json.decode(response.body)["recordList"] != null) {
          recordList = List<AssistantChatRequestModel>.from(json
              .decode(response.body)["recordList"]
              .map((x) => AssistantChatRequestModel.fromJson(x)));
        }
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - getAssistantChatRequest(): " + e.toString());
    }
  }

  //Astrologer assistant delete
  Future<dynamic> assistantDelete(int id) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}astrologerAssistant/delete"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"id": id}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.encode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - assistantDelete():-' + e.toString());
    }
  }

  Future<dynamic> getHoroscope({int? horoscopeSignId}) async {
    debugPrint('horoscopeSignId-> $horoscopeSignId');
    debugPrint('horoscopeSignId header-> ${await global.getApiHeaders(true)}');

    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getDailyHoroscope"),
        body: json.encode({"horoscopeSignId": horoscopeSignId}),
        headers: await global.getApiHeaders(true),
      );

      // debugPrint('respone Horoscope-> ${response.body}');
      int _ncalltype = json.decode(response.body)['astroApiCallType'] ?? 2;

      dailyhoroscopeController.updatecalltype(_ncalltype);
      debugPrint('calltype Horoscope-> $_ncalltype');

      dynamic recordList;
      dynamic vedicList;

      if (_ncalltype == 3) {
        if (response.statusCode == 200) {
          debugPrint('return inside 3');
          vedicList = json.decode(response.body)['vedicList'];
          DailyHororscopeModelVedic.fromJson(json.decode(response.body));
        } else {
          vedicList = null;
        }
        return vedicList;
      } else if (_ncalltype == 2) {
        if (response.statusCode == 200) {
          debugPrint('return inside 2');

          recordList = json.decode(response.body)['recordList'];
        } else {
          recordList = null;
        }
        return recordList;
      }
    } catch (e) {
      print('Exception in getHoroscope():' + e.toString());
    }
  }

//----------------------------------------astrologer review-----------------------------------//

//get customer review for astrologer
  Future<dynamic> getCustomerReview(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getAstrologerUserReview"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"astrologerId": id}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        recordList = List<CustomerReviewModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => CustomerReviewModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getCustomerReview():-' + e.toString());
    }
  }

  //Reply astrologer review
  Future<dynamic> astrologerReply(int id, String reply) async {
    try {
      print("${appParameters[appMode]['apiUrl']}userReview/reply");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}userReview/reply"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"reviewId": id, "reply": reply}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - astrologerReply():-' + e.toString());
    }
  }

  //---------------------------------- Live Astrologer --------------------------------

  //send liveAstrologer token

  Future sendLiveAstrologerToken(int astrologerId, String channelName,
      String token, String chatToken) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}liveAstrologer/add"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": astrologerId,
          "channelName": channelName,
          "token": token,
        }),
      );
      print("hellakjsndj");
      print("${appParameters[appMode]['apiUrl']}liveAstrologer/add");
      print(json.encode({
        "astrologerId": astrologerId,
        "channelName": channelName,
        "token": token,
      }));
      print('statuscoderecord : ${response.statusCode}');
      log('liveAstrologer response is->  : ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        log('response decode->  : ${json.decode(response.body)['recordList']}');
        recordList = json.decode(response.body)['recordList'];
        log('live token save successfully');
        log('recordList is->  : $recordList');
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - addAstromallProdcut(): " + e.toString());
    }
  }

  Future<dynamic> getWaitList(String channel) async {
    try {
      final response = await http.post(
          Uri.parse("${appParameters[appMode]['apiUrl']}waitlist/get"),
          body: {
            "channelName": channel,
          });
      dynamic recordList;
      print('jnkjnkasdnknk');
      print('${response.statusCode}');
      print('wait list reponse -> ${response.body}');

      if (response.statusCode == 200) {
        recordList = List<WaitList>.from(json
            .decode(response.body)["recordList"]
            .map((x) => WaitList.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception in getAstrologer():' + e.toString());
    }
  }

  Future sendLiveAstrologerChatToken(
      int astrologerId, String channelName, String token) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}liveAstrologer/livechattoken"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": astrologerId,
          "channelName": channelName,
          "liveChatToken": token
        }),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body)['recordList'];
        log('live chat token save successfully');
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - sendLiveAstrologerChatToken(): " +
          e.toString());
    }
  }

  Future endLiveSession(int astrologerId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}liveAstrologer/endSession"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"astrologerId": astrologerId}),
      );
      log('endLiveSession response : ${response.body}');
      log('end sesion url : ${appParameters[appMode]['apiUrl']}liveAstrologer/endSession');

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body)['recordList'];
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - endLiveSession(): " + e.toString());
    }
  }

  //-------------------------------Follower---------------------------------//
  Future<dynamic> getFollowersList(int id, int startIndex, int record) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getAstrologerFollower"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          "startIndex": startIndex,
          "fetchRecord": record
        }),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        recordList = List<FollowingModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => FollowingModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getFollowersList():-' + e.toString());
    }
  }

  //-------------------------------Wallet---------------------------------//
  Future<dynamic> withdrawAdd(
      int id,
      double withdrawAmount,
      String paymentMethod,
      String upiId,
      String accountNumber,
      String ifscCode,
      String accountHolderName) async {
    try {
      log("${appParameters[appMode]['apiUrl']}withdrawlrequest/add");
      log("payment method is -$paymentMethod");

      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}withdrawlrequest/add"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          "withdrawAmount": withdrawAmount,
          "paymentMethod": paymentMethod,
          "upiId": upiId,
          "accountHolderName": accountHolderName,
          "accountNumber": accountNumber,
          "ifscCode": ifscCode,
        }),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - withdrawAdd(): " + e.toString());
    }
  }

  //update withdraw
  Future<dynamic> withdrawUpdate(
      int id,
      int astrologerId,
      double withdrawAmount,
      String paymentMethod,
      String upiId,
      String accountNumber,
      String ifscCode,
      String accountHolderName,
      ) async {
    try {
      print("${appParameters[appMode]['apiUrl']}withdrawlrequest/update");
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}withdrawlrequest/update"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "id": id,
          "astrologerId": astrologerId,
          "withdrawAmount": withdrawAmount,
          "paymentMethod": paymentMethod,
          "upiId": upiId,
          "accountHolderName": accountHolderName,
          "accountNumber": accountNumber,
          "ifscCode": ifscCode,
        }),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: $screen - withdrawUpdate(): " + e.toString());
    }
  }

  //get amount
  Future<dynamic> getWithdrawAmount(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}withdrawlrequest/get"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"astrologerId": id}),
      );
      log('amount -> ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        recordList =
            Withdraw.fromJson(json.decode(response.body)["recordList"]);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getWithdrawAmount():-' + e.toString());
    }
  }

  //-------------------------------Notification---------------------------------//
  Future<dynamic> getNotification(int startIndex, int record) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getUserNotification"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"startIndex": startIndex, "fetchRecord": record}),
      );
      debugPrint(
          'notification- url- ${appParameters[appMode]['apiUrl']}getUserNotification")}');
      debugPrint('notification header ${await global.getApiHeaders(true)}');
      dynamic recordList;
      if (response.statusCode == 200) {
        print('Notification : ${json.decode(response.body)}');
        recordList = List<NotificationModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => NotificationModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getNotification():-' + e.toString());
    }
  }

  Future<String?> otpResponseOptless(Map<String, dynamic>? dataResponse) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}getOtlResponse'),
        body: json.encode({"token": dataResponse!['response']['token']}),
        headers: await global.getApiHeaders(false),
      );
      String? otplessphoneno;
      Map data = json.decode(response.body);
      if (response.statusCode == 200) {
        otplessphoneno =
        data['authentication_details']['phone']['phone_number'];
      } else {
        otplessphoneno = null;
      }
      return otplessphoneno;
    } catch (e) {
      print('Exception: $screen - deteNotification():-' + e.toString());
    }
    return null;
  }

  Future<dynamic> deleteNotification(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}userNotification/deleteUserNotification"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"id": notificationId}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - deteNotification():-' + e.toString());
    }
  }

  Future<ImageModel> uploadImageFileToServer(
      {required String id, List<String>? imagePath}) async {
    log('rastrologer id : $id');
    for (var img in imagePath!) {
      log('image are path: uploading is $img');
    }

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${appParameters[appMode]['apiUrl']}addStory"),
      );
      // Add API headers
      request.headers
          .addAll(await global.getApiHeaders(true, ismultipart: true));
      request.fields['astrologerId'] = id;
      request.fields['mediaType'] = 'image';

      // Add images to request
      for (int i = 0; i < imagePath.length; i++) {
        File imageFile = File(imagePath[i]);
        List<int> imageBytes = await imageFile.readAsBytes();
        String filename = imagePath[i].split('/').last;
        log('uploiading image name is $filename');
        http.MultipartFile imageMultipartFile = http.MultipartFile.fromBytes(
          'media[]',
          imageBytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageMultipartFile);
      }

      // Send request and handle response
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      log('response status code: ${response.statusCode}');
      log('response body video: $responseBody');

      ImageModel recordList;
      if (response.statusCode == 200) {
        recordList = imageModelFromJson(responseBody);
      } else {
        recordList = ImageModel(message: 'Failed to upload images');
      }
      return recordList;
    } catch (e) {
      log('Exception during file upload: $e');
      rethrow;
    }
  }

  Future<VideoModel> uploadFileToServer(
      {required String id, File? videoFile}) async {
    log('rastrologer id : $id');

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${appParameters[appMode]['apiUrl']}addStory"),
      );
      // Add API headers
      request.headers
          .addAll(await global.getApiHeaders(true, ismultipart: true));
      // Add astrologerId field
      request.fields['astrologerId'] = id;
      request.fields['mediaType'] = 'video';

      // Read video file bytes
      List<int> videoBytes = videoFile!.readAsBytesSync();
      final videoFileinBytes = http.MultipartFile.fromBytes(
        'media',
        videoBytes,
        filename: 'video.mp4',
        contentType: MediaType('video', 'mp4'),
      );
      request.files.add(videoFileinBytes);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      log('response log status code: ${response.statusCode}');
      log('response log body: $responseBody');

      VideoModel recordList;
      if (response.statusCode == 200) {
        recordList = videoModelFromJson(responseBody);
      } else {
        recordList = VideoModel(message: 'Failed to upload video');
      }
      return recordList;
    } catch (e) {
      log('Exception during file upload: $e');
      rethrow;
    }
  }

  Future<StoryTextModel> uploadTextToServer(
      {required String id, String? txts}) async {
    log('rastrologer id : $id');

    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}addStory"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": id,
          'mediaType': 'text',
          'media': txts,
        }),
      );
      log('text response ${response.body}');
      StoryTextModel recordList;
      if (response.statusCode == 200) {
        recordList = storyTextModelFromJson(response.body);
        // recordList = ;
      } else {
        recordList = StoryTextModel(message: 'Failed to upload video');
      }
      return recordList;
    } catch (e) {
      log('Exception during text upload: $e');
      rethrow;
    }
  }

  Future<dynamic> getAstroStory(String astrologerId) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getStory"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"astrologerId": astrologerId}),
      );
      print("viewSigleStory");
      print("${response.statusCode}");
      print("${jsonDecode(response.body)}");
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<ViewStories>.from(json
            .decode(response.body)["recordList"]
            .map((x) => ViewStories.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      debugPrint('Exception in getStory():' + e.toString());
    }
  }

  Future<dynamic> deleteAllNotification(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "${appParameters[appMode]['apiUrl']}userNotification/deleteAllNotification"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"userId": userId}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body)['recordList'];
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - deleteAllNotification():-' + e.toString());
    }
  }

  Future<dynamic> getLiveUsers(String channelName) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}getLiveUser'),
        body: json.encode({"channelName": channelName}),
        headers: await global.getApiHeaders(false),
      );
      print('done get live: $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<LiveUserModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => LiveUserModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in getLiveUsers : -" + e.toString());
    }
  }

  Future<dynamic> addKundli(
      List<KundliModelAdd> basicDetails, bool ismatch, int amount) async {
    debugPrint('basicDetails ${basicDetails.toString()}');
    debugPrint('ismatch $ismatch');
    debugPrint('amount $amount');

    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}kundali/add'),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "kundali": basicDetails,
          "amount": amount,
          "is_match": ismatch,
        }),
      );
      log('kundli body ${json.encode({
        "kundali": basicDetails,
        "amount": 0,
        "is_match": ismatch,
      })}');
      log('kundli added ${response.body}');

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body)['recordList'];
        log('kundli recordList $recordList');
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception:- in add-Kundli:- ' + e.toString());
    }
  }

  Future<dynamic> updateKundli(int id, KundliModel basicDetails) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}kundali/update/$id'),
        headers: await global.getApiHeaders(true),
        body: json.encode(basicDetails),
      );
      print(response);
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception:- in updateKundli:-' + e.toString());
    }
  }

  Future<dynamic> deleteKundli(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}kundali/delete'),
        body: json.encode({"id": "$id"}),
        headers: await global.getApiHeaders(true),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in deleteKundli : -" + e.toString());
    }
  }

  Future<dynamic> getKundli() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getkundali"),
        headers: await global.getApiHeaders(true),
      );
      debugPrint('get kundli by list ${response.body}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<KundliModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => KundliModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception in getKundli():' + e.toString());
    }
  }

  Future<dynamic> getSystemFlag() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getSystemFlag"),
      );
      print("kjasndkjn");
      print("${appParameters[appMode]['apiUrl']}getSystemFlag");
      print("${response.statusCode}");
      dynamic recordList;
      if (response.statusCode == 200) {
        print("kjansdkj response ${json.decode(response.body)["recordList"]}");

        recordList = List<SystemFlag>.from(json
            .decode(response.body)["recordList"]
            .map((x) => SystemFlag.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - getSystemFlag():-' + e.toString());
    }
  }

  Future<dynamic> addChatWaitList(
      {int? astrologerId, String? status, DateTime? datetime}) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}addStatus"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": astrologerId,
          "status": status,
          "waitTime": datetime != null ? datetime.toIso8601String() : null
        }),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
        debugPrint('set status is: ${response.body}');
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - addChatWaitList(): ' + e.toString());
    }
  }

  Future<dynamic> addCallWaitList(
      {int? astrologerId, String? status, DateTime? callDateTime}) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}addCallStatus"),
        headers: await global.getApiHeaders(true),
        body: json.encode({
          "astrologerId": astrologerId,
          "status": status,
          "waitTime":
          callDateTime != null ? callDateTime.toIso8601String() : null
        }),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception: $screen - addCallWaitList(): ' + e.toString());
    }
  }

  Future<bool> setAstrologerOnOffBusyline(String callStatus) async {
    try {
      log("set status is: $callStatus");
      global.showOnlyLoaderDialog();
      await callControlleronline.statusCallChange(
        astroId: global.user.id!,
        callStatus: callStatus,
      );
      await chatControlleronline.statusChatChange(
        astroId: global.user.id!,
        chatStatus: callStatus,
      );
      global.hideLoader();
      return true;
    } catch (error) {
      log('error $error');
      global.hideLoader();
      return false;
    }
  }
  // Future<void> setAstrologerOnOffBusyline(String callStatus) async {
  //   debugPrint("set status is: $callStatus");
  //   global.showOnlyLoaderDialog();
  //   await callControlleronline.statusCallChange(
  //     astroId: global.user.id!,
  //     callStatus: callStatus,
  //   );
  //   await chatControlleronline.statusChatChange(
  //     astroId: global.user.id!,
  //     chatStatus: callStatus,
  //   );
  //   global.hideLoader();
  // }

  //Third Party API

  Future<dynamic> getReport(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/general_ascendant_report"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getReportDasha():' + e.toString());
    }
  }

  Future<dynamic> getHororscopeSign() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getHororscopeSign"),
        headers: await global.getApiHeaders(true),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<HororscopeSignModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => HororscopeSignModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception in getHororscopeSign():' + e.toString());
    }
  }

//{required String girlID, required String boyID}
  Future<dynamic> getMatching(int boyid, int girlid) async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}KundaliMatching/report"),
        body:
        json.encode({"male_kundli_id": boyid, "female_kundli_id": girlid}),
        headers: await global.getApiHeaders(true),
      );
      log('matching details $boyid,  $girlid}');
      dynamic recordList;
      debugPrint('matching res ${response.body}');
      debugPrint('matching status is ${response.statusCode}');

      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
        // recordList = List<KundliMatchingDetailModel>.from(json
        //     .decode(response.body)["recordList"]
        //     .map((x) => KundliMatchingDetailModel.fromJson(x)));
      } else {
        recordList = null;
      }

      return recordList;
    } catch (e) {
      print('Exception in getDailyHororscope():' + e.toString());
    }
  }

  Future<dynamic> getManglic(
      int? dayBoy,
      int? monthBoy,
      int? yearBoy,
      int? hourBoy,
      int? minBoy,
      int? dayGirl,
      int? monthGirl,
      int? yearGirl,
      int? hourGirl,
      int? minGirl,
      ) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/match_manglik_report"),
        body: json.encode({
          "m_day": dayBoy,
          "m_month": monthBoy,
          "m_year": yearBoy,
          "m_hour": hourBoy,
          "m_min": minBoy,
          "m_lat": 19.132,
          "m_lon": 72.342,
          "m_tzone": 5.5,
          "f_day": dayGirl,
          "f_month": monthGirl,
          "f_year": yearGirl,
          "f_hour": hourGirl,
          "f_min": minGirl,
          "f_lat": 19.132,
          "f_lon": 72.342,
          "f_tzone": 5.5
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
        // recordList = List<KundliMatchingDetailModel>.from(json
        //     .decode(response.body)["recordList"]
        //     .map((x) => KundliMatchingDetailModel.fromJson(x)));
      } else {
        recordList = null;
      }

      return recordList;
    } catch (e) {
      print('Exception in getDailyHororscope():' + e.toString());
    }
  }

  Future<dynamic> getKundaliPDf({
    required int userid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}kundali/get/$userid'),
        headers: await global.getApiHeaders(true),
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
        debugPrint('response pdf $recordList');
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getKundliBasicDetails():' + e.toString());
    }
  }

  Future<dynamic> getKundliBasicDetails(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/birth_details"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": "application/json"
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getKundliBasicDetails():' + e.toString());
    }
  }

  Future<dynamic> getKundliBasicPanchangDetails(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/basic_panchang"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getKundliBasicPanchangDetails():' + e.toString());
    }
  }

  Future<dynamic> getAvakhadaDetails(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/astro_details"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getAvakhadaDetails():' + e.toString());
    }
  }

  Future<dynamic> getPlanetsDetail(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/planets"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getAvakhadaDetails():' + e.toString());
    }
  }

  Future<dynamic> getSadesati(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/sadhesati_current_status"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getSadesati():' + e.toString());
    }
  }

  Future<dynamic> getKalsarpa(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/kalsarpa_details"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getKalsarpa():' + e.toString());
    }
  }

  Future<dynamic> getGemstone(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/basic_gem_suggestion"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getGemstone():' + e.toString());
    }
  }

  Future<dynamic> getVimshattari(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/major_vdasha"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = (json.decode(response.body) as List)
            .map((e) => VimshattariModel.fromJson(e))
            .toList();
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getVimshattari():' + e.toString());
    }
  }

  Future<dynamic> getAntardasha(
      {String? antarDasha,
        int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/sub_vdasha/$antarDasha"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = (json.decode(response.body) as List)
            .map((e) => VimshattariModel.fromJson(e))
            .toList();
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getAntardasha():' + e.toString());
    }
  }

  Future<dynamic> getPatynatarDasha(
      {String? firstName,
        String? secoundName,
        int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse("https://json.astrologyapi.com/v1/sub_sub_vdasha/Mars/Rahu"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = (json.decode(response.body) as List)
            .map((e) => VimshattariModel.fromJson(e))
            .toList();
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getPatynatarDasha():' + e.toString());
    }
  }

  Future<dynamic> getSookshmaDasha(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://json.astrologyapi.com/v1/sub_sub_sub_vdasha/Mars/Rahu/Jupiter"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = (json.decode(response.body) as List)
            .map((e) => VimshattariModel.fromJson(e))
            .toList();
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getSookshmaDasha():' + e.toString());
    }
  }

  Future<dynamic> getPrana(
      {int? day,
        int? month,
        int? year,
        int? hour,
        int? min,
        double? lat,
        double? lon,
        double? tzone}) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://json.astrologyapi.com/v1/sub_sub_sub_sub_vdasha/Mars/Rahu/Jupiter/Saturn"),
        body: json.encode({
          "day": day,
          "month": month,
          "year": year,
          "hour": hour,
          "min": min,
          "lat": lat,
          "lon": lon,
          "tzone": tzone
        }),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );

      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = (json.decode(response.body) as List)
            .map((e) => VimshattariModel.fromJson(e))
            .toList();
      } else {
        recordList = null;
      }
      return recordList;
    } catch (e) {
      print('Exception in getPrana():' + e.toString());
    }
  }

  Future<dynamic> geoCoding({double? lat, double? long}) async {
    debugPrint(
        'api userid is ${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}');
    debugPrint(
        'api key is ${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}');
    debugPrint('lat is $lat');
    debugPrint('long is $long');

    try {
      final response = await http.post(
        Uri.parse('https://json.astrologyapi.com/v1/timezone_with_dst'),
        body: json.encode({"latitude": lat, "longitude": long}),
        headers: {
          "authorization": "Basic " +
              base64.encode(
                  "${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiUserId)}:${global.getSystemFlagValue(global.systemFlagNameList.astrologyApiKey)}"
                      .codeUnits),
          "Content-Type": 'application/json'
        },
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in geoCoding : -" + e.toString());
    }
  }

  Future<dynamic> generateRtmToken(String agoraAppId,
      String agoraAppCertificate, String chatId, String channelName) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}generateToken'),
        body: json.encode({
          "appID": agoraAppId,
          "appCertificate": agoraAppCertificate,
          "user": chatId,
          "channelName": channelName
        }),
        headers: await global.getApiHeaders(true),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in generateRtmToken : -" + e.toString());
    }
  }

  Future<dynamic> getKundliChartforChat(String id) async {
    final modelbody = json.encode({
      "userId": id,
    });

    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getKundaliReportById"),
        headers: await global.getApiHeaders(true),
        body: modelbody,
      );
      log('kundli res is getKundliChartforChat ${response.body}');
      log('kundli code is getKundliChartforChat ${response.statusCode}');

      dynamic kundlichartmodel;
      if (response.statusCode == 200) {
        kundlichartmodel = kundliChartModelFromJson(response.body);
      } else {
        kundlichartmodel = null;
      }
      return kundlichartmodel;
    } catch (e) {
      debugPrint('Exception in getkundliChart original():' + e.toString());
    }
  }

  Future<dynamic> getKundliChart(KundliModel kundlimode) async {
    var id = kundlimode.id;
    var name = kundlimode.name;
    var gender = kundlimode.gender;
    var birthDate = kundlimode.birthDate; // This is a DateTime object
    var birthTime = kundlimode.birthTime;
    var birthPlace = kundlimode.birthPlace;
    var latitude = kundlimode.latitude;
    var longitude = kundlimode.longitude;
    var timezone = kundlimode.timezone;
    var lang = kundlimode.lang ?? "en";
    final modelbody = json.encode({
      "kundali": [
        {
          "id": id,
          "lang": lang,
          "name": name,
          "gender": gender,
          "birthDate": birthDate.toIso8601String(),
          "birthTime": birthTime,
          "birthPlace": birthPlace,
          "latitude": latitude.toString(),
          "longitude": longitude.toString(),
          "timezone": timezone.toString(),
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}kundali/addnew"),
        headers: await global.getApiHeaders(true),
        body: modelbody,
      );
      log('kundli res is here ${response.body}');
      log('kundli code is here ${response.statusCode}');

      dynamic kundlichartmodel;
      if (response.statusCode == 200) {
        kundlichartmodel = kundliChartModelFromJson(response.body);
      } else {
        kundlichartmodel = null;
      }
      return kundlichartmodel;
    } catch (e) {
      debugPrint('Exception in getkundliChart original():' + e.toString());
    }
  }

  Future<dynamic> generateRtcToken(String agoraAppId,
      String agoraAppCertificate, String chatId, String channelName) async {
    print(
        'RTC token-data : agoracertificate is $agoraAppCertificate and agoraappid is $agoraAppId and chatID is $chatId and channel name is $channelName}');
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}generateRtcToken'),
        body: json.encode({
          "appID": agoraAppId,
          "appCertificate": agoraAppCertificate,
          "user": chatId,
          "channelName": channelName
        }),
        headers: await global.getApiHeaders(true),
      );
      print('RTC token-generate : ${json.decode(response.body)}');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body);
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in generateRtcToken : -" + e.toString());
    }
  }

  //astrology blogs

  Future<dynamic> getBlog(
      String searchString, int startIndex, int fetchRecord) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}getAppBlog'),
        headers: await global.getApiHeaders(false),
        body: json.encode({
          "searchString": searchString,
          "startIndex": startIndex,
          "fetchRecord": fetchRecord
        }),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<Blog>.from(json
            .decode(response.body)["recordList"]
            .map((x) => Blog.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in getBlog : -" + e.toString());
    }
  }

  Future<dynamic> viewerCount(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}addBlogReader'),
        headers: await global.getApiHeaders(true),
        body: json.encode({"blogId": "$id"}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body)['recordList'];
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception:- in viewerCount ' + e.toString());
    }
  }

//get app review
  Future<dynamic> getAppReview() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}appReview/get"),
        headers: await global.getApiHeaders(true),
        body: json.encode({"appId": 2}),
      );
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<AppReviewModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => AppReviewModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception in getAppReview():' + e.toString());
    }
  }

  Future<dynamic> addAppFeedback(var basicDetails) async {
    try {
      final response = await http.post(
        Uri.parse('${appParameters[appMode]['apiUrl']}appReview/add'),
        headers: await global.getApiHeaders(true),
        body: json.encode(basicDetails),
      );
      print(response);
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = json.decode(response.body)['recordList'];
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print('Exception:- in addAppFeedback:-' + e.toString());
    }
  }

  Future getLanguagesForMultiLanguage() async {
    try {
      final response = await http.post(
        Uri.parse("${appParameters[appMode]['apiUrl']}getAppLanguage"),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<Language>.from(json
            .decode(response.body)["recordList"]
            .map((x) => Language.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception: api_helper.dart - getLanguagesForMultiLanguage(): " +
          e.toString());
    }
  }

  //get called user data

  Future<dynamic> getIntakedata(int id) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${appParameters[appMode]['apiUrl']}chatRequest/getIntakeForm'),
        headers: await global.getApiHeaders(true),
        body: json.encode({"userId": "$id"}),
      );
      print('done : $response');
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<IntakeModel>.from(json
            .decode(response.body)["recordList"]
            .map((x) => IntakeModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getAPIResult(response, recordList);
    } catch (e) {
      print("Exception in getIntakedata : -" + e.toString());
    }
  }
}
