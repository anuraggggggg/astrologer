// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../constants/colorConst.dart';
import '../../../controllers/Authentication/signup_controller.dart';
import '../../../controllers/HomeController/chat_controller.dart';
import '../../../controllers/HomeController/home_controller.dart';
import '../../../controllers/HomeController/wallet_controller.dart';
import '../../../utils/config.dart';
import '../../../widgets/wallet_history_screen.dart';
import '../Report_Module/report_history_list_screen.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../call_detail_screen.dart';
import '../chat/chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final homeController = Get.find<HomeController>();
  final chatController = Get.find<ChatController>();
  final walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 4,
      initialIndex: homeController.homeTabIndex,
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
                controller: homeController.historyTabController,
                onTap: (index) {
                  homeController.onHistoryTabBarIndexChanged(index);
                },
                indicatorColor: COLORS().primaryColor,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                unselectedLabelColor: COLORS().bodyTextColor,
                labelColor: Colors.black,
                tabs: [
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 12.sp,
                    ),
                  ).tr(),
                  Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 11.sp,
                    ),
                  ).tr(),
                  Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 11.sp,
                    ),
                  ).tr(),
                  Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 11.sp,
                    ),
                  ).tr(),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: homeController.historyTabController,
              children: [
                //First Tabbar
                GetBuilder<SignupController>(builder: (c) {
                  return const WalletHistoryScreen();
                }),
                //Second Tabbar history of call
                GetBuilder<SignupController>(
                  builder: (signupController) {
                    return signupController.astrologerList.isEmpty
                        ? SizedBox(
                            child: Center(
                              child: const Text('Please Wait!!!!').tr(),
                            ),
                          )
                        : signupController
                                .astrologerList[0]!.callHistory!.isEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 10, bottom: 200),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          // global.warningDialog(context);
                                        });
                                        signupController.astrologerList.clear();
                                        await signupController
                                            .astrologerProfileById(false);
                                        signupController.update();
                                      },
                                      child: const Icon(
                                        Icons.refresh_outlined,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Center(
                                      child:
                                          const Text('No call history is here')
                                              .tr()),
                                ],
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await signupController
                                      .astrologerProfileById(false);
                                  signupController.update();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    // global.warningDialog(context);
                                  });
                                },
                                child: ListView.builder(
                                  itemCount:
                                      signupController.astrologerList.isNotEmpty
                                          ? signupController.astrologerList[0]!
                                                  .callHistory?.length ??
                                              0
                                          : 0,
                                  controller: signupController
                                      .callHistoryScrollController,
                                  physics: const ClampingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (signupController
                                              .astrologerList.isNotEmpty) {
                                            Get.to(() => CallDetailScreen(
                                                  callHistorydata:
                                                      signupController
                                                          .astrologerList[0]!
                                                          .callHistory![index],
                                                ));
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              width: width,
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  top: 8,
                                                  right: 8,
                                                  bottom: 10),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '#00${signupController.astrologerList[0]!.callHistory![index].id.toString()}s',
                                                              style: Get
                                                                  .theme
                                                                  .primaryTextTheme
                                                                  .titleSmall,
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5.0),
                                                          child: Text(
                                                            signupController
                                                                            .astrologerList[
                                                                                0]!
                                                                            .callHistory![
                                                                                index]
                                                                            .name !=
                                                                        null ||
                                                                    signupController
                                                                        .astrologerList[
                                                                            0]!
                                                                        .callHistory![
                                                                            index]
                                                                        .name
                                                                        .toString()
                                                                        .isNotEmpty
                                                                ? signupController
                                                                    .astrologerList[
                                                                        0]!
                                                                    .callHistory![
                                                                        index]
                                                                    .name
                                                                    .toString()
                                                                : "User",
                                                            style: Get
                                                                .theme
                                                                .primaryTextTheme
                                                                .displaySmall,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5.0),
                                                          child: Text(
                                                            DateFormat(
                                                                    'dd MMM yyyy , hh:mm a')
                                                                .format(DateTime
                                                                    .parse(
                                                              signupController
                                                                  .astrologerList[
                                                                      0]!
                                                                  .callHistory![
                                                                      index]
                                                                  .createdAt
                                                                  .toString(),
                                                            )),
                                                            style: Get
                                                                .theme
                                                                .primaryTextTheme
                                                                .titleMedium,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5.0),
                                                          child: Text(
                                                            signupController
                                                                .astrologerList[
                                                                    0]!
                                                                .callHistory![
                                                                    index]
                                                                .callStatus!,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Rate : ",
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ).tr(),
                                                              Text(
                                                                '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${signupController.astrologerList[0]!.callHistory![index].callRate} /min',
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 2.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Duration : ",
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ).tr(),
                                                              Text(
                                                                signupController.astrologerList[0]!.callHistory![index].totalMin !=
                                                                            null &&
                                                                        signupController
                                                                            .astrologerList[0]!
                                                                            .callHistory![index]
                                                                            .totalMin!
                                                                            .isNotEmpty
                                                                    ? "${signupController.astrologerList[0]!.callHistory![index].totalMin} min"
                                                                    : "0 min",
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 2.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Deduction : ",
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ).tr(),
                                                              Text(
                                                                "${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${signupController.astrologerList[0]!.callHistory![index].deduction}",
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                height: 75,
                                                                width: 75,
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            50),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              7),
                                                                  color: COLORS()
                                                                      .primaryColor,
                                                                  image: signupController.astrologerList[0]!.callHistory![index].profile !=
                                                                              null &&
                                                                          signupController
                                                                              .astrologerList[
                                                                                  0]!
                                                                              .callHistory![
                                                                                  index]
                                                                              .profile!
                                                                              .isNotEmpty
                                                                      ? DecorationImage(
                                                                          scale:
                                                                              8,
                                                                          image:
                                                                              NetworkImage(
                                                                            "$imgBaseurl${signupController.astrologerList[0]!.callHistory![index].profile}",
                                                                          ))
                                                                      : const DecorationImage(
                                                                          scale:
                                                                              8,
                                                                          image:
                                                                              AssetImage(
                                                                            "assets/images/no_customer_image.png",
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ))
                                                ],
                                              ),
                                            ),
                                            signupController
                                                            .isMoreDataAvailable ==
                                                        true &&
                                                    !signupController
                                                        .isAllDataLoaded &&
                                                    signupController
                                                                .astrologerList[
                                                                    0]!
                                                                .callHistory!
                                                                .length -
                                                            1 ==
                                                        index
                                                ? const CircularProgressIndicator()
                                                : const SizedBox(),
                                            index ==
                                                    signupController
                                                            .astrologerList[0]!
                                                            .callHistory!
                                                            .length -
                                                        1
                                                ? const SizedBox(
                                                    height: 20,
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                  },
                ),
                //Third tabbar history if chat
                GetBuilder<SignupController>(
                  builder: (signupController) {
                    return signupController.astrologerList.isEmpty
                        ? SizedBox(
                            child: Center(
                              child: const Text('Please Wait!!!!').tr(),
                            ),
                          )
                        : signupController
                                .astrologerList[0]!.chatHistory!.isEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 10, bottom: 200),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          // global.warningDialog(context);
                                        });
                                        signupController.astrologerList.clear();
                                        await signupController
                                            .astrologerProfileById(false);
                                        signupController.update();
                                      },
                                      child: const Icon(
                                        Icons.refresh_outlined,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Center(
                                      child:
                                          const Text('No chat history is here')
                                              .tr()),
                                ],
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  debugPrint('click refresh chat');
                                  await signupController
                                      .astrologerProfileById(false);
                                  signupController.update();
                                  getwalletamountlist();
                                },
                                child: ListView.builder(
                                  itemCount: signupController
                                      .astrologerList[0]!.chatHistory?.length,
                                  controller: signupController
                                      .chatHistoryScrollController,
                                  physics: const ClampingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics()),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        debugPrint(
                                            'firebase history chat id:- ${signupController.astrologerList[0]!.chatHistory![index].chatId!}');

                                        int duration = int.parse(chatController
                                            .chatList[index].chatduration!);
                                        Get.to(
                                          () => ChatScreen(
                                            chatHistoryData: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index],
                                            flagId: 2,
                                            customerName: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .name!,
                                            customerProfile: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .profile!,
                                            customerId: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .id!, //cutomer id here
                                            fireBasechatId: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .chatId!, //firebase chat id
                                            chatId: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .chatId!, //chat id
                                            astrologerId: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .astrologerId!,
                                            astrologerName: signupController
                                                .astrologerList[0]!
                                                .chatHistory![index]
                                                .astrologerName!,
                                            chatduration: duration,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: width,
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  top: 8,
                                                  right: 8,
                                                  bottom: 10),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '#00${signupController.astrologerList[0]!.chatHistory![index].id.toString()}',
                                                                style: Get
                                                                    .theme
                                                                    .primaryTextTheme
                                                                    .titleSmall,
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5.0),
                                                            child: Text(
                                                              signupController.astrologerList[0]!.chatHistory![index].name !=
                                                                          null &&
                                                                      signupController
                                                                          .astrologerList[
                                                                              0]!
                                                                          .chatHistory![
                                                                              index]
                                                                          .name!
                                                                          .isNotEmpty
                                                                  ? signupController
                                                                      .astrologerList[
                                                                          0]!
                                                                      .chatHistory![
                                                                          index]
                                                                      .name!
                                                                  : "User",
                                                              style: Get
                                                                  .theme
                                                                  .primaryTextTheme
                                                                  .displaySmall,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5.0),
                                                            child: Text(
                                                              DateFormat(
                                                                      'dd MMM yyyy , hh:mm a')
                                                                  .format(DateTime.parse(signupController
                                                                      .astrologerList[
                                                                          0]!
                                                                      .chatHistory![
                                                                          index]
                                                                      .createdAt
                                                                      .toString())),
                                                              style: Get
                                                                  .theme
                                                                  .primaryTextTheme
                                                                  .titleMedium,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5.0),
                                                            child: Text(
                                                              signupController
                                                                  .astrologerList[
                                                                      0]!
                                                                  .chatHistory![
                                                                      index]
                                                                  .chatStatus!,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 5.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Rate : ",
                                                                  style: Get
                                                                      .theme
                                                                      .primaryTextTheme
                                                                      .titleSmall,
                                                                ).tr(),
                                                                Text(
                                                                  signupController.astrologerList[0]!.chatHistory![index].chatRate !=
                                                                              null &&
                                                                          signupController
                                                                              .astrologerList[0]!
                                                                              .chatHistory![index]
                                                                              .chatRate!
                                                                              .isNotEmpty
                                                                      ? '${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${signupController.astrologerList[0]!.chatHistory![index].chatRate} /min'
                                                                      : "${global.getSystemFlagValue(global.systemFlagNameList.currency)} 0/min",
                                                                  style: Get
                                                                      .theme
                                                                      .primaryTextTheme
                                                                      .titleSmall,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 2.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Duration : ",
                                                                  style: Get
                                                                      .theme
                                                                      .primaryTextTheme
                                                                      .titleSmall,
                                                                ).tr(),
                                                                Text(
                                                                  signupController.astrologerList[0]!.chatHistory![index].totalMin !=
                                                                              null &&
                                                                          signupController
                                                                              .astrologerList[0]!
                                                                              .chatHistory![index]
                                                                              .totalMin!
                                                                              .isNotEmpty
                                                                      ? "${signupController.astrologerList[0]!.chatHistory![index].totalMin} min"
                                                                      : "0 min",
                                                                  style: Get
                                                                      .theme
                                                                      .primaryTextTheme
                                                                      .titleSmall,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 2.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Deduction : ",
                                                                  style: Get
                                                                      .theme
                                                                      .primaryTextTheme
                                                                      .titleSmall,
                                                                ).tr(),
                                                                Text(
                                                                  "${global.getSystemFlagValue(global.systemFlagNameList.currency)} ${signupController.astrologerList[0]!.chatHistory![index].deduction}",
                                                                  style: Get
                                                                      .theme
                                                                      .primaryTextTheme
                                                                      .titleSmall,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            height: 75,
                                                            width: 75,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 50),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              color: COLORS()
                                                                  .primaryColor,
                                                              image: signupController
                                                                              .astrologerList[
                                                                                  0]!
                                                                              .chatHistory![
                                                                                  index]
                                                                              .profile !=
                                                                          null &&
                                                                      signupController
                                                                          .astrologerList[
                                                                              0]!
                                                                          .chatHistory![
                                                                              index]
                                                                          .profile!
                                                                          .isNotEmpty
                                                                  ? DecorationImage(
                                                                      scale: 8,
                                                                      image:
                                                                          NetworkImage(
                                                                        "$imgBaseurl${signupController.astrologerList[0]!.chatHistory![index].profile}",
                                                                      ))
                                                                  : const DecorationImage(
                                                                      scale: 8,
                                                                      image:
                                                                          AssetImage(
                                                                        "assets/images/no_customer_image.png",
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ],
                                                      ))
                                                ],
                                              ),
                                            ),
                                            signupController
                                                            .isMoreDataAvailable ==
                                                        true &&
                                                    !signupController
                                                        .isAllDataLoaded &&
                                                    signupController
                                                                .astrologerList[
                                                                    0]!
                                                                .chatHistory!
                                                                .length -
                                                            1 ==
                                                        index
                                                ? const CircularProgressIndicator()
                                                : const SizedBox(),
                                            index ==
                                                    signupController
                                                            .astrologerList[0]!
                                                            .chatHistory!
                                                            .length -
                                                        1
                                                ? const SizedBox(
                                                    height: 20,
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                  },
                ),
                //Fifth Tabbar
                const ReportHistoryListScreen(),
              ],
            ),
          )
        ],
      ),
    );
  }

  void getwalletamountlist() async {
    await walletController.getAmountList();
    walletController.update();
  }
}
