// ignore_for_file: avoid_print, deprecated_member_use, unused_element

import 'package:astrowaypartner/controllers/HomeController/call_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/report_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'callAvailability_controller.dart';
import 'chatAvailability_controller.dart';

class HomeCheckController extends FullLifeCycleController
    with FullLifeCycleMixin {
  // Mandatory
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final reportController = Get.find<ReportController>();
  final callControlleronline = Get.find<CallAvailabilityController>();
  final chatControlleronline = Get.find<ChatAvailabilityController>();
  @override
  void onDetached() {
    print('HomeController - onDetached called');
  }

  // Mandatory
  @override
  void onInactive() async {
    print('Hello');
    print('HomeController - onInative called');
  }

  // Mandatory
  @override
  void onPaused() {
    print('HomeController - onPaused called');
  }

  // Mandatory
  @override
  void onResumed() async {
    chatController.chatList = [];
    callController.callList = [];
    reportController.reportList = [];
    // _loadDataInBackground(
    //     () => chatController.getChatList(false, isLoading: 0), 'chat');
    // _loadDataInBackground(
    //     () => callController.getCallList(false, isLoading: 0), 'call');
    // _loadDataInBackground(
    //     () => reportController.getReportList(false, isLoading: 0), 'report');

    print('HomeController - onResumed called');
  }

  void _loadDataInBackground(
      Future<void> Function() loadData, String logMessage) {
    Future<void>.microtask(() async {
      try {
        await loadData();
        debugPrint('loaded $logMessage in the background');
      } catch (error) {
        debugPrint('loading $logMessage in the background error: $error');
      }
    });
  }

  @override
  Future<bool> didPushRoute(String route) {
    print('HomeController - the route $route will be open');
    return super.didPushRoute(route);
  }

  // Optional
  @override
  Future<bool> didPopRoute() {
    print('HomeController - the current route will be closed');
    return super.didPopRoute();
  }

  // Optional
  @override
  void didChangeMetrics() {
    print('HomeController - the window size did change');
    super.didChangeMetrics();
  }

  // Optional
  @override
  void didChangePlatformBrightness() {
    print('HomeController - platform change ThemeMode');
    super.didChangePlatformBrightness();
  }

  @override
  void onHidden() {}
}
