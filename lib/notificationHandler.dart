// ignore_for_file: file_names, prefer_const_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/call_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/report_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/main.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:astrowaypartner/views/HomeScreen/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/HomeController/chat_controller.dart';
import 'controllers/HomeController/home_controller.dart';
import 'views/HomeScreen/Drawer/Wallet/Wallet_screen.dart';

class NotificationHandler {
  final walletController = Get.find<WalletController>();
  final reportController = Get.find<ReportController>();
  final homecontroller = Get.find<HomeController>();
  final signupController = Get.find<SignupController>();
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();

  Future<void> onSelectNotification(String payload) async {
    Map<dynamic, dynamic> messageData;
    messageData = json.decode(payload);
    Map<dynamic, dynamic> body;
    body = jsonDecode(messageData['body']);
    log('in onSelectNotification');
    log('notification body $body');
    log('selected notificationType is ${body["notificationType"]} and calltype is ${body['call_type']}');

    if (body["notificationType"] == 7) {
      await walletController.getAmountList();
      walletController.update();
      Get.to(() => WalletScreen());
    } else if (body["notificationType"] == 8) {
      //chat
      log('chat tab clear and updated');
      chatController.chatList.clear();
      chatController.update();

      await chatController.getChatList(false);
      chatController.update();

      homecontroller.homeTabIndex = 0;

      homecontroller.isSelectedBottomIcon = 1;
      homecontroller.selectedItemPosition = 0;
      homecontroller.update();
      Get.to(() => const HomeScreen());
    } else if (body["notificationType"] == 2) {
      callController.callList.clear();
      callController.update();
      await callController.getCallList(false);
      callController.update();

      if (body['call_type'] == 10) {
        callController.acceptCallRequest(
          body['callId'],
          body['profile'],
          body['name'],
          body['id'],
          body['fcmToken'],
          body['call_duration'].toString(),
        );
      } else if (body['call_type'] == 11) {
        callController.acceptVideoCallRequest(
            body['callId'],
            body['profile'] ?? '',
            body['name'],
            body['id'],
            body['fcmToken'],
            body['call_duration'].toString());
      } else if (body["notificationType"] == 9) {
        reportController.reportList.clear();
        reportController.update();
        homecontroller.homeTabIndex = 0;

        homecontroller.update();
        await reportController.getReportList(false);
        reportController.update();

        Get.offAll(const HomeScreen());
      } else if (body["notificationType"] == 13) {
        //GIFT
        log('noti typ live - ${body["notificationType"]}');
        debugPrint(
            'is online -> ${homecontroller.notificationHandlingremoteUID}');
        if (homecontroller.notificationHandlingremoteUID != 0) {
          global.showToast(message: 'You are already live, end call first');
        } else {
          await walletController.getAmountList();
          signupController.astrologerList = [];
          signupController.update();
          walletController.update();
          await signupController.astrologerProfileById(false);
          homecontroller.homeTabIndex = 0;
          homecontroller.homeTabIndex = 1; //pageview index
          homecontroller.isSelectedBottomIcon = 3;
          homecontroller.historyTabController!.animateTo(0);
          homecontroller.update();
          Get.offAll(const HomeScreen());
        }
      }
    }
  }

  Future<void> foregroundNotificatioCustomAuddio(RemoteMessage payload) async {
    final initializationSettingsDarwin = DarwinInitializationSettings(
      defaultPresentBadge: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      defaultPresentSound: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        return;
      },
    );

    log('payload is ${payload.data['title']}');
    log('payload description 1 ${payload.data['description']}');

    final android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    final initialSetting = InitializationSettings(
        android: android, iOS: initializationSettingsDarwin);
    localNotifications.initialize(initialSetting,
        onDidReceiveNotificationResponse: (_) {
      log('foregroundNotificatioCustomAuddio tap');

      onSelectNotification(json.encode(payload.data));
    });
    final customSound = 'app_sound.wav';
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'channel_id_17',
      'channel.name',
      importance: Importance.max,
      icon: "@mipmap/ic_launcher",
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('app_sound'),
    );

    final iOSDetails = DarwinNotificationDetails(
      sound: customSound,
    );
    final platformChannelSpecifics =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    global.sp = await SharedPreferences.getInstance();

    if (global.sp!.getString("currentUser") != null) {
      await localNotifications.show(
        10,
        payload.data['title'], //message.data["title"]
        payload.data['description'] ?? '',
        platformChannelSpecifics,
        payload: json.encode(payload.data.toString()),
      );
    }
  }

  Future<void> foregroundNotification(RemoteMessage payload) async {
    log('--------------------------------------------------');
    log('started foreground notification');
    log('--------------------------------------------------');

    final initializationSettingsDarwin = DarwinInitializationSettings(
      defaultPresentBadge: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      defaultPresentSound: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        return;
      },
    );
    final android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    final initialSetting = InitializationSettings(
        android: android, iOS: initializationSettingsDarwin);

    localNotifications.initialize(initialSetting,
        onDidReceiveNotificationResponse: (_) {
      log('foregroundNotification tap');

      onSelectNotification(json.encode(payload.data));
    });

    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'channel_id-111',
      'channel.name',
      importance: Importance.max,
      icon: "@mipmap/ic_launcher",
      playSound: true,
      enableVibration: true,
    );

    final iOSDetails = const DarwinNotificationDetails();
    final platformChannelSpecifics =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    global.sp = await SharedPreferences.getInstance();

    if (global.sp!.getString("currentUser") != null) {
      await localNotifications.show(
        10,
        payload.data['title'],
        payload.data['description'],
        platformChannelSpecifics,
        payload: json.encode(payload.data.toString()),
      );
    }
  }
}
