// ignore_for_file: file_names, must_be_immutable

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:astrowaypartner/controllers/Authentication/signup_controller.dart';
import 'package:astrowaypartner/widgets/app_bar_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailabiltyScreen extends StatelessWidget {
  AvailabiltyScreen({super.key});
  SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        height: 80,
        backgroundColor: COLORS().primaryColor,
        title: const Text("Availability").tr(),
      ),
      body: GetBuilder<SignupController>(
        builder: (c) {
          return signupController.astrologerList[0]!.week!.isEmpty || signupController.astrologerList[0]!.week == []
              ? Center(
                  child: const Text("You don't have time yet!").tr(),
                )
              : GetBuilder<SignupController>(
                  builder: (c) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: signupController.astrologerList[0]!.week?.length,
                      itemBuilder: ((context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                signupController.astrologerList[0]!.week![index].day!,
                                style: Theme.of(context).primaryTextTheme.displaySmall,
                              ),
                            ),
                            signupController.astrologerList[0]!.week![index].timeAvailabilityList!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(),
                                    child: Container(
                                      height: 30,
                                      width: Get.width,
                                      color: Colors.transparent,
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: signupController.astrologerList[0]!.week?[index].timeAvailabilityList?.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (BuildContext context, int index5) {
                                          return (signupController.astrologerList[0]!.week![index].timeAvailabilityList![index5].fromTime != "" && signupController.astrologerList[0]!.week![index].timeAvailabilityList![index5].toTime != "")
                                              ? Container(
                                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                                  color: Colors.grey[300],
                                                  child: Row(
                                                    children: [
                                                      Text("${signupController.astrologerList[0]!.week![index].timeAvailabilityList![index5].fromTime} - ${signupController.astrologerList[0]!.week![index].timeAvailabilityList![index5].toTime}"),
                                                      const SizedBox(width: 5),
                                                      index5 != signupController.astrologerList[0]!.week![index].timeAvailabilityList!.length - 1
                                                          ? const VerticalDivider(
                                                              thickness: 2,
                                                              color: Colors.grey,
                                                            )
                                                          : const SizedBox()
                                                    ],
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: const Text("No time added").tr(),
                                                );
                                        },
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: const Text("No time added").tr(),
                                  ),
                            const Divider()
                          ],
                        );
                      }),
                    );
                  },
                );
        },
      ),
    );
  }
}
