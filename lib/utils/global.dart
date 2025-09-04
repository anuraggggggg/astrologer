// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable, prefer_typing_uninitialized_variables, unnecessary_null_comparison, non_constant_identifier_names, depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/HomeController/live_astrologer_controller.dart';
import '../controllers/networkController.dart';
import '../controllers/splashController.dart';
import '../models/Master Table Model/all_skill_model.dart';
import '../models/Master Table Model/assistant/assistant_all_skill_model.dart';
import '../models/Master Table Model/assistant/assistant_language_list_model.dart';
import '../models/Master Table Model/assistant/assistant_primary_skill_model.dart';
import '../models/Master Table Model/astrologer_category_list_model.dart';
import '../models/Master Table Model/get_master_table_list_model.dart';
import '../models/Master Table Model/highest_qualification_model.dart';
import '../models/Master Table Model/language_list_model.dart';
import '../models/Master Table Model/main_source_business_model.dart';
import '../models/Master Table Model/primary_skill_model.dart';
import '../models/hororScopeSignModel.dart';
import '../models/systemFlagNameList.dart';
import '../models/user_model.dart';
import '../services/apiHelper.dart';
import '../views/Authentication/login_screen.dart';

//----------------------------------------------Variable--------------------------------------

//Getx Controller
NetworkController networkController = Get.put(NetworkController());
LiveAstrologerController liveAstrologerController =
    Get.find<LiveAstrologerController>();
//Shared PReffrence
SharedPreferences? sp;
SharedPreferences? spLanguage;

//Model
CurrentUser user = CurrentUser();
GetMasterTableDataModel getMasterTableDataModelList = GetMasterTableDataModel();
SplashController splashController = Get.find<SplashController>();

//Model List
final List<String> genderList = <String>["Male", "Female", "Other"];
List<AstrolgoerCategoryModel>? astrologerCategoryModelList = [];
List<PrimarySkillModel>? skillModelList = [];
List<AllSkillModel>? allSkillModelList = [];
// List<SystemFlag>? systemFlagList;

List<LanguageModel>? languageModelList = [];
List<AssistantPrimarySkillModel>? assistantPrimarySkillModelList = [];
List<AssistantAllSkillModel>? assistantAllSkillModelList = [];
List<AssistantLanguageModel>? assistantLanguageModelList = [];
List<MainSourceBusinessModel>? mainSourceBusinessModelList = [];
bool isUserJoinAsChatInLive = false;
List<HighestQualificationModel>? highestQualificationModelList = [];
List<CountryTravel>? degreeDiplomaList = [];
List<CountryTravel>? jobWorkingList = [];
APIHelper apiHelper = APIHelper();
List<HororscopeSignModel> hororscopeSignList = [];
final List foreignCountryCountList = <String>["0", "1-2", "3-5", "6+"];
int? userID;

abstract class DateFormatter {
  static String? formatDate(DateTime timestamp) {
    if (timestamp == null) {
      return null;
    }
    String date =
        "${timestamp.day} ${DateFormat('MMMM').format(timestamp)} ${timestamp.year}";
    return date;
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static DateTime? toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }
}

//Other Variable
Map<int, Color> color = {
  50: const Color.fromRGBO(240, 223, 32, .1),
  100: const Color.fromRGBO(240, 223, 32, .2),
  200: const Color.fromRGBO(240, 223, 32, .3),
  300: const Color.fromRGBO(240, 223, 32, .4),
  400: const Color.fromRGBO(240, 223, 32, .5),
  500: const Color.fromRGBO(240, 223, 32, .6),
  600: const Color.fromRGBO(240, 223, 32, .7),
  700: const Color.fromRGBO(240, 223, 32, .8),
  800: const Color.fromRGBO(240, 223, 32, .9),
  900: const Color.fromRGBO(240, 223, 32, 1),
};

String getSystemFlagValue(String flag) {
  return splashController.systemFlag.firstWhere((e) => e.name == flag).value;
}

// Future<void> share() async {
//   await FlutterShare.share(
//     title: '1 item',
//     text: '1 item',
//     chooserTitle: '1 item',
//   );
// }

//Application Id
String appId = Platform.isAndroid ? "AstroGuruAndroid" : "AstroGuruIos";
AndroidDeviceInfo? androidInfo;
IosDeviceInfo? iosInfo;
DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
String? deviceId;
String? fcmToken;
String? deviceLocation;
String? deviceManufacturer;
String? deviceModel;
var appVersion;
int? currentUserId;
//
// String agoraAppId = "b1741743e7544e718c93290256c46e26";
// String agoraAppCertificate = "4590361f9ede41d282dc26c9acb2a91c";
//
// String agoraChannelName = "jytoshi";
// String agoraToken = "4590361f9ede41d282dc26c9acb2a91c";
// String agoraLiveToken = "4590361f9ede41d282dc26c9acb2a91c";
// String channelName = "jytoshi";
// String agoraLiveChannelName = "";
// String liveChannelName = "jytoshi";
// String agoraChatToken = "611367204#1573622";
// String agoraChatUserId = "jytoshi";
// String chatChannelName = "jytoshi";
// String encodedString = "&&";
// String appName = "";

//
// String agoraAppId = "c5e90abe79d14fca95457c870baaca11";
// //d5681698498e46be97987146c630526a
// String agoraAppCertificate = "f1864624e3a24a2ca3ab0ad4c8e42c4f";
// //f7e2921acd0d44debe1221cae7e1e43a
//
// String agoraChannelName = "jyotishi";
// String channelName = "jyotishi";
// String agoraLiveToken = "aa28456002d04f7e8e3966d73d576c30";
// // String channelName = "jyotishi";
// String agoraLiveChannelName = "jyotishi";
// String liveChannelName = "jyotishionline_115";
// String agoraChatToken = "007eJxTYCh1nXDlzj8PcdezGw69t0iZdn7p3kMr9ZQcQndYeP04yjJJgSHZNNXSIDEp1dwyxdAkLTnR0tTE1DzZwtwgKTExOdHQUKm4PKMhkJFB0cCAkZGBlYERCEF8FQbLVLPUVDMTA10zIyNzXUPDNANdC8MkY10jY8tEs1RDs2STJEsA73MnQg==";
// String agoraChatUserId = "jyotish";
// String chatChannelName = "jyotish";
// String encodedString = "&&";
// String appName = "";



String agoraAppId = "bcccb5ab324a40988e9fdc300702dec7";
String agoraAppCertificate = "7d42b9d99b64497b97341d8a5b763a36";

String agoraChannelName = "lidajyotishi";
String agoraToken = "";
String agoraLiveToken = "";
String channelName = "lidajyotishi";
String agoraLiveChannelName = "lidajyotishi";
String liveChannelName = "lidajyotishi";
String agoraChatToken = "";
String agoraChatUserId = "lidajyotishi";
String chatChannelName = "lidajyotishi";
String encodedString = "&&";
String appName = "";

var nativeAndroidPlatform = const MethodChannel('nativeAndroid');
SystemFlagNameList systemFlagNameList = SystemFlagNameList();

//Get app version
String getAppVersion() {
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appVersion = packageInfo.version;
  });
  return appVersion;
  //tell badal that anydesk pe hu main
}

//Get device info
getDeviceData() async {
  await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appVersion = packageInfo.version;
  });
  if (Platform.isAndroid) {
    androidInfo ??= await deviceInfo.androidInfo;
    deviceModel = androidInfo!.model;
    deviceManufacturer = androidInfo!.manufacturer;
    deviceId = androidInfo!.id;
    fcmToken = await FirebaseMessaging.instance.getToken();
  } else if (Platform.isIOS) {
    iosInfo ??= await deviceInfo.iosInfo;
    deviceModel = iosInfo!.model;
    deviceManufacturer = "Apple";
    deviceId = iosInfo!.identifierForVendor;
    fcmToken = await FirebaseMessaging.instance.getToken();
  }
}

Future<Map<String, dynamic>> loadCredentials() async {
  String credentialsPath = 'lib/utils/noti_service.json';
  String content = await rootBundle.loadString(credentialsPath);
  return json.decode(content);
}

Future<void> sendNotification({
  String? fcmToken,
  String? title,
  String? subtitle,
  String? astroname,
  String? channelname,
  String? token,
  String? astroId,
  String? requestType,
  String? id,
  String? charge,
  String? nfcmToken,
  String? astroProfile,
  String? videoCallCharge,
}) async {
  var accountCredentials = await loadCredentials();
  var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  var client = http.Client();
  try {
    var credentials = await obtainAccessCredentialsViaServiceAccount(
        ServiceAccountCredentials.fromJson(accountCredentials), scopes, client);
    if (credentials == null) {
      log('Failed to obtain credentials');
      return;
    }
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer ${credentials.accessToken.data}'
    };
    log("GENERATED TOKEN IS-> ${credentials.accessToken.data}");
    final data = {
      "message": {
        "token": fcmToken,
        "notification": {"body": subtitle, "title": title}, //remove later
        "data": {
          "title": title,
          "description": subtitle,
          "astroName": astroname,
          "channel": channelname,
          "token": token,
          "astroId": astroId,
          "requestType": requestType,
          "id": id,
          "charge": charge,
          "fcmToken": nfcmToken,
          "astroProfile": astroProfile,
          "videoCallCharge": videoCallCharge
        },
        "android": {
          "notification": {"click_action": "android.intent.action.MAIN"}
        }
      }
    };

    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/jyotishiastro-fbd16/messages:send');

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    log('noti response ${response.body}');
    if (response.statusCode == 200) {
      log('Notification sent successfully');
    } else {
      log('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  } finally {
    client.close();
  }
}




//Shared prefrences
//save current user
CurrentUser? astroUser;
saveCurrentUser(CurrentUser user) async {
  try {
    sp = await SharedPreferences.getInstance();
    await sp!.setString('currentUser', json.encode(user.toJson()));
    print("sucess");
  } catch (e) {
    print("Exception - gloabl.dart - saveCurrentUser():" + e.toString());
  }
}

///  =================================================================
/// ********************** LOGOUT ********************
/// ==================================================================
logoutUser(BuildContext context) async {
  await apiHelper.logoutapi();
  sp = await SharedPreferences.getInstance();
  sp!.remove("currentUser");
  log("current user logout:- ${sp!.getString('currentUserId')}");
  currentUserId = null;
  splashController.currentUser = null;
  user = CurrentUser();
  await Future.delayed(const Duration(seconds: 3)).then(
    (value) => Get.offAll(() => const LoginScreen()),
  );
}

//get current user
Future<int> getCurrentUser() async {
  sp = await SharedPreferences.getInstance();
  CurrentUser userData =
      CurrentUser.fromJson(json.decode(sp!.getString("currentUser") ?? ""));
  int id = userData.id ?? 0;
  return id;
}

//Get data of current user id
getCurrentUserId() async {
  sp = await SharedPreferences.getInstance();
  CurrentUser userData =
      CurrentUser.fromJson(json.decode(sp!.getString("currentUser") ?? ""));
  currentUserId = userData.id;
}

//check login
Future<bool> isLogin() async {
  sp = await SharedPreferences.getInstance();
  if (sp!.getString("token") == null && sp!.getInt("currentUserId") == null) {
    Get.to(() => const LoginScreen());
    return false;
  } else {
    return true;
  }
}

//Device Details
String appId2 = Platform.isAndroid ? "2" : "2";
String reviewAppId = "2";
//-------------------------------------------Functions--------------------------------------

///  =================================================================
/// ********************** API HEADER ********************
/// ==================================================================
Future<Map<String, String>> getApiHeaders(bool authorizationRequired,
    {bool? ismultipart = false}) async {
  try {
    // ignore: prefer_collection_literals
    Map<String, String> apiHeader = Map<String, String>();
    Map<String, dynamic> deviceData = {};

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceData = {
        "deviceModel": androidInfo.model,
        "deviceManufacturer": androidInfo.manufacturer,
        "deviceId": androidInfo.id,
        "fcmToken": await FirebaseMessaging.instance.getToken(),
        "deviceLocation": null,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceData = {
        "deviceModel": iosInfo.model,
        "deviceManufacturer": "Apple",
        "deviceId": iosInfo.identifierForVendor,
        "fcmToken": await FirebaseMessaging.instance.getToken(),
        "deviceLocation": null,
      };
    }

    if (authorizationRequired) {
      sp = await SharedPreferences.getInstance();
      if (sp!.getString("currentUser") != null) {
        String? tokenType;
        String? token;
        if (sp!.getString('currentUser') != null) {
          CurrentUser userData = CurrentUser.fromJson(
              json.decode(sp!.getString("currentUser") ?? ""));
          tokenType = userData.tokenType;
          token = userData.token;
        }
        print('authentication token :- $token');
        apiHeader.addAll({"Authorization": " $tokenType $token"});
      } else {
        apiHeader.addAll({"Authorization": appId});
      }
    } else {
      apiHeader.addAll({"Authorization": appId});
    }

    // Add Content-Type header for multipart/form-data if needed
    log('hismultipart $ismultipart ');

    if (ismultipart == true) {
      log('header multipart true yeah ');
      apiHeader.addAll({"Content-Type": "multipart/form-data"});
    } else {
      apiHeader.addAll({"Content-Type": "application/json"});
    }
    apiHeader.addAll({"DeviceInfo": json.encode(deviceData)});
    log('api header-> $apiHeader');

    return apiHeader;
  } catch (err) {
    print("Exception: global.dart : getApiHeaders" + err.toString());
    return {};
  }
}

///  =================================================================
/// ********************** SHARE DYNAMIC LINK ********************
/// ==================================================================
// createAndShareLinkForDailyHorscope(ScreenshotController sc) async {
//   showOnlyLoaderDialog();
//   String? appShareLink;
//   String applink;

//   try {
//     final DynamicLinkParameters parameters = DynamicLinkParameters(
//       uriPrefix: 'https://astrowaydiploy.page.link',
//       link: Uri.parse(
//           "https://astrowaydiploy.page.link/userProfile?screen=dailyHorscope"),
//       androidParameters: const AndroidParameters(
//         packageName: 'com.jyotishi.astro',
//         minimumVersion: 1,
//       ),
//     );
//     Uri url;
//     final ShortDynamicLink shortLink = await dynamicLinks
//         .buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);
//     url = shortLink.shortUrl;
//     debugPrint('url $url');
//     appShareLink = url.toString();
//     debugPrint('appShareLink $appShareLink');

//     applink = appShareLink;
//   } on Exception catch (e) {
//     debugPrint('exception dynamic link $e');
//   }
//   hideLoader();

//   final directory = (await getApplicationDocumentsDirectory()).path;

//   sc
//       .capture(delay: const Duration(milliseconds: 10))
//       .then((Uint8List? image) async {
//     debugPrint('${image != null}');
//     if (image != null) {
//       try {
//         String fileName = DateTime.now().microsecondsSinceEpoch.toString();
//         final imagePath = await File('$directory/$fileName.png').create();
//         if (imagePath != null) {
//           final temp = await getExternalStorageDirectory();
//           final path = '${temp!.path}/$fileName.jpg';
//           File(path).writeAsBytesSync(image);
//           await FlutterShare.shareFile(
//                   filePath: path,
//                   title: getSystemFlagValue(systemFlagNameList.appName),
//                   text:
//                       "Check out your free daily horoscope on ${getSystemFlagValue(systemFlagNameList.appName)} & plan your day batter $appShareLink")
//               .then((value) {})
//               .catchError((e) {
//             print(e);
//           });
//         }
//       } catch (e) {
//         debugPrint('catch error $e');
//       }
//     } else {
//       debugPrint('inside else bloc image');
//     }
//   }).catchError((onError) {
//     debugPrint(onError.toString());
//   });
// }

// showToast({required String message}) async {
//   return Fluttertoast.showToast(
//     msg: message,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     timeInSecForIosWeb: 1,
//     backgroundColor: Colors.black.withOpacity(0.8),
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
// }


showToast({required String message}) async {
  return EasyLoading.showToast(message);
}

sendTokenToApi(
    int id, String agoraLiveChannelName, String agoraLiveToken, String s) {
  liveAstrologerController.sendLiveToken(
      id, agoraLiveChannelName, agoraLiveToken, "");
}

Future<Widget> showHtml(
    {required String html, Map<String, Style>? style}) async {
  try {
    return Html(
      data: html,
      style: style ?? {},
    );
  } catch (e) {
    return Html(
      data: html,
      style: style ?? {},
    );
  }
}

void showOnlyLoaderDialog() {
  Future.delayed(Duration.zero, () {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  });
}

void hideLoader() {
  Get.back();
}

String url = "https://1.envato.market/da0XDM";
String diployurl = "https://diploy.in";


//
// warningDialog(BuildContext context) {
//   // BuildContext context = Get.context!;
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Container(
//         margin: EdgeInsets.symmetric(horizontal: 2.w),
//         child: AlertDialog(
//           surfaceTintColor: Colors.white,
//           insetPadding: EdgeInsets.symmetric(horizontal: 1.w),
//           backgroundColor: Colors.white,
//           contentPadding: EdgeInsets.zero,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           title: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(1.w),
//                 child: Center(
//                   child: Text(
//                     "Notice: ",
//                     style: Get.theme.textTheme.displayLarge!.copyWith(
//                       color: Colors.black,
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w600,
//                       fontStyle: FontStyle.normal,
//                     ),
//                   ).tr(),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(1.w),
//                 child: Center(
//                   child: RichText(
//                     text: TextSpan(
//                       text:
//                           'Beware of scammer & nulled codes. Some websites are using our name & assets to mislead like astroway.in & more (Buy the astroway source code from codecanyon & ',
//                       style: const TextStyle(color: Colors.black),
//                       children: <TextSpan>[
//                         TextSpan(
//                           text: 'diploy.in ',
//                           style: const TextStyle(
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () async {
//                               if (await canLaunch(diployurl)) {
//                                 await launch(diployurl);
//                               } else {
//                                 throw 'Could not launch $diployurl';
//                               }
//                             },
//                         ),
//                         const TextSpan(text: ' at \$96 only: '),
//                         TextSpan(
//                           text: url,
//                           style: const TextStyle(
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () async {
//                               if (await canLaunch(url)) {
//                                 await launch(url);
//                               } else {
//                                 throw 'Could not launch $url';
//                               }
//                             },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Get.back();
//                       // Get.back();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5.w),
//                         side: BorderSide(color: Colors.pink.shade200),
//                       ),
//                       shadowColor: Colors.transparent,
//                     ),
//                     child: Text(
//                       'OK',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.normal,
//                         color: Colors.black,
//                       ),
//                     ).tr(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actionsAlignment: MainAxisAlignment.spaceBetween,
//           actionsPadding:
//               const EdgeInsets.only(bottom: 15, left: 15, right: 15),
//         ),
//       );
//     },
//   );
// }

///  =================================================================
/// ********************** NETWORK BODY ********************
/// ==================================================================
//For Network controller
Future<bool> checkBody() async {
  bool result;
  try {
    await networkController.initConnectivity();
    if (networkController.connectionStatus.value != 0) {
      result = true;
    } else {
      ever(networkController.connectionStatus, (status) {
        debugPrint('status init $status');
        if (status > 0) {
          result = true;
        } else {
          Get.snackbar(
            "Warning",
            "No Internet Connection",
            snackPosition: SnackPosition.BOTTOM,
            messageText: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.signal_wifi_off,
                  color: Colors.white,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                    ),
                    child: const Text(
                      "No Internet Available",
                      textAlign: TextAlign.start,
                    ).tr(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (networkController.connectionStatus.value != 0) {
                      Get.back();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white),
                    height: 30,
                    width: 55,
                    child: Center(
                      child: Text(
                        "Retry",
                        style: TextStyle(
                            color: Theme.of(Get.context!).primaryColor),
                      ).tr(),
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(days: 1),
            backgroundColor: Theme.of(Get.context!).primaryColor,
            colorText: Colors.white,
          );
        }
      });

      result = false;
    }

    return result;
  } catch (e) {
    print("Exception - checkBodyController - checkBody():" + e.toString());
    return false;
  }
}

printException(String className, String functionName, dynamic err) {
  print("Exception: $className: - $functionName(): $err");
}

Future exitAppDialog() async {
  try {
    showCupertinoDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return Theme(
            data: ThemeData(dialogBackgroundColor: Colors.white),
            child: CupertinoAlertDialog(
              title: const Text(
                'Exit App',
              ).tr(),
              content: Text(
                'Are you sure you want to exit app?',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ).tr(),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ).tr(),
                  onPressed: () {
                    // Dismiss the dialog but don't
                    // dismiss the swiped item
                    return Navigator.of(context).pop(false);
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    'Exit',
                  ).tr(),
                  onPressed: () async {
                    exit(0);
                  },
                ),
              ],
            ),
          );
        });
  } catch (e) {
    print('Exception - gloabl.dart - exitAppDialog(): ${e.toString()}');
  }
}
