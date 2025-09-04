// ignore_for_file: must_be_immutable, file_names

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/callAvailability_controller.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:astrowaypartner/widgets/common_textfield_widget.dart';
import 'package:astrowaypartner/widgets/primary_text_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:astrowaypartner/utils/global.dart' as global;
import 'package:get/get.dart';

class CallAvailabilityScreen extends StatelessWidget {
  CallAvailabilityScreen({super.key});

  CallAvailabilityController callAvailabilityController =
      Get.find<CallAvailabilityController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(
            height: 80,
            backgroundColor: COLORS().primaryColor,
            title: const Text("Call Availability").tr()),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child:
              GetBuilder<CallAvailabilityController>(builder: (callAvaialble) {
            return Column(children: [
              ListTile(
                enabled: true,
                tileColor: Colors.white,
                title: Center(
                  child: Text(
                    "Change your availability for call",
                    style: Theme.of(context).primaryTextTheme.displaySmall,
                  ).tr(),
                ),
              ),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: callAvailabilityController.callType,
                    activeColor: COLORS().primaryColor,
                    onChanged: (val) {
                      callAvailabilityController.setCallAvailability(
                          val, "Online");
                      callAvailabilityController.showAvailableTime = true;
                      callAvailabilityController.update();
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
                    groupValue: callAvailabilityController.callType,
                    activeColor: COLORS().primaryColor,
                    onChanged: (val) {
                      callAvailabilityController.setCallAvailability(
                          val, "Offline");
                      callAvailabilityController.showAvailableTime = true;
                      callAvailabilityController.update();
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
                    groupValue: callAvailabilityController.callType,
                    activeColor: COLORS().primaryColor,
                    onChanged: (val) {
                      callAvailabilityController.setCallAvailability(
                          val, "Wait Time");
                      callAvailabilityController.showAvailableTime = false;
                      callAvailabilityController.update();
                    },
                  ),
                  Text(
                    'Wait Time',
                    style: Theme.of(context).primaryTextTheme.titleMedium,
                  ).tr()
                ],
              ),
              callAvailabilityController.showAvailableTime == true
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
                              callAvailabilityController
                                  .selectWaitTime(context);
                            },
                            hintText: tr("Choose Time"),
                            textEditingController:
                                callAvailabilityController.waitTime,
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
              global.user.callStatus =
                  callAvailabilityController.callStatusName;
              global.user.dateTime = callAvailabilityController.waitTime.text;
              global.showOnlyLoaderDialog();
              //! Set Call Availibility Status online offline wait
              await callAvailabilityController.statusCallChange(
                  astroId: global.user.id!,
                  callStatus: callAvailabilityController.callStatusName,
                  callTime: callAvailabilityController.waitTime.text);
              global.hideLoader();
              callAvailabilityController.showAvailableTime = true;
              callAvailabilityController.update();
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
