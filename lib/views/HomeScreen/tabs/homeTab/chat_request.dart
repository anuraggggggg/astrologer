import 'package:flutter/material.dart';

class ChatRequests extends StatelessWidget {
  const ChatRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.chat, color: Colors.orange),
            title: Text("Amit Patil"),
            subtitle: Text("Requested a chat session"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.chat, color: Colors.orange),
            title: Text("Sneha Kapoor"),
            subtitle: Text("Requested a chat session"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ],
    );
  }
}
