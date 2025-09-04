//flutter
import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../controllers/HomeController/call_controller.dart';
import '../utils/config.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double? height;
  final double? elevation;
  final double? appbarPadding;
  final String? profile;
  final String? customername;
  final bool? centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final int? counterduration;

  const ChatAppBar({
    super.key,
    this.leading,
    this.elevation,
    this.centerTitle,
    this.actions,
    this.backgroundColor,
    @required this.height,
    this.appbarPadding,
    this.profile,
    this.customername,
    this.counterduration,
  });

  @override
  State<ChatAppBar> createState() => _MyCustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height ?? 80);
}

class _MyCustomAppBarState extends State<ChatAppBar> {
  int? subtitleCounter = 0;
  late Timer _timer;
  @override
  void initState() {
    log('innit called chat appbar }');

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: widget.appbarPadding ?? 0,
              bottom: widget.appbarPadding ?? 0),
          child: AppBar(
            elevation: widget.elevation ?? 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: CachedNetworkImage(
                    imageUrl: '$imgBaseurl${widget.profile}',
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 20,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/no_customer_image.png",
                      fit: BoxFit.fill,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                GetBuilder<CallController>(builder: (cllController) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          widget.customername?.isEmpty ?? true
                              ? "User"
                              : widget.customername!,
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      cllController.newIsStartTimer == true
                          ? status()
                          : Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'waiting to join..',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp),
                              ),
                            ),
                    ],
                  );
                }),
              ],
            ),
            centerTitle: widget.centerTitle,
            leading: widget.leading,
            actions: widget.actions,
            backgroundColor: widget.backgroundColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget status() {
    return CountdownTimer(
      endTime: DateTime.now().millisecondsSinceEpoch +
          1000 * widget.counterduration!,
      widgetBuilder: (_, CurrentRemainingTime? time) {
        if (time == null) {
          return const Text('');
        }
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: time.hours != null && time.hours != 0
              ? Text(
                  '${time.hours} H ${time.min} min ${time.sec} sec',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10.sp,
                      color: Colors.black),
                )
              : time.min != null
                  ? Text(
                      '${time.min} min ${time.sec} sec',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                          color: Colors.black),
                    )
                  : Text(
                      '${time.sec} sec',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                          color: Colors.black),
                    ),
        );
      },
      onEnd: () {},
    );
  }
}
