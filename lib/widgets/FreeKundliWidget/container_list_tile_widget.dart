import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContainerListTileWidget extends StatelessWidget {
  final Color? color;
  final String? doshText;
  final String? title;
  final String? subTitle;
  const ContainerListTileWidget(
      {super.key, this.title, this.subTitle, this.doshText, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: color!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: CircleAvatar(
          radius: 40,
          backgroundColor: color,
          child: Text(
            doshText!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          title!,
          style: title == ''
              ? const TextStyle(fontSize: 0)
              : Get.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        subtitle: Text(subTitle!,
            style: Theme.of(context).primaryTextTheme.titleSmall),
      ),
    );
  }
}
