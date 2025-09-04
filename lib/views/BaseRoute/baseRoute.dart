// ignore_for_file: prefer_const_constructors_in_immutables, file_names

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseRoute extends StatelessWidget {
  final dynamic a;
  final dynamic o;
  final String? r;

  BaseRoute({super.key, this.a, this.o, this.r});

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Future addAnalytics() async {
    a.setCurrentScreen(screenName: r);
  }

  Future exitAppDialog() async {
    Get.dialog(AlertDialog(
      title: const Text(
        'Exit',
      ).tr(),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return const Text('Are you sure you want to exit App?');
      }),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: Get.theme.primaryTextTheme.labelSmall,
          ).tr(),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: Text(
            'Exit',
            style: Get.theme.primaryTextTheme.labelSmall,
          ).tr(),
          onPressed: () async {
            exit(0);
            // Get.back();
          },
        ),
      ],
    ));
  }
}
