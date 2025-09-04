// ignore_for_file: file_names

import 'package:astrowaypartner/constants/colorConst.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommonSmallTextFieldWidget extends StatelessWidget {
  final String? titleText;
  final String? hintText;
  final IconData? preFixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool? readOnly;
  final int? maxLines;
  final double? height;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;

  const CommonSmallTextFieldWidget({
    super.key,
    this.titleText,
    this.hintText,
    this.preFixIcon,
    required this.controller,
    this.keyboardType,
    this.readOnly,
    this.maxLines,
    this.onTap,
    this.onFieldSubmitted,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            tr(titleText ?? tr("textfield Name Not Defined")),
            style: Theme.of(context).primaryTextTheme.displaySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            height: height ?? 35,
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              onFieldSubmitted: onFieldSubmitted,
              onTap: onTap,
              readOnly: readOnly ?? false,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              keyboardType: keyboardType ?? TextInputType.text,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
                helperStyle: TextStyle(color: COLORS().primaryColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(6),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: COLORS().primaryColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                hintText: hintText,
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    preFixIcon ?? Icons.no_accounts,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
