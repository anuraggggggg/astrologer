// ignore_for_file: must_be_immutable, avoid_print, unnecessary_nullable_for_final_variable_declarations, unused_element, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:astrowaypartner/controllers/Provider/loginProvider.dart';
import 'package:astrowaypartner/fastApi/fastApiServices.dart';
import 'package:astrowaypartner/fastApi/sessionController.dart';
import 'package:astrowaypartner/views/HomeScreen/chat/chat_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/newAudioPage.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/videoCallPage.dart';
import 'package:astrowaypartner/views/chat/chat_screen.dart';
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

import 'package:flutter_easyloading/flutter_easyloading.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION CHANNEL IDs
// ─────────────────────────────────────────────────────────────────────────────

const String kCallChannelId = 'incoming_call_channel_v2';
const String kGiftChannelId = 'gift_notification_channel'; // NEW
const String kChatChannelId = 'chat_notification_channel';

final localNotifications = FlutterLocalNotificationsPlugin();

// ─────────────────────────────────────────────────────────────────────────────
// MAIN DEBUG LOGGER
// ─────────────────────────────────────────────────────────────────────────────

class _ML {
  static const _tag = '🚀 [Main]';
  static void fcm(String msg) => log('$_tag 📩 FCM     | $msg');
  static void bg(String msg) => log('$_tag 🌙 BG      | $msg');
  static void noti(String msg) => log('$_tag 🔔 NOTI    | $msg');
  static void call(String msg) => log('$_tag 📞 CALL    | $msg');
  static void gift(String msg) => log('$_tag 🎁 GIFT    | $msg');
  static void error(String msg, [dynamic e]) {
    log('$_tag ❌ ERROR   | $msg');
    if (e != null) log('$_tag            | $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION ACTION HANDLER (background tap actions)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
void notificationActionHandler(NotificationResponse response) async {
  _ML.noti('notificationActionHandler called actionId=${response.actionId}');

  if (response.payload == null) {
    _ML.noti('Payload is null — skipping');
    return;
  }

  final data = jsonDecode(response.payload!);
  _ML.noti('Decoded payload: $data');

  final prefs = await SharedPreferences.getInstance();
  final callController = Get.put(CallController());

  if (response.actionId == 'ACCEPT_CALL') {
    _ML.call('ACCEPT_CALL tapped');
    await callController.acceptCallRequest(
      data['callId'],
      data['profile'],
      data['name'],
      data['id'],
      data['fcmToken'],
      data['call_duration'].toString(),
    );
    await prefs.setString('PENDING_CALL', response.payload!);
    _ML.call('PENDING_CALL saved to prefs');
  }

  if (response.actionId == 'REJECT_CALL') {
    _ML.call('REJECT_CALL tapped');
    await callController.rejectCallRequest(data['callId']);
    await prefs.remove('PENDING_CALL');
    _ML.call('PENDING_CALL cleared from prefs');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BACKGROUND MESSAGE HANDLER
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  _ML.bg('handleBackgroundMessage fired');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final walletController = Get.put(WalletController());
  final chatController = Get.put(ChatController());
  final callController = Get.put(CallController());
  final reportController = Get.put(ReportController());

  global.sp = await SharedPreferences.getInstance();
  if (global.sp == null || global.sp!.getString("currentUser") == null) {
    _ML.bg('No logged-in user — ignoring background notification');
    return;
  }

  _ML.bg('Raw FCM data: ${message.data}');

  try {
    if (message.data.isEmpty) {
      _ML.bg('message.data is empty — skipping');
      return;
    }

    // ── Parse payload ─────────────────────────────────────────────────────
    Map<String, dynamic> messageData;
    if (message.data.containsKey('body') && message.data['body'] != null) {
      messageData = jsonDecode(message.data['body']);
      _ML.bg('Parsed from body field');
    } else {
      messageData = message.data;
      _ML.bg('Used message.data directly');
    }
    _ML.bg('Parsed messageData: $messageData');

    // ── Resolve notification type ─────────────────────────────────────────
    int? notificationType = _resolveNotificationType(messageData);
    _ML.bg('Resolved notificationType=$notificationType');

    if (notificationType == null) {
      _ML.bg('No notificationType found — ignoring');
      return;
    }

    // ── Dispatch ──────────────────────────────────────────────────────────
    switch (notificationType) {
      case 7:
        _ML.bg('Type 7 → Wallet update');
        await walletController.getAmountList(isLoading: 0);
        break;

      case 8:
        _ML.bg('Type 8 → Chat list refresh');
        await chatController.getChatList(true, isLoading: 0);
        break;

      case 10: // AUDIO CALL
      case 11: // VIDEO CALL
        _ML.call('Type $notificationType → Incoming call notification');
        await _showIncomingCallNotification(messageData);
        break;

      case 12:
        _ML.bg('Type 12 → Chat notification (no action)');
        break;

      // ── GIFT NOTIFICATION (background) ────────────────────────────────
      // Add type 13 (or whatever your backend uses) for gifts
      case 13:
        _ML.gift('Type 13 → Gift received in background');
        await _showGiftNotification(messageData);
        break;

      case 9:
        _ML.bg('Type 9 → Report update');
        reportController.reportList.clear();
        await reportController.getReportList(false);
        break;

      default:
        _ML.bg('Unknown notificationType=$notificationType — ignored');
    }
  } catch (e, s) {
    _ML.error('handleBackgroundMessage exception', e);
    log('❌ STACK: $s');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS: Notification type resolution
// ─────────────────────────────────────────────────────────────────────────────

int? _resolveNotificationType(Map<String, dynamic> data) {
  if (data['call_type'] == 'Audio') return 10;
  if (data['call_type'] == 'Video') return 11;
  if (data['call_type'] == 'Chat') return 12;

  // Support explicit gift type from backend
  if (data['type'] == 'gift' || data['notificationType'] == 13) return 13;

  return data['notificationType'] ?? data['type'];
}

// ─────────────────────────────────────────────────────────────────────────────
// SHOW INCOMING CALL NOTIFICATION
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showIncomingCallNotification(
    Map<String, dynamic> messageData) async {
  _ML.call('Showing incoming call notification for ${messageData['name']}');

  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "${messageData['name'] ?? 'User'} is calling…",
    "Tap to respond",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        kCallChannelId,
        'Incoming Calls',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        playSound: true,
        actions: [
          AndroidNotificationAction('ACCEPT_CALL', 'Accept',
              showsUserInterface: true),
          AndroidNotificationAction('REJECT_CALL', 'Reject',
              showsUserInterface: true),
        ],
      ),
    ),
    payload: jsonEncode(messageData),
  );

  _ML.call('Incoming call notification shown ✅');
}

// ─────────────────────────────────────────────────────────────────────────────
// SHOW GIFT NOTIFICATION — FCM-based, for background/terminated state
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showGiftNotification(Map<String, dynamic> data) async {
  final senderName = data['name'] ?? data['user'] ?? 'A viewer';
  final giftName = data['gift_name'] ?? 'a gift';
  final giftIcon = data['gift_icon'] ?? '🎁';
  final giftPrice = data['gift_price']?.toString() ?? '0';

  _ML.gift(
      'Showing gift notification: sender=$senderName gift=$giftName price=₹$giftPrice');

  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    '$giftIcon Gift from $senderName!',
    '$senderName sent you $giftName worth ₹$giftPrice',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        kGiftChannelId,
        'Gift Notifications',
        channelDescription: 'Notifications for gifts received during live',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        // Gift-specific icon — use your own drawable name
        // largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_gift'),
      ),
    ),
    payload: jsonEncode(data),
  );

  _ML.gift('Gift notification shown ✅');
}

// ─────────────────────────────────────────────────────────────────────────────
// CALL KIT BACKGROUND INIT
// ─────────────────────────────────────────────────────────────────────────────

void initforbackground() async {
  _ML.call('initforbackground called');
  final prefs = await SharedPreferences.getInstance();

  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    _ML.call('CallKit BG event: $event');

    if (event == null) {
      await prefs.setBool('is_accepted', false);
      await prefs.setBool('is_rejected', false);
      return;
    }

    switch (event.event) {
      case Event.actionCallStart:
        _ML.call('actionCallStart');
        break;

      case Event.actionCallAccept:
        _ML.call('actionCallAccept');
        await prefs.setBool('is_accepted', true);
        final extraJson = jsonEncode(event.body['extra']);
        _ML.call('Saving accepted data: $extraJson');
        await prefs.setString('is_accepted_data', extraJson);
        break;

      case Event.actionCallDecline:
        _ML.call('actionCallDecline');
        final callController = Get.put(CallController());
        callController.rejectCallRequest(event.body['extra']['callId']);
        callController.update();
        await prefs.setBool('is_rejected', true);
        await prefs.setBool('is_accepted', false);
        await prefs.setString('is_accepted_data', '');
        break;

      case Event.actionCallCallback:
        _ML.call('actionCallCallback');
        break;

      case Event.actionCallTimeout:
        _ML.call('actionCallTimeout — clearing prefs');
        await prefs.setBool('is_accepted', false);
        await prefs.setBool('is_rejected', false);
        await prefs.setString('is_accepted_data', '');
        break;

      default:
        _ML.call('Unknown CallKit event: ${event.event}');
    }
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GetStorage.init();

  _ML.fcm('App starting up');

  final sessionController = Get.put(SessionController(), permanent: true);
  await sessionController.loadSession();

  await Firebase.initializeApp(
    name: 'Astroway',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  _ML.fcm('Firebase initialized ✅');

  // ── Local Notification Setup ────────────────────────────────────────────
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await localNotifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationActionHandler,
  );

  _ML.noti('FlutterLocalNotificationsPlugin initialized ✅');

  // ── Create notification channels ────────────────────────────────────────
  if (Platform.isAndroid) {
    final androidPlugin =
        localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Call channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        kCallChannelId,
        'Incoming Calls',
        description: 'Notifications for incoming audio/video calls',
        importance: Importance.max,
        playSound: true,
      ),
    );

    // Gift channel — NEW
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        kGiftChannelId,
        'Gift Notifications',
        description: 'Notifications for gifts received during live streams',
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Chat channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        kChatChannelId,
        'Chat Notifications',
        description: 'Notifications for incoming chat messages',
        importance: Importance.high,
      ),
    );

    _ML.noti('Android notification channels created ✅');
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  _ML.fcm('FCM permissions requested ✅');

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
        Locale('mr', 'IN'),
        Locale('sa', 'IN'),
        Locale('ta', 'IN'),
        Locale('te', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => AuthProvider(FastApiServices())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MY APP
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    _ML.fcm('MyApp initState — registering FCM listeners');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _ML.fcm('onMessage (foreground) received');
      _ML.fcm('message.data: ${message.data}');

      _showAndroidNotification(message);

      // ── Special title-based messages ──────────────────────────────────
      if (message.data["title"] == "For Live Streaming Chat") {
        _ML.fcm('Handling: For Live Streaming Chat');
        _handleLiveStreamingChat(message);
        return;
      }

      if (message.data["title"] == "For timer and session start for live") {
        _ML.fcm('Handling: For timer and session start for live');
        _handleTimerAndSessionStart(message);
        return;
      }

      if (message.data["title"] == "Start simple chat timer") {
        _ML.fcm('Handling: Start simple chat timer');
        log('time set to true');
        callController.newIsStartTimer = true;
        callController.update();
        timerController.endTime =
            DateTime.now().millisecondsSinceEpoch + 1000 * 300;
        timerController.update();
        return;
      }

      if (message.data["title"] == "End chat from customer") {
        _ML.fcm('Handling: End chat from customer');
        log('isInChatScreen ${chatController.isInChatScreen}');
        if (chatController.isInChatScreen) {
          chatController.updateChatScreen(false);
          apiHelper.setAstrologerOnOffBusyline("Online");
          chatController.update();
        }
        return;
      }

      if (message.data["title"] == "Reject call request from astrologer") {
        _ML.call('User rejected call request');
        callController.isRejectCall = true;
        callController.update();
        callController.rejectDialog();
        return;
      }

      // ── Generic data-based dispatch ───────────────────────────────────
      try {
        if (message.data.isNotEmpty) {
          Map<String, dynamic> messageData;
          if (message.data.containsKey('body') &&
              message.data['body'] != null) {
            messageData = jsonDecode(message.data['body']);
            _ML.fcm('Parsed from body field');
          } else {
            messageData = message.data;
          }

          _ML.fcm('Parsed foreground messageData: $messageData');

          final notificationType = _resolveNotificationType(messageData);
          _ML.fcm('Resolved foreground notificationType=$notificationType');

          global.userID = messageData['id'];
          _ML.fcm('global.userID set to ${global.userID}');

          if (messageData['notificationType'] != null) {
            switch (messageData['notificationType']) {
              case 7:
                _ML.fcm('Foreground type 7 → Wallet');
                await walletController.getAmountList(isLoading: 0);
                NotificationHandler().foregroundNotification(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: false);
                break;

              case 8:
                _ML.fcm('Foreground type 8 → Chat list');
                await chatController.getChatList(true, isLoading: 0);
                chatController.update();
                NotificationHandler()
                    .foregroundNotificatioCustomAuddio(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
                break;

              case 2:
                _ML.call('Foreground type 2 → Incoming call notification');
                await _showIncomingCallNotification(messageData);
                break;

              case 9:
                _ML.fcm('Foreground type 9 → Report');
                reportController.reportList.clear();
                reportController.update();
                await reportController.getReportList(false);
                NotificationHandler().foregroundNotification(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
                break;

              // ── GIFT NOTIFICATION (foreground) ─────────────────────────
              // notificationType 13 = gift received
              case 13:
                _ML.gift('Foreground type 13 → Gift received');
                _ML.gift('Gift data: $messageData');
                // Gift is shown in HostLiveRoomPage via Agora data stream.
                // FCM gift notification is a fallback when app is backgrounded.
                // When foreground, the Agora stream handles the UI.
                // But we still show a system notification for record:
                await _showGiftNotification(messageData);
                break;

              case 10:
              case 11:
              case 12:
                _ML.fcm(
                    'Foreground type $notificationType → Live join waitlist');
                liveAstrologerController.isUserJoinWaitList = true;
                liveAstrologerController.update();
                NotificationHandler()
                    .foregroundNotificatioCustomAuddio(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
                break;

              default:
                _ML.fcm(
                    'Foreground unknown type → ${messageData['notificationType']}');
                NotificationHandler().foregroundNotification(message);
                await FirebaseMessaging.instance
                    .setForegroundNotificationPresentationOptions(
                        alert: true, badge: true, sound: true);
            }
          } else {
            // Admin or other non-typed notification
            _ML.fcm('No notificationType — treating as admin notification');
            NotificationHandler().foregroundNotification(message);
          }
        } else {
          _ML.fcm('message.data is empty in foreground — skipping');
        }
      } catch (e) {
        _ML.error('Foreground FCM handler exception', e);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _ML.fcm('onMessageOpenedApp fired data=${message.data}');
      NotificationHandler().onSelectNotification(json.encode(message.data));
    });

    getfcm();
  }

  // ── Live streaming chat handler ───────────────────────────────────────────

  void _handleLiveStreamingChat(RemoteMessage message) {
    final data = message.data;
    final sessionType = data["sessionType"];
    _ML.fcm('_handleLiveStreamingChat sessionType=$sessionType');

    if (sessionType == "start") {
      final liveChatUserName = data['liveChatSUserName'];
      if (liveChatUserName != null) {
        liveAstrologerController.liveChatUserName = liveChatUserName;
        liveAstrologerController.update();
      }
      final chatId = data["chatId"];
      liveAstrologerController.isUserJoinAsChat = true;
      liveAstrologerController.chatId = chatId;

      final waitListId = int.parse(data["waitListId"].toString());
      final time = liveAstrologerController.waitList
          .where((element) => element.id == waitListId)
          .first
          .time;
      liveAstrologerController.endTime = DateTime.now().millisecondsSinceEpoch +
          1000 * int.parse(time.toString());
      liveAstrologerController.update();
    } else {
      if (liveAstrologerController.isOpenPersonalChatDialog) {
        Get.back();
        liveAstrologerController.isOpenPersonalChatDialog = false;
      }
      liveAstrologerController.isUserJoinAsChat = false;
      liveAstrologerController.chatId = null;
      liveAstrologerController.update();
    }
  }

  // ── Timer and session start handler ──────────────────────────────────────

  void _handleTimerAndSessionStart(RemoteMessage message) {
    final data = message.data;
    final waitListId = int.parse(data["waitListId"].toString());
    liveAstrologerController.joinedUserName = data["name"] ?? "User";
    liveAstrologerController.joinedUserProfile = data["profile"] ?? "";
    final time = liveAstrologerController.waitList
        .where((element) => element.id == waitListId)
        .first
        .time;
    liveAstrologerController.endTime = DateTime.now().millisecondsSinceEpoch +
        1000 * int.parse(time.toString());
    liveAstrologerController.update();
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
          builder: EasyLoading.init(),
          home: SplashScreen(
            a: analytics,
            o: observer,
          ),
        ),
      );
    });
  }

  void getfcm() async {
    _ML.fcm('getfcm called');
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    _ML.fcm('FCM TOKEN = $fcmToken');

    if (Platform.isAndroid) {
      NotificationMethodChannel().createNewChannel();
      _ML.fcm('Android notification method channel created');
    }

    initializeCallKitEventHandlers();
  }

  void initializeCallKitEventHandlers() {
    _ML.call('initializeCallKitEventHandlers called');

    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;
      _ML.call('CallKit foreground event: ${event.event}');

      switch (event.event) {
        case Event.actionCallStart:
          _ML.call('actionCallStart');
          break;

        case Event.actionCallAccept:
          _ML.call('actionCallAccept — clearing prefs, calling callAccept');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_accepted', false);
          await prefs.setString('is_accepted_data', '');
          callAccept(event);
          break;

        case Event.actionCallDecline:
          _ML.call('actionCallDecline');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_accepted', false);
          await prefs.setString('is_accepted_data', '');

          if (event.body['extra']["notificationType"] == 2) {
            final callType = event.body['extra']['call_type'];
            if (callType == 10 || callType == 11) {
              _ML.call('Rejecting call ID=${event.body['extra']['callId']}');
              callController.rejectCallRequest(event.body['extra']['callId']);
              callController.update();
            }
          }
          break;

        case Event.actionCallCallback:
          _ML.call('actionCallCallback — calling callAccept');
          callAccept(event);
          break;

        default:
          _ML.call('Unhandled CallKit event: ${event.event}');
      }
    });
  }

  void callAccept(CallEvent event) async {
    _ML.call('callAccept called');
    _ML.call('  notificationType = ${event.body['extra']['notificationType']}');
    _ML.call('  callId           = ${event.body['extra']['callId']}');
    _ML.call('  profile          = ${event.body['extra']['profile']}');
    _ML.call('  name             = ${event.body['extra']['name']}');
    _ML.call('  call_duration    = ${event.body['extra']['call_duration']}');
    _ML.call('  fcmToken         = ${event.body['extra']['fcmToken']}');
    _ML.call('  id (CustomerID)  = ${event.body['extra']['id']}');

    if (event.body['extra']["notificationType"] == 2) {
      callController.callList.clear();
      callController.update();
      await callController.getCallList(false);
      callController.update();

      final callType = event.body['extra']['call_type'];
      _ML.call('call_type=$callType → routing accept');

      if (callType == 10) {
        _ML.call('Accepting AUDIO call');
        callController.acceptCallRequest(
          event.body['extra']['callId'],
          event.body['extra']['profile'],
          event.body['extra']['name'],
          event.body['extra']['id'],
          event.body['extra']['fcmToken'],
          event.body['extra']['call_duration'].toString(),
        );
      } else if (callType == 11) {
        _ML.call('Accepting VIDEO call');
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
      _ML.call('notificationType != 2 — may be chat type, no action');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHOW ANDROID NOTIFICATION (foreground notification helper)
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showAndroidNotification(RemoteMessage message) async {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification == null || android == null) {
    _ML.noti(
        '_showAndroidNotification: no notification/android field — skipping');
    return;
  }

  _ML.noti(
      '_showAndroidNotification title="${notification.title}" body="${notification.body}"');

  final payload = json.encode(message.data);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    kCallChannelId,
    'Incoming Calls',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    ticker: 'Incoming Call',
  );

  final NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await localNotifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    notification.title,
    notification.body,
    platformDetails,
    payload: payload,
  );

  _ML.noti('Android notification shown ✅');
}
