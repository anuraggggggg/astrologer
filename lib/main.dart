// ignore_for_file: must_be_immutable, avoid_print, unnecessary_nullable_for_final_variable_declarations, unused_element, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:astrowaypartner/controllers/Provider/loginProvider.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/fastApi/sessionController.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/live_astrologer_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/report_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/timer_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/callAvailability_controller.dart';
import 'package:astrowaypartner/controllers/chatAvailability_controller.dart';
import 'package:astrowaypartner/controllers/networkController.dart';
import 'package:astrowaypartner/controllers/splashController.dart';
import 'package:astrowaypartner/firebase_options.dart';
import 'package:astrowaypartner/methodchannel/notificationMethod.dart';
import 'package:astrowaypartner/services/apiHelper.dart';
import 'package:astrowaypartner/theme/nativeTheme.dart';
import 'package:astrowaypartner/theme/themeService.dart';
import 'package:astrowaypartner/utils/CallUtils.dart';
import 'package:astrowaypartner/utils/binding/networkBinding.dart';
import 'package:astrowaypartner/views/splash/splashScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/HomeController/call_controller.dart';
import 'controllers/following_controller.dart';
import 'controllers/life_cycle_controller.dart';
import 'notificationHandler.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'utils/FallbackLocalizationDelegate.dart';
//astrowaydiploy astrologer

import 'package:flutter_easyloading/flutter_easyloading.dart'; // <--- ADD THIS IMPORT

final localNotifications = FlutterLocalNotificationsPlugin();
//my

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final liveAstrologerController = Get.put(LiveAstrologerController());
  final walletController = Get.put(WalletController());
  final chatController = Get.put(ChatController());
  final callController = Get.put(CallController());
  final timerController = Get.put(TimerController());
  final reportController = Get.put(ReportController());
  Get.put(NetworkController());
  Get.put(FollowingController());
  Get.put(CallAvailabilityController());
  Get.put(ChatAvailabilityController());
  Get.put(HomeController());
  Get.put(SignupController());
  Get.put(HomeCheckController());
  log('firebase background msg called..');
  log('notification message -> ${message.data}');

  global.sp = await SharedPreferences.getInstance();
  if (global.sp != null && global.sp!.getString("currentUser") != null) {
    if (message.data["title"] == "For Live Streaming Chat") {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        await localNotifications.cancelAll();
      });
      log('notification sessionType -> ${message.data["sessionType"]}');
      String sessionType = message.data["sessionType"];
      if (sessionType == "start") {
        String? liveChatUserName2 = message.data['liveChatSUserName'];
        if (liveChatUserName2 != null) {
          liveAstrologerController.liveChatUserName = liveChatUserName2;
          liveAstrologerController.update();
        }
        String chatId = message.data["chatId"];
        liveAstrologerController.isUserJoinAsChat = true;
        liveAstrologerController.update();
        liveAstrologerController.chatId = chatId;
        int waitListId = int.parse(message.data["waitListId"].toString());
        String time = liveAstrologerController.waitList
            .where((element) => element.id == waitListId)
            .first
            .time;
        liveAstrologerController.endTime =
            DateTime.now().millisecondsSinceEpoch +
                1000 * int.parse(time.toString());
        liveAstrologerController.update();
      } else {
        if (liveAstrologerController.isOpenPersonalChatDialog) {
          Get.back(); //if chat dialog opended
          liveAstrologerController.isOpenPersonalChatDialog = false;
        }
        liveAstrologerController.isUserJoinAsChat = false;
        liveAstrologerController.chatId = null;
        liveAstrologerController.update();
      }
    } else if (message.data["title"] ==
        "For timer and session start for live") {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        await localNotifications.cancelAll();
      });
      int waitListId = int.parse(message.data["waitListId"].toString());
      liveAstrologerController.joinedUserName = message.data["name"] ?? "User";
      liveAstrologerController.joinedUserProfile =
          message.data["profile"] ?? "";
      String time = liveAstrologerController.waitList
          .where((element) => element.id == waitListId)
          .first
          .time;
      liveAstrologerController.endTime = DateTime.now().millisecondsSinceEpoch +
          1000 * int.parse(time.toString());
      liveAstrologerController.update();
    } else if (message.data["title"] == "Start simple chat timer") {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        await localNotifications.cancelAll();
      });
      log('started time for chat joined now');
      callController.newIsStartTimer = true;
      callController.update();
      log('time set to true 2');

      timerController.endTime =
          DateTime.now().millisecondsSinceEpoch + 1000 * 300;
      timerController.update();
    } else if (message.data["title"] == "End chat from customer") {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        await localNotifications.cancelAll();
      });

      if (chatController.isInChatScreen) {
        chatController.isInChatScreen = false;
        chatController.update();
        Get.back();
      }
    } else if (message.data["title"] == "Reject call request from astrologer") {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        await localNotifications.cancelAll();
      });

      debugPrint('user Rejected call request:-');
      callController.isRejectCall = true;
      callController.update();
    } else {
      try {
        if (message.data.isNotEmpty) {
          var messageData = json.decode((message.data['body']));
          debugPrint('notification body background ->  $messageData');
          if (messageData['notificationType'] != null) {
            switch (messageData['notificationType']) {
              case 7:
                // get wallet api call
                debugPrint('call in background');

                await walletController.getAmountList(isLoading: 0);
                break;

              case 8:
                // get Chat api call

                await chatController.getChatList(true, isLoading: 0);
                chatController.update();

                debugPrint('chat resp -> $messageData');
                NotificationHandler()
                    .foregroundNotificatioCustomAuddio(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
                break;

              case 2:
                // in background
                debugPrint('calling from :- 2');
                await callController.getCallList(true, isLoading: 0);
                callController.update();
                // NotificationHandler()
                //     .foregroundNotificatioCustomAuddio(message);
                // await FirebaseMessaging.instance
                //     .setForegroundNotificationPresentationOptions(
                //         alert: true, badge: true, sound: true);
                CallUtils.showIncomingCall(messageData);
                initforbackground();

                // audio call
                break;

              case 9:
                reportController.reportList.clear();
                reportController.update();
                await reportController.getReportList(false);
                reportController.update();
                NotificationHandler().foregroundNotification(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
                break;

              case 10:
              case 11:
              case 12:
                debugPrint('calling type :- 10, 11, 12');

                liveAstrologerController.isUserJoinWaitList = true;
                liveAstrologerController.update();
                NotificationHandler().foregroundNotification(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
                break;

              default:
                log('Unknown notification type');
                NotificationHandler().foregroundNotification(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
            }
          }
        }
      } catch (e) {
        log("Exception in _firebaseMessagingBackgroundHandler else $e");
      }
    }
  } else {
    log("else Current_user not found in bg message");
  }
}

void initforbackground() async {
  final prefs = await SharedPreferences.getInstance();

  debugPrint('inside initforbackground');
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    debugPrint('inside initforbackground $event');

    if (event == null) {
      await prefs.setBool('is_accepted', false);
      await prefs.setBool('is_rejected', false);
      return;
    }

    switch (event.event) {
      case Event.actionCallStart:
        // Handle call accept action
        print('actionCallStart call incoming');
        break;
      case Event.actionCallAccept:
        // Handle call decline action
        print('actionCallAccept call incoming');
        await prefs.setBool('is_accepted', true);
        String extraDataJson = jsonEncode(event.body['extra']);
        print('actionCallAccept extraDataJson $extraDataJson');
        await prefs.setString('is_accepted_data', extraDataJson);

        break;
      case Event.actionCallDecline:
        print('call rejected');
        final callController = Get.put(CallController());
        // Handle call end action
        callController.rejectCallRequest(event.body['extra']['callId']);
        callController.update();

        await prefs.setBool('is_rejected', true);
        await prefs.setBool('is_accepted', false);
        await prefs.setString('is_accepted_data', '');

        break;
      case Event.actionCallCallback:
        print('actionCallCallback initforbackground call incoming click');

        break;

      case Event.actionCallTimeout:
        print('actionCallTimeout initforbackground call incoming click');
        //clear background data when missed call so whenever app open agian then this data
        //not open direactly callscreens
        await prefs.setBool('is_accepted', false);
        await prefs.setBool('is_rejected', false);
        await prefs.setString('is_accepted_data', '');
        break;

      default:
        break;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GetStorage.init();
  Get.put(SessionController(), permanent: true);

  await Firebase.initializeApp(
      name: 'Astroway', options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('bn', 'IN'),
        Locale('es', 'ES'),
        Locale('gu', 'IN'),
        Locale('kn', 'IN'),
        Locale('ml', 'IN'),
        Locale('mr', 'IN'), //marathi
        Locale('sa', 'IN'),
        Locale('ta', 'IN'),
        Locale('te', 'IN')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('en', 'US'),
      child: MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(FastApiServices())),
      ], child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic analytics;
  final apiHelper = APIHelper();

  dynamic observer;
  final liveAstrologerController = Get.put(LiveAstrologerController());
  final walletController = Get.put(WalletController());
  final chatController = Get.put(ChatController());
  final callController = Get.put(CallController());
  final timerController = Get.put(TimerController());
  final reportController = Get.put(ReportController());
  final networkController = Get.put(NetworkController());
  final followingController = Get.put(FollowingController());
  final callavailibilty = Get.put(CallAvailabilityController());
  final chatavailibilty = Get.put(ChatAvailabilityController());
  final signupcontroller = Get.put(SignupController());

  final homecontroller = Get.put(HomeController());
  final splashController = Get.put(SplashController());
  final hhomecheckcontrlller = Get.put(HomeCheckController());

  String dataResponse = 'Unknown';

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data["title"] == "For Live Streaming Chat") {
        String sessionType = message.data["sessionType"];
        if (sessionType == "start") {
          String? liveChatUserName2 = message.data['liveChatSUserName'];
          if (liveChatUserName2 != null) {
            liveAstrologerController.liveChatUserName = liveChatUserName2;
            liveAstrologerController.update();
          }
          String chatId = message.data["chatId"];
          liveAstrologerController.isUserJoinAsChat = true;
          liveAstrologerController.update();
          liveAstrologerController.chatId = chatId;
          int waitListId = int.parse(message.data["waitListId"].toString());
          String time = liveAstrologerController.waitList
              .where((element) => element.id == waitListId)
              .first
              .time;
          liveAstrologerController.endTime =
              DateTime.now().millisecondsSinceEpoch +
                  1000 * int.parse(time.toString());
          liveAstrologerController.update();
        } else {
          if (liveAstrologerController.isOpenPersonalChatDialog) {
            Get.back(); //if chat dialog opended
            liveAstrologerController.isOpenPersonalChatDialog = false;
          }
          liveAstrologerController.isUserJoinAsChat = false;
          liveAstrologerController.chatId = null;
          liveAstrologerController.update();
        }
      } else if (message.data["title"] ==
          "For timer and session start for live") {
        int waitListId = int.parse(message.data["waitListId"].toString());
        liveAstrologerController.joinedUserName =
            message.data["name"] ?? "User";
        liveAstrologerController.joinedUserProfile =
            message.data["profile"] ?? "";
        String time = liveAstrologerController.waitList
            .where((element) => element.id == waitListId)
            .first
            .time;
        liveAstrologerController.endTime =
            DateTime.now().millisecondsSinceEpoch +
                1000 * int.parse(time.toString());
        liveAstrologerController.update();
      } else if (message.data["title"] == "Start simple chat timer") {
        log('time set to true');

        callController.newIsStartTimer = true;
        callController.update();

        timerController.endTime =
            DateTime.now().millisecondsSinceEpoch + 1000 * 300;
        timerController.update();
      } else if (message.data["title"] == "End chat from customer") {
        log('isInChatScreen ${chatController.isInChatScreen}');

        if (chatController.isInChatScreen) {
          chatController.updateChatScreen(false);
          apiHelper.setAstrologerOnOffBusyline("Online");
          chatController.update();

          //  Get.back();
        } else {
          log('do nothing chat dismiss');
        }
      } else if (message.data["title"] ==
          "Reject call request from astrologer") {
        print('user Rejected call request:-');
        callController.isRejectCall = true;
        callController.update();
        callController.rejectDialog();
      } else {
        try {
          if (message.data.isNotEmpty) {
            var messageData = json.decode((message.data['body']));
            debugPrint('set msg type foreground');

            log('noti body $messageData');
            global.userID = messageData['id'];
            print('id of user ${global.userID}');
            if (messageData['notificationType'] != null) {
              switch (messageData['notificationType']) {
                case 7:
                  // get wallet api call
                  await walletController.getAmountList(isLoading: 0);

                  NotificationHandler().foregroundNotification(message);
                  await FirebaseMessaging.instance
                      .setForegroundNotificationPresentationOptions(
                          alert: true, badge: true, sound: false);
                  break;

                case 8:
                  log('inside foreground noti type 8');
                  // chatController.startRingTone();
                  await chatController.getChatList(true, isLoading: 0);
                  chatController.update();

                  NotificationHandler()
                      .foregroundNotificatioCustomAuddio(message);
                  await FirebaseMessaging.instance
                      .setForegroundNotificationPresentationOptions(
                          alert: true, badge: true, sound: true);

                  break;

                case 2:
                  global.userID = messageData['id'];
                  print('new id is ${global.userID}');
                  await callController.getCallList(true);
                  callController.update();
                  CallUtils.showIncomingCall(messageData);

                  break;

                case 9:
                  reportController.reportList.clear();
                  reportController.update();
                  await reportController.getReportList(false);
                  NotificationHandler().foregroundNotification(message);
                  await FirebaseMessaging.instance
                      .setForegroundNotificationPresentationOptions(
                          alert: true, badge: true, sound: true);
                  break;

                case 10:
                case 11:
                case 12:
                  liveAstrologerController.isUserJoinWaitList = true;
                  liveAstrologerController.update();
                  NotificationHandler()
                      .foregroundNotificatioCustomAuddio(message);
                  await FirebaseMessaging.instance
                      .setForegroundNotificationPresentationOptions(
                          alert: true, badge: true, sound: true);
                  break;

                default:
                  NotificationHandler().foregroundNotification(message);
                  await FirebaseMessaging.instance
                      .setForegroundNotificationPresentationOptions(
                          alert: true, badge: true, sound: true);
              }
            } else {
              //FOR ADMIN NOTIFICATION
              NotificationHandler().foregroundNotification(message);
              debugPrint('FOR ADMIN NOTIFICATION ELSE BLOCK');
            }
          } else {
            debugPrint('els data null');
          }
        } catch (e) {
          debugPrint('els data null exceptio is $e');
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationHandler().onSelectNotification(json.encode(message.data));
    });

    getfcm();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (s) {
      return Sizer(
        builder: (context, orientation, deviceType) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          enableLog: true,
          theme: Themes.light,
          darkTheme: Themes.dark,
          themeMode: ThemeService().theme,
          locale: context.locale,
          localizationsDelegates: [
            ...context.localizationDelegates,
            FallbackLocalizationDelegate()
          ],
          supportedLocales: context.supportedLocales,
          initialBinding: NetworkBinding(),
          title: global.appName,
          initialRoute: "SplashScreen",
          builder: EasyLoading.init(), // <--- ADD THIS LINE
          home: SplashScreen(
            a: analytics,
            o: observer,
          ),
        ),
      );
    });
  }

  void getfcm() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN $fcmToken');
    if (Platform.isAndroid) {
      NotificationMethodChannel().createNewChannel(); //init notif customsound
    }
    initializeCallKitEventHandlers();
  }

  void initializeCallKitEventHandlers() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallStart:
          // Handle call accept action
          log('actionCallStart call incoming');
          break;
        case Event.actionCallAccept:
          // Handle call decline action
          final prefs = await SharedPreferences.getInstance();

          print('actionCallAccept call incoming');
          await prefs.setBool('is_accepted', false);
          await prefs.setString('is_accepted_data', '');
          callAccept(event);
          break;
        case Event.actionCallDecline:
          // Handle call end action
          final prefs = await SharedPreferences.getInstance();

          print('actionCall declined');
          await prefs.setBool('is_accepted', false);
          await prefs.setString('is_accepted_data', '');

          if (event.body['extra']["notificationType"] == 2) {
            if (event.body['extra']['call_type'] == 10 ||
                event.body['extra']['call_type'] == 11) {
              callController.rejectCallRequest(event.body['extra']['callId']);
              callController.update();
              log('call rejected main.dart');
            }
          }
        case Event.actionCallCallback:
          callAccept(event);
          break;
        default:
          break;
      }
    });
  }

  void callAccept(CallEvent event) async {
    log('extra call notificationType ${event.body['extra']['notificationType']}');
    log('extra call callId ${event.body['extra']['callId']}');
    log('extra call profile ${event.body['extra']['profile']}');
    log('extra call name ${event.body['extra']['name']}');
    log('extra call call_duration ${event.body['extra']['call_duration']}');
    log('extra call fcmToken ${event.body['extra']['fcmToken']}');
    log('extra call CustomerID ${event.body['extra']['id']}');

    if (event.body['extra']["notificationType"] == 2) {
      callController.callList.clear();
      callController.update();
      await callController.getCallList(false);
      callController.update();

      if (event.body['extra']['call_type'] == 10) {
        callController.acceptCallRequest(
          event.body['extra']['callId'],
          event.body['extra']['profile'],
          event.body['extra']['name'],
          event.body['extra']['id'],
          event.body['extra']['fcmToken'],
          event.body['extra']['call_duration'].toString(),
        );
      } else if (event.body['extra']['call_type'] == 11) {
        callController.acceptVideoCallRequest(
          event.body['extra']['callId'],
          event.body['extra']['profile'],
          event.body['extra']['name'],
          event.body['extra']['id'],
          event.body['extra']['fcmToken'],
          event.body['extra']['call_duration'].toString(),
        );
      }
    } else {
      //may be chat
    }
  }
}
