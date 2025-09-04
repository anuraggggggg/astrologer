// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../constants/colorConst.dart';
import '../../../constants/messageConst.dart';
import '../../../controllers/HomeController/chat_controller.dart';
import '../../../controllers/networkController.dart';
import 'package:astrowaypartner/utils/global.dart' as global;

import '../../../main.dart';
import '../../../utils/config.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with AutomaticKeepAliveClientMixin {
  final chatController = Get.find<ChatController>();
  final networkController = Get.find<NetworkController>();

  @override
  void initState() {
    super.initState();
    // Fetch chat data if needed
    if (chatController.chatList.isEmpty) {
      chatController.getChatList(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return GetBuilder<ChatController>(
      builder: (chatController) {
        return chatController.chatList.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 10, bottom: 200),
                    child: ElevatedButton(
                      onPressed: () async {
                        var status = networkController.connectionStatus.value;
                        if (status <= 0) {
                          global.showToast(message: 'No internet');
                          return;
                        }
                        await chatController.getChatList(false);
                        chatController.update();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // global.warningDialog(context);
                        });
                      },
                      child: const Icon(Icons.refresh_outlined,
                          color: Colors.black),
                    ),
                  ),
                  Center(
                      child:
                          const Text('You don\'t have chat request yet!').tr()),
                ],
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await chatController.getChatList(true);
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: chatController.chatList.length,
                  physics: const ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: chatController.scrollController,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CachedNetworkImage(
                                imageUrl:
                                    '$imgBaseurl${chatController.chatList[index].profile}',
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 75,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Get.theme.primaryColor,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "$imgBaseurl${chatController.chatList[index].profile}"),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 75,
                                  width: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Get.theme.primaryColor,
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/no_customer_image.png"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: COLORS().primaryColor,
                                            size: 20),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Text(
                                            chatController.chatList[index]
                                                            .name ==
                                                        "" ||
                                                    chatController
                                                            .chatList[index]
                                                            .name ==
                                                        null
                                                ? "User"
                                                : chatController
                                                    .chatList[index].name!,
                                            style: Get.theme.primaryTextTheme
                                                .displaySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_month_outlined,
                                              color: COLORS().primaryColor,
                                              size: 20),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(
                                              DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(chatController
                                                      .chatList[index].birthDate
                                                      .toString())),
                                              style: Get.theme.primaryTextTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    chatController.chatList[index].birthTime!
                                            .isNotEmpty
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Icon(Icons.schedule_outlined,
                                                    color:
                                                        COLORS().primaryColor,
                                                    size: 20),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5),
                                                  child: Text(
                                                    chatController
                                                        .chatList[index]
                                                        .birthTime!,
                                                    style: Get
                                                        .theme
                                                        .primaryTextTheme
                                                        .titleSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 30,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        side: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      onPressed: () async {
                                        Future.delayed(const Duration(
                                                milliseconds: 500))
                                            .then((value) async {
                                          await localNotifications.cancelAll();
                                        });
                                        global.showOnlyLoaderDialog();
                                        await chatController.storeChatId(
                                          chatController.chatList[index].id!,
                                          chatController
                                              .chatList[index].chatId!,
                                        );
                                        global.hideLoader();
                                        await chatController.acceptChatRequest(
                                          chatController
                                              .chatList[index].chatId!,
                                          chatController.chatList[index].name ??
                                              'user',
                                          chatController
                                                  .chatList[index].profile ??
                                              "",
                                          chatController.chatList[index].id!,
                                          chatController
                                              .chatList[index].fcmToken!,
                                          chatController
                                              .chatList[index].chatduration!,
                                        );
                                      },
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "Accept",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400),
                                        ).tr(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    width: 90,
                                    height: 30,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: COLORS().errorColor,
                                        side: BorderSide(
                                            color: COLORS().errorColor),
                                      ),
                                      onPressed: () {
                                        Get.dialog(
                                          AlertDialog(
                                            title: const Text(
                                                    "Are you sure you want remove customer?")
                                                .tr(),
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: const Text(
                                                          MessageConstants.No)
                                                      .tr(),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    // Cancel all local notifications
                                                    Future.delayed(const Duration(milliseconds: 500)).then((value) async {
                                                      await localNotifications.cancelAll();
                                                    });

                                                    // Get the current chatId
                                                    final chatId = chatController.chatList[index].chatId!;

                                                    // Call reject function (API/backend update)
                                                    await chatController.rejectChatRequest(chatId);

                                                    // Remove the user from the chat list locally
                                                    chatController.chatList.removeAt(index);

                                                    // Update the UI
                                                    chatController.update();

                                                    // Close the dialog
                                                    Get.back();
                                                  },
                                                  child: const Text(MessageConstants.YES).tr(),
                                                ),

                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "Reject",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w400),
                                        ).tr(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
