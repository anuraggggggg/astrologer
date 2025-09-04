import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateKundliTitleWidget extends StatelessWidget {
  final String? title;
  const CreateKundliTitleWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title!, style: Get.textTheme.headlineSmall);
  }
}
