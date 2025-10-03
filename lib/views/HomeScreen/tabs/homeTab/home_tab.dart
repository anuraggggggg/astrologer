import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/chat_request.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/video_call_request.dart';
import 'package:flutter/material.dart';
import 'audio_call_requests.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.yellow[100],
          backgroundColor: Colors.white,
          title: const Text(
            "Requests",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFC400)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorPadding: const EdgeInsets.all(6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          const Text("Audio"),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam,
                              size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          const Text("Video"),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          const Text("Chat"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow[50]!,
                Colors.yellow[100]!,
                Colors.white,
              ],
            ),
          ),
          child: const TabBarView(
            children: [
              AudioCallRequests(),
              VideoCallRequests(),
              ChatRequests(),
            ],
          ),
        ),
      ),
    );
  }
}
