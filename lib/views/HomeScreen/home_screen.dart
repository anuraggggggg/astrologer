// ignore_for_file: must_be_immutable, unnecessary_null_comparison, avoid_print, prefer_typing_uninitialized_variables, deprecated_member_use, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/controllers/HistoryController/call_history_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/chat_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/edit_profile_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/home_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/live_astrologer_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/report_controller.dart';
import 'package:astrowaypartner/controllers/HomeController/wallet_controller.dart';
import 'package:astrowaypartner/controllers/following_controller.dart';
import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/controllers/networkController.dart';
import 'package:astrowaypartner/controllers/notification_controller.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/Wallet/Wallet_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Drawer/drawer_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/edit_profile_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Profile/profile_screen.dart';

import 'package:astrowaypartner/views/HomeScreen/live/live_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/notification_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/Report_Module/report_request_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/callTab.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/languagePicker.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:astrowaypartner/widgets/floating_action_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:sizer/sizer.dart';

import '../../controllers/splashController.dart';

import '../../services/apiHelper.dart';
import 'history/HistroryScreen.dart';
import 'tabs/chatTab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final chatController = Get.find<ChatController>();
  final callHistoryController = Get.find<CallHistoryController>();
  final reportController = Get.find<ReportController>();
  final signupController = Get.find<SignupController>();
  final walletController = Get.find<WalletController>();
  final followingController = Get.find<FollowingController>();
  final editProfileController = Get.put(EditProfileController());
  final liveAstrologerController = Get.find<LiveAstrologerController>();
  final notificationController = Get.find<NotificationController>();
  final networkController = Get.find<NetworkController>();
  final homeController = Get.find<HomeController>();
  final splashController = Get.find<SplashController>();

  final kundlicontroller = Get.find<KundliController>();

  final apiHelper = APIHelper();
  final snakeBarStyle = SnakeBarBehaviour.pinned;
  bool showSelectedLabels = true;
  bool showUnselectedLabels = true;
  Color selectedColor = Colors.grey.shade500;
  Color unselectedColor = Colors.blueGrey;
  int _selectedItemPosition = 0;
  int previousposition = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getwalletamountlist();
      //global.warningDialog(context);
    });

    //SET ASTRO ONLINE ON APP START
    apiHelper.setAstrologerOnOffBusyline('Online');
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: GetBuilder<HomeController>(builder: (homeController) {
        return WillPopScope(
            onWillPop: () async {
              bool isExit = false;
              if (homeController.isSelectedBottomIcon == 1) {
                isExit = await homeController.onBackPressed();
                if (isExit) {
                  exit(0);
                }
              } else if (homeController.isSelectedBottomIcon == 2) {
                global.showToast(
                    message: tr(
                        'You must end the call to exit the live streaming session.'));
              } else {
                homeController.isSelectedBottomIcon = 1;
                homeController.update();
              }
              return isExit;
            },
            child: Scaffold(
              appBar: homeController.isSelectedBottomIcon == 2
                  ? null
                  : MyCustomAppBar(
                      height: 80,
                      title: Text(
                        global.getSystemFlagValue(
                          global.systemFlagNameList.appName,
                        ),
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04),
                      ).tr(),
                      actions: [
                        homeController.isSelectedBottomIcon == 1
                            ? Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      homeController.lan = [];
                                      await homeController.getLanguages();
                                      await homeController.updateLanIndex();
                                      print(homeController.lan);
                                      global.checkBody().then((result) {
                                        if (result) {
                                          //lANGUAGE BOTTOMSHEET
                                          showLanguageBottomSheet(
                                              context, homeController);
                                        }
                                      });
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: ImageIcon(
                                        AssetImage(
                                          'assets/images/translation.png',
                                        ),
                                        color: Colors.black,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        notificationController.notificationList
                                            .clear();
                                        notificationController
                                            .getNotificationList(false);
                                        Get.to(() => NotificationScreen());
                                      },
                                      icon: const Icon(
                                          Icons.notifications_outlined),
                                    ),
                                  ),
                                  GetBuilder<WalletController>(
                                    builder: (walletController) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await walletController
                                              .getAmountList();
                                          Get.to(() => WalletScreen());
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border:
                                                Border.all(color: Colors.black),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                Text(
                                                    '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ',
                                                    style: Get
                                                        .theme
                                                        .primaryTextTheme
                                                        .displaySmall),
                                                Text(
                                                  walletController.withdraw
                                                              .walletAmount !=
                                                          null
                                                      ? walletController
                                                          .withdraw
                                                          .walletAmount!
                                                          .toStringAsFixed(0)
                                                      : " 0",
                                                  style: Get
                                                      .theme
                                                      .primaryTextTheme
                                                      .displaySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : GetBuilder<EditProfileController>(
                                builder: (editProfileController) {
                                  return homeController.isSelectedBottomIcon ==
                                          4
                                      ? IconButton(
                                          onPressed: () {
                                            editProfileController
                                                .fillAstrologer(global.user);
                                            editProfileController.updateId =
                                                global.user.id;
                                            Get.to(() => EditProfileScreen());
                                            editProfileController.index = 0;
                                          },
                                          icon: const Icon(Icons.edit_outlined),
                                        )
                                      : const SizedBox();
                                },
                              ),
                      ],
                    ),
              body: Container(
                height: height,
                color: COLORS().greyBackgroundColor,
                child: homeController.isSelectedBottomIcon == 1
                    ?
                    //---------------------------Home-------------------------------------
                    GetBuilder<HomeController>(
                        builder: (homeController) => DefaultTabController(
                          length: 3,
                          initialIndex: 0,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.transparent,
                                        spreadRadius: 0.2,
                                        blurRadius: 0.2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: TabBar(
                                    dividerColor: Colors.transparent,
                                    controller: homeController.tabController,
                                    onTap: (index) async {
                                      homeController.homeTabIndex = index;
                                    },
                                    indicatorColor: COLORS().primaryColor,
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    unselectedLabelColor:
                                        COLORS().bodyTextColor,
                                    labelColor: Colors.black,
                                    tabs: [
                                      Text(
                                        'Chat',
                                        style: TextStyle(fontSize: 11.sp),
                                      ).tr(),
                                      Text(
                                        'Calls',
                                        style: TextStyle(fontSize: 11.sp),
                                      ).tr(),
                                      Text(
                                        'Report',
                                        style: TextStyle(fontSize: 11.sp),
                                      ).tr(),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: homeController.tabController,
                                  children: [
                                    //First TabBar  --chat--
                                    const ChatTab(),

                                    //Second TabBar  --calls--
                                    const CallTab(),

                                    //third TabBar --report--
                                    ReportRequestScreen(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : homeController.isSelectedBottomIcon == 2
                        ?
                        //---------------------------Record Live session-------------------------------------
                        const LiveScreen()
                        : homeController.isSelectedBottomIcon == 3
                            ?
                            //---------------------------History-------------------------------------
                            const HistoryScreen()
                            : homeController.isSelectedBottomIcon == 4
                                ?
                                //--------------------------Profile------------------------------------

                                ProfileScreen()
                                : null,
              ),
              floatingActionButton: homeController.isSelectedBottomIcon != 1
                  ? const SizedBox()
                  : const FloatingActionButtonWidget(),
              drawer: DrawerScreen(),
              bottomNavigationBar: SizedBox(
                height: 7.7.h,
                child: SnakeNavigationBar.color(
                  behaviour: snakeBarStyle,
                  snakeViewColor: selectedColor,
                  unselectedItemColor: Colors.blueGrey,
                  showUnselectedLabels: showUnselectedLabels,
                  showSelectedLabels: showSelectedLabels,
                  currentIndex: _selectedItemPosition,
                  selectedLabelStyle: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  // BOTTOm NAVIGATION POSITION HANDlE
                  onTap: (value) {
                    setState(() {
                      previousposition = _selectedItemPosition;
                      _selectedItemPosition = value;
                    });

                    debugPrint('tapped on $value');
                    //HOME TAB
                    if (value == 0) {
                      getamountlist();

                      var status = networkController.connectionStatus.value;
                      debugPrint('network  status $status');
                      if (status <= 0) {
                        global.showToast(message: 'No internet');
                      }
                      if (liveAstrologerController.isImInLive) {
                        debugPrint('already Live');
                        alreadyLive(1, homeController);
                      } else {
                        homeController.isSelectedBottomIcon = 1;
                        homeController.update();
                      }
                    }
                    //LIVE TAB
                    if (value == 1) {
                      if (liveAstrologerController.isImInLive) {
                        global.showToast(message: 'You are already live');
                      } else {
                        showCuprtinoLiveDialog(homeController);
                      }
                    }
                    if (value == 2) {
                      getamountlist();

                      var status = networkController.connectionStatus.value;
                      debugPrint('network  status $status');
                      if (status <= 0) {
                        global.showToast(message: 'No internet');
                      }
                      if (liveAstrologerController.isImInLive) {
                        debugPrint('tab History');
                        alreadyLive(3, homeController);
                      } else {
                        _handlevalue2(homeController);
                      }
                    }
                    if (value == 3) {
                      var status = networkController.connectionStatus.value;
                      debugPrint('network  status $status');
                      if (status <= 0) {
                        global.showToast(message: 'No internet');
                      }
                      if (liveAstrologerController.isImInLive) {
                        debugPrint('tab profile');
                        alreadyLive(4, homeController);
                      } else {
                        _handlevalue3(homeController);
                      }
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset(
                            'assets/images/bottombaricons/home.png',
                          ),
                        ),
                        label: tr('Home')),
                    BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset(
                            'assets/images/bottombaricons/live.png',
                          ),
                        ),
                        label: tr('Live')),
                    BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset(
                            'assets/images/bottombaricons/history.png',
                          ),
                        ),
                        label: tr('History')),
                    BottomNavigationBarItem(
                        icon: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset(
                            'assets/images/bottombaricons/profile-user.png',
                          ),
                        ),
                        label: tr('Profile')),
                  ],
                ),
              ),
            ));
      }),
    );
  }

  void getamountlist() async {
    await walletController.getAmountList();
  }

  void setLocale(Locale nLocale) {
    context.setLocale(nLocale);
    Get.updateLocale(nLocale);
  }

  void _handlevalue2(HomeController homeController) async {
    signupController.astrologerList.clear();
    await signupController.astrologerProfileById(true);
    homeController.isSelectedBottomIcon = 3;
    homeController.update();
  }

  void _handlevalue3(HomeController homeController) async {
    followingController.followerList.clear();
    await followingController.followingList(false);
    homeController.isSelectedBottomIcon = 4;
    homeController.update();
  }

  void showCuprtinoLiveDialog(HomeController homeController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Start Live Session').tr(),
          content: const Text('Do you want to start a live session?').tr(),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'Go Live',
                style: TextStyle(color: Colors.black),
              ).tr(),
              onPressed: () {
                //  "Go Live"
                liveAstrologerController.isImInLive = true;
                liveAstrologerController.update();
                homeController.isSelectedBottomIcon = 2;
                homeController.update();
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ).tr(),
              onPressed: () {
                setState(() {
                  _selectedItemPosition = previousposition;
                });
                // Navigator.of(context).pop();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void alreadyLive(int position, HomeController homeController) {
    debugPrint('already live posi $position');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('You are Live').tr(),
          content: const Text('Do you want to Stop a live session?').tr(),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.black),
              ).tr(),
              onPressed: () {
                homeController.isSelectedBottomIcon = position;
                homeController.update();
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                'No',
                style: TextStyle(color: Colors.black),
              ).tr(),
              onPressed: () {
                setState(() {
                  _selectedItemPosition = 1;
                  //! Fix position when No clicked while Live Live index is 1 i.e
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void getwalletamountlist() async {
    await walletController.getAmountList();
    walletController.update();
  }
}
