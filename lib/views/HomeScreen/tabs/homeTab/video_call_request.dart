import 'package:flutter/material.dart';

class VideoCallRequests extends StatelessWidget {
  const VideoCallRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.videocam, color: Colors.blue),
            title: Text("Rahul Verma"),
            subtitle: Text("Requested a video call"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.videocam, color: Colors.blue),
            title: Text("Priya Sharma"),
            subtitle: Text("Requested a video call"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ],
    );
  }
}
