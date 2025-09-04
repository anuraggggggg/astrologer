// ignore_for_file: file_names

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/chatAvailability_controller.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:astrowaypartner/widgets/common_textfield_widget.dart';
import 'package:astrowaypartner/widgets/primary_text_widget.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

// ignore: must_be_immutable
class ChatAvailabilityScreen extends StatelessWidget {
  ChatAvailabilityScreen({super.key});

  ChatAvailabilityController chatAvailabilityController =
      Get.find<ChatAvailabilityController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
            height: 80,
            backgroundColor: COLORS().primaryColor,
            title: const Text("Chat Availability").tr()),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child:
              GetBuilder<ChatAvailabilityController>(builder: (chatAvaialble) {
            return Column(children: [
              ListTile(
                enabled: true,
                tileColor: Colors.white,
                title: Center(
                  child: Text(
                    "Change your availability for chat",
                    style: Theme.of(context).primaryTextTheme.displaySmall,
                  ).tr(),
                ),
              ),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: chatAvailabilityController.chatType,
                    activeColor: COLORS().primaryColor,
                    onChanged: (val) {
                      chatAvailabilityController.setChatAvailability(
                          val, "Online");
                      chatAvailabilityController.showAvailableTime = true;
                      chatAvailabilityController.update();
                    },
                  ),
                  Text(
                    'Online',
                    style: Theme.of(context).primaryTextTheme.titleMedium,
                  ).tr()
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 2,
                    groupValue: chatAvailabilityController.chatType,
                    activeColor: COLORS().primaryColor,
                    onChanged: (val) {
                      chatAvailabilityController.setChatAvailability(
                          val, "Offline");
                      chatAvailabilityController.showAvailableTime = true;
                      chatAvailabilityController.update();
                    },
                  ),
                  Text(
                    'Offline',
                    style: Theme.of(context).primaryTextTheme.titleMedium,
                  ).tr()
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 3,
                    groupValue: chatAvailabilityController.chatType,
                    activeColor: COLORS().primaryColor,
                    onChanged: (val) {
                      chatAvailabilityController.setChatAvailability(
                          val, "Wait Time");
                      chatAvailabilityController.showAvailableTime = false;
                      chatAvailabilityController.update();
                    },
                  ),
                  Text(
                    'Wait Time',
                    style: Theme.of(context).primaryTextTheme.titleMedium,
                  ).tr()
                ],
              ),
              chatAvailabilityController.showAvailableTime == true
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: PrimaryTextWidget(
                              text: "Choose time for available"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 10),
                          child: const Text(
                            "Once wait time is over status will become Online",
                            style: TextStyle(fontSize: 09, color: Colors.grey),
                          ).tr(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: CommonTextFieldWidget(
                            onTap: () {
                              chatAvailabilityController
                                  .selectWaitTime(context);
                            },
                            hintText: tr("Choose Time"),
                            textEditingController:
                                chatAvailabilityController.waitTime,
                            readOnly: true,
                            keyboardType: TextInputType.none,
                          ),
                        ),
                      ],
                    ),
            ]);
          }),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: COLORS().primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          height: 45,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          child: TextButton(
            onPressed: () async {
              global.user.chatStatus =
                  chatAvailabilityController.chatStatusName;
              global.user.dateTime = chatAvailabilityController.waitTime.text;

              global.showOnlyLoaderDialog();
              await chatAvailabilityController.statusChatChange(
                  astroId: global.user.id!,
                  chatStatus: chatAvailabilityController.chatStatusName,
                  chatTime: chatAvailabilityController.waitTime.text);
              global.hideLoader();
              chatAvailabilityController.showAvailableTime = true;
              chatAvailabilityController.update();
              Get.back();
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.black),
            ).tr(),
          ),
        ),
      ),
    );
  }
}
