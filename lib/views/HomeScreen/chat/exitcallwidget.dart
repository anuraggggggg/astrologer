 import 'package:flutter/material.dart';


void showExitDialog(BuildContext context, String title , Function(bool isleave) leave ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('Are you sure you want to exit the $title ?'),
        actions: [
          TextButton(
            onPressed: () {
                leave(false);
            }, // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              debugPrint("ajsndkjbns");
              debugPrint("ontab");
              leave(true);
           
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
