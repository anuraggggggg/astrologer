// ignore_for_file: file_names

import 'package:astrowaypartner/widgets/FreeKundliWidget/container_list_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManglikDosh extends StatelessWidget {
  const ManglikDosh({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manglik Analysis',
                  style: Get.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold))
              .tr(),
          const SizedBox(
            height: 10,
          ),
          const ContainerListTileWidget(
            title: '',
            subTitle: '',
            doshText: 'No',
            color: Colors.green,
          ),
          const SizedBox(
            height: 10,
          ),
          Text('This is a computer generated result. Please consult an Astrologer to confirm & understand this in detail.',
                  style: Get.textTheme.titleMedium!
                      .copyWith(fontSize: 12, color: Colors.grey))
              .tr()
        ],
      ),
    );
  }
}
