// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../constants/messageConst.dart';
import '../../controllers/notification_controller.dart';
import '../../widgets/app_bar_widget.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final notificationController = Get.find<NotificationController>();
  Color getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    double height = Get.height;
    double width = Get.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyCustomAppBar(
          backgroundColor: Get.theme.primaryColor,
          height: 80,
          title: Text(
            "Notification",
            style: TextStyle(fontSize: 16.sp, color: Colors.black),
          ).tr(),
          actions: [
            IconButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    titleTextStyle: Get.textTheme.bodyLarge,
                    title: const Text(
                            "Are you sure you want delete all notifications?")
                        .tr(),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text(MessageConstants.No).tr(),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Get.back(); //back from dialog
                            await notificationController
                                .deleteAllNotification();
                          },
                          child: const Text(MessageConstants.YES).tr(),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.delete, color: Colors.black),
            ),
          ],
        ),
        body: GetBuilder<NotificationController>(
          builder: (notificationController) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: height,
              width: width,
              child: notificationController.notificationList.isEmpty
                  ? Center(child: const Text('No Notification is here').tr())
                  : ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 1.h);
                      },
                      itemCount: notificationController.notificationList.length,
                      itemBuilder: (context, index) {
                        String formattedDate = DateFormat("dd/MMM/yyyy hh:mm a")
                            .format(DateTime.parse(notificationController
                                .notificationList[index].updatedAt
                                .toString()));

                        debugPrint('date time is $formattedDate');
                        debugPrint(
                            'title is ${notificationController.notificationList[index].title}');
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: notificationController
                                            .notificationList[index]
                                            .callStatus ==
                                        'Rejected' ||
                                    notificationController
                                            .notificationList[index]
                                            .chatStatus ==
                                        'Rejected' ||
                                    notificationController
                                            .notificationList[index]
                                            .callStatus ==
                                        'Accepted' ||
                                    notificationController
                                            .notificationList[index]
                                            .chatStatus ==
                                        'Accepted'
                                ? const Color(0xffffe5d4)
                                : Colors.grey.shade200,
                          ),
                          height: 16.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 4.h,
                                  width: width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("WOAH!".toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontSize: 10.sp,
                                                  color:
                                                      const Color(0xff423934))),
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      Text(
                                        formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 8.sp,
                                              color: const Color(0xffab9d94),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${notificationController.notificationList[index].title}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: 11.sp,
                                          color: const Color(0xff83786e)),
                                ),
                                notificationController.notificationList[index]
                                        .description!.isNotEmpty
                                    ? Text(
                                        '${notificationController.notificationList[index].description}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 11.sp,
                                                color: const Color(0xff83786e)),
                                      )
                                    : SizedBox(
                                        height: 2.h,
                                      ),
                              ]),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
