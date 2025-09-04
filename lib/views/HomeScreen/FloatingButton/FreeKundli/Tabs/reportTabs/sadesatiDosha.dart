// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class SadesatiDosha extends StatelessWidget {
  SadesatiDosha({super.key});
  KundliController kundliController = Get.find<KundliController>();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(children: [
        const SizedBox(
          height: 10,
        ),
        Text('Sadesati Analysis',
                style: Get.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold))
            .tr(),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
                color:
                    kundliController.isSadesati! ? Colors.red : Colors.green),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Text(
                'Current Sadesati Status',
                style: Get.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ).tr(),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: kundliController.isSadesati!
                        ? Colors.red
                        : Colors.green,
                    child: Text(
                      kundliController.isSadesati! ? 'Yes' : 'No',
                      style: const TextStyle(color: Colors.white),
                    ).tr(),
                  ),
                ],
              )
            ],
          ),
        ),
      ]),
    );
  }
}
