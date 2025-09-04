// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:astrowaypartner/controllers/HomeController/call_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/report_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/following_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/language.dart';
import '../../services/apiHelper.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  String screen = 'home_controller.dart';
  final chatController = Get.find<ChatController>();
  final callController = Get.find<CallController>();
  final reportController = Get.find<ReportController>();
  final walletController = Get.find<WalletController>();
  final followingController = Get.find<FollowingController>();
  int? notificationHandlingremoteUID = 0;
  getOnlineAstro(val) {
    notificationHandlingremoteUID = val;
    log('is online homecontroller check-$notificationHandlingremoteUID');

    update();
  }

  int selectedItemPosition = 0;
  int previousposition = 0;

  //Scroll  controller
  ScrollController chatScrollController = ScrollController();
  ScrollController callScrollController = ScrollController();
  ScrollController reportScrollController = ScrollController();
  ScrollController followingScrollController = ScrollController();
  int fetchRecord = 20;
  int startIndex = 0; //! WORK HERE
  bool isDataLoaded = false;
  bool isAllDataLoaded = false;
  bool isChatMoreDataAvailable = false;
  bool isCallMoreDataAvailable = false;
  bool isReportMoreDataAvailable = false;
  bool isFollowerMoreDataAvailable = false;
  TabController? historyTabController;
  TabController? tabController;

  List<Language> lan = [];
  APIHelper apiHelper = APIHelper();

  @override
  onInit() {
    init();
    historyTabController = TabController(length: 4, vsync: this);
    tabController = TabController(length: 3, vsync: this);

    super.onInit();
  }

  init() async {
    await walletController.getAmountList();
    paginateTask();
  }

  void paginateTask() {
    chatScrollController.addListener(() async {
      if (chatScrollController.position.pixels ==
              chatScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isChatMoreDataAvailable = true;
        print('scroll my following');
        update();
        await chatController.getChatList(true);
      }
    });
    callScrollController.addListener(() async {
      if (callScrollController.position.pixels ==
              callScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isCallMoreDataAvailable = true;
        print('scroll my following');
        update();
        await callController.getCallList(true);
      }
    });
    reportScrollController.addListener(() async {
      if (reportScrollController.position.pixels ==
              reportScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isReportMoreDataAvailable = true;
        print('scroll my following');
        update();
        await callController.getCallList(true);
      }
    });
    followingScrollController.addListener(() async {
      if (followingScrollController.position.pixels ==
              followingScrollController.position.maxScrollExtent &&
          !isAllDataLoaded) {
        isFollowerMoreDataAvailable = true;
        print('scroll my following');
        update();
        await followingController.followingList(true);
      }
    });
  }

//Home Tabs
  int homeTabIndex = 0.obs();

//Histroey Tabs
  int historyCurrentIndex = 0;
  int historyTabIndex = 0.obs();

  onHistoryTabBarIndexChanged(value) {
    historyTabIndex = value;
    update();
  }

//Extras
  int? currentPage;
  int totalPage = 3;
//Bottom
  int isSelectedBottomIcon = 1.obs();
  bool isSelected = false;

  DateTime? currentBackPressTime;
  Future<bool> onBackPressed() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      global.showToast(message: "Press again to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  int selectedIndex = 0;
  updateLan(int index) {
    selectedIndex = index;
    lan[index].isSelected = true;
    update();
    for (int i = 0; i < lan.length; i++) {
      if (i == index) {
        continue;
      } else {
        lan[i].isSelected = false;
        update();
      }
    }
    update();
  }

  updateLanIndex() async {
    global.spLanguage = await SharedPreferences.getInstance();
    var currentLan = global.spLanguage!.getString('currentLanguage') ?? 'en';
    for (int i = 0; i < lan.length; i++) {
      if (lan[i].lanCode == currentLan) {
        selectedIndex = i;
        lan[i].isSelected = true;
        update();
      } else {
        lan[i].isSelected = false;
        update();
      }
    }
    print(selectedIndex);
  }

  getLanguages() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          lan.clear(); // Clear existing languages
          lan.addAll(staticLanguageList); // Add static languages
          update();
        }
      });
    } catch (e) {
      print("Exception in addFeedback():- $e");
    }
  }
}
