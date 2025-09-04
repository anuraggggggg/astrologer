import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrimaryTextWidget extends StatelessWidget {
  const PrimaryTextWidget({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: tr(text ?? ""),
        style: Theme.of(context).primaryTextTheme.titleSmall,
        children: const <TextSpan>[
          TextSpan(
            text: "*",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
