// ignore_for_file: file_names

import 'package:astrowaypartner/controllers/free_kundli_controller.dart';
import 'package:astrowaypartner/widgets/FreeKundliWidget/container_list_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class KalsarpaDosha extends StatelessWidget {
  KalsarpaDosha({super.key});
  KundliController kundliController = Get.find<KundliController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text('Kalsarpa Analysis',
                    style: Get.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold))
                .tr(),
            const SizedBox(
              height: 10,
            ),
            ContainerListTileWidget(
              title: tr('Kalsarpa'),
              subTitle: tr('Kundli is free from kalsharrpa dosha'),
              doshText: kundliController.isKalsarpa! ? 'Yes' : 'No',
              color: kundliController.isKalsarpa! ? Colors.red : Colors.green,
            ),
          ]),
    );
  }
}
