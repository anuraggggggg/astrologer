// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:astrowaypartner/controllers/kundli_matchig_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KundliDialog extends StatefulWidget {
  const KundliDialog({super.key});

  @override
  _MyDialogState createState() => _MyDialogState();
}

final KundliMatchingController kundliMatchingController =
    Get.find<KundliMatchingController>();

class _MyDialogState extends State<KundliDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Direaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('South'),
            leading: Radio(
              value: 'South',
              groupValue: kundliMatchingController.selectedDirection,
              onChanged: (value) {
                setState(() {});
                kundliMatchingController.onDireactionChanged(value.toString());
              },
            ),
          ),
          ListTile(
            title: const Text('North'),
            leading: Radio(
              value: 'North',
              groupValue: kundliMatchingController.selectedDirection,
              onChanged: (value) {
                setState(() {});
                kundliMatchingController.onDireactionChanged(value.toString());
              },
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Get.back();

            await kundliMatchingController.addKundliMatchData(true);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
