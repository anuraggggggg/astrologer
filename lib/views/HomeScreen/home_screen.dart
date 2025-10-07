import 'dart:io';
import 'package:astrowaypartner/views/HomeScreen/Profile/profile_screen.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/homeTab/home_tab.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/payment_tab.dart';
import 'package:astrowaypartner/views/HomeScreen/tabs/profileTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedItemPosition = 0;
  int previousposition = 0;
  String walletAmount = "--"; // ✅ Safe placeholder

  @override
  void initState() {
    super.initState();
    // Removed direct API calls
    // You can trigger API calls later when needed
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("Jyotishi Pandit"), // ✅ Static Title
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadWalletAmount, // ✅ Safe call
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to wallet screen (dummy for now)
                  debugPrint("Wallet tapped");
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      const Text("₹"),
                      Text(walletAmount), // ✅ Will not break if null
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            height: height,
            color: Colors.grey.shade200,
            child: _buildSelectedTab(), // ✅ Safe rendering
          ),
          bottomNavigationBar: SizedBox(
            height: 7.7.h,
            child: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.pinned,
              snakeViewColor: Colors.grey.shade500,
              unselectedItemColor: Colors.blueGrey,
              showUnselectedLabels: true,
              showSelectedLabels: true,
              currentIndex: _selectedItemPosition,
              onTap: (value) {
                setState(() {
                  previousposition = _selectedItemPosition;
                  _selectedItemPosition = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.videocam), label: "Live"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.history), label: "History"),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person), label: "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedItemPosition) {
      case 0:
        return const HomeTabScreen();
      case 1:
        return const Center(child: Text("Live Tab"));
      case 2:
        return const PaymentHistoryTab();
      case 3:
        return ProfileTabScreen();
      default:
        return const SizedBox();
    }
  }

  void _loadWalletAmount() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        walletAmount = "500"; // ✅ Mock Data
      });
    } catch (e) {
      debugPrint("Error loading wallet: $e");
      setState(() {
        walletAmount = "--"; // fallback
      });
    }
  }
}
