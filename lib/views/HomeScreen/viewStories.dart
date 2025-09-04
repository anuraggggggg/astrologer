// ignore_for_file: file_names, must_be_immutable, avoid_function_literals_in_foreach_calls

import 'package:astrowaypartner/controllers/storiescontroller.dart';
import 'package:astrowaypartner/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:sizer/sizer.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class ViewStoriesScreen extends StatefulWidget {
  String profile;
  String name;
  bool isprofile;
  int astroId;
  ViewStoriesScreen(
      {super.key,
      required this.profile,
      required this.name,
      required this.isprofile,
      required this.astroId});

  @override
  State<ViewStoriesScreen> createState() => _ViewStoriesScreenState();
}

class _ViewStoriesScreenState extends State<ViewStoriesScreen> {
  final controller = StoryController();
  List<StoryItem> storyItems = [];
  StoriesController storiesController = Get.find<StoriesController>();
  // final BottomNavigationController bottomNavigationController =
  // Get.find<BottomNavigationController>();

  @override
  void initState() {
    super.initState();
    storiesController.viewSingleStory.forEach((element) {
      if (element.mediaType.toString() == "video") {
        storyItems.add(StoryItem.pageVideo(
          "$imgBaseurl${element.media}",
          controller: controller,
          //duration: Duration(seconds: (5).toInt()),
        ));
      } else if (element.mediaType.toString() == "image") {
        storyItems.add(StoryItem.pageImage(
          url: "$imgBaseurl${element.media}",
          controller: controller,
          duration: Duration(
            seconds: (5).toInt(),
          ),
        ));
      } else if (element.mediaType.toString() == "text") {
        storyItems.add(StoryItem.text(
          title: element.media.toString(),
          backgroundColor: Colors.black,
          duration: Duration(
            seconds: (5).toInt(),
          ),
        ));
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            StoryView(
                controller: controller, // pass controller here too
                repeat: false, // should the stories be slid forever
                onStoryShow: (s, index) {
                  // storiesController.viewStory(storiesController.viewSingleStory[index].id.toString());
                },
                onComplete: () async {
                  // await storiesController.getAllStories();
                  Navigator.pop(context);
                },
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.pop(context);
                  }
                },
                storyItems:
                    storyItems // To disable vertical swipe gestures, ignore this parameter.
                // Preferrably for inline story view.
                ),
            Positioned(
              top: 20,
              left: 10,
              child: InkWell(
                onTap: () async {
                  // if(widget.isprofile)
                  // {
                  //   Navigator.pop(context);
                  // }else
                  // {
                  //   Get.find<ReviewController>().getReviewData(widget.astroId);
                  //   global.showOnlyLoaderDialog(context);
                  //   await bottomNavigationController
                  //       .getAstrologerbyId(widget.astroId);
                  //   global.hideLoader();
                  //   Get.to(() => AstrologerProfile(
                  //     index: 0,
                  //   ));
                  // }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(widget.profile),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      widget.name,
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
