// ignore_for_file: library_private_types_in_public_api

import 'package:astrowaypartner/controllers/storiescontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class TextScreen extends StatefulWidget {
  const TextScreen({super.key});

  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final TextEditingController texcontroller = TextEditingController();
  final FocusNode textfocus = FocusNode();
  StoriesController storycontroller = Get.find<StoriesController>();
  @override
  void initState() {
    super.initState();
    // Focus on the text field after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(textfocus);
    });
  }

  List backgroundColors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.deepOrange
  ];
  int selectColors = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors[selectColors],
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: texcontroller,
                  focusNode: textfocus,
                  decoration: const InputDecoration(
                    counterText: "",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: 'your story here...',
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  maxLines: null,
                  maxLength: 90,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 22,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                  // Handle close button tap
                },
                child: Icon(
                  Icons.close,
                  size: 24.sp,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 22,
              right: 22,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      debugPrint("Select Colors :- $selectColors");
                      debugPrint("length:- ${backgroundColors.length}");
                      if (selectColors == backgroundColors.length - 1) {
                        setState(() {
                          selectColors = 0;
                        });
                      } else {
                        setState(() {
                          selectColors = selectColors + 1;
                        });
                      }

                      // Handle close button tap
                    },
                    child: Icon(
                      Icons.color_lens_outlined,
                      size: 24.sp,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      storycontroller.uploadText(texcontroller.text);
                      // Handle close button tap
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
