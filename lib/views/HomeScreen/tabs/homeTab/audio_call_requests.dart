import 'package:flutter/material.dart';

class AudioCallRequests extends StatelessWidget {
  const AudioCallRequests({super.key});

  @override
  Widget build(BuildContext context) {
    // Later replace with ListView.builder and fetch API data
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.call, color: Colors.green),
            title: Text("John Doe"),
            subtitle: Text("Requested an audio call"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.call, color: Colors.green),
            title: Text("Jane Smith"),
            subtitle: Text("Requested an audio call"),
          ),
        ),
      ],
    );
  }
}
