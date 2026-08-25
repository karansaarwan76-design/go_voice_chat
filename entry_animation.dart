import 'package:flutter/material.dart';

// 1. Entry Animation & Banner Widget
class UserEntryAnnouncement extends StatefulWidget {
  final String username;
  final bool isVip;
  final VoidCallback onAnimationFinished;

  const UserEntryAnnouncement({
    Key? key,
    required this.username,
    required this.isVip,
    required this.onAnimationFinished,
  }) : super(key: key);

  @override
  State<UserEntryAnnouncement> createState() => _UserEntryAnnouncementState();
}

class _UserEntryAnnouncementState extends State<UserEntryAnnouncement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onAnimationFinished();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.isVip
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF4500)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF9013FE)],
                      ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: widget.isVip
                        ? Colors.amber.withOpacity(0.7)
                        : Colors.purple.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isVip ? Icons.star_rounded : Icons.person_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isVip
                          ? "👑 VIP Entry: ${widget.username} Room mein enter hue hain!"
                          : "👋 Welcome: ${widget.username} join kiya hai!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 2. Admin Testing Panel Widget
class AdminEntryTestController extends StatefulWidget {
  const AdminEntryTestController({Key? key}) : super(key: key);

  @override
  State<AdminEntryTestController> createState() => _AdminEntryTestControllerState();
}

class _AdminEntryTestControllerState extends State<AdminEntryTestController> {
  String? activeUserName;
  bool activeIsVip = false;
  bool showBanner = false;

  void triggerTest(String name, bool isVip) {
    setState(() {
      activeUserName = name;
      activeIsVip = isVip;
      showBanner = true;
    });
  }

  @override
  Widget build(context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Admin Entry Testing Panel",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => triggerTest("Karan (Admin)", true),
                icon: const Icon(Icons.star, color: Colors.black),
                label: const Text("Test VIP Entry Animation", style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () => triggerTest("New User", false),
                icon: const Icon(Icons.person, color: Colors.white),
                label: const Text("Test Normal Entry Animation"),
              ),
            ],
          ),
        ),
        if (showBanner)
          UserEntryAnnouncement(
            username: activeUserName ?? "User",
            isVip: activeIsVip,
            onAnimationFinished: () {
              setState(() {
                showBanner = false;
              });
            },
          ),
      ],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

// User ke recharge ya ID update karne par yeh function chalega
Future<void> grantVipPackage(String userId, int daysCount) async {
  // Current date mein 15 ya 30 din jodna
  DateTime expiryDate = DateTime.now().add(Duration(days: daysCount));

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'isVip': true,
    'vipExpiryDate': Timestamp.fromDate(expiryDate), // Expiry time save ho gaya
    'entryThemeActive': true,
  });
}

// App khulte hi check karne ke liye ki VIP pack expire toh nahi ho gaya
Future<void> checkAndUpdateVipStatus(String userId) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists) {
    var data = userDoc.data() as Map<String, dynamic>;
    
    if (data['vipExpiryDate'] != null) {
      Timestamp expiryTimestamp = data['vipExpiryDate'];
      DateTime expiryDate = expiryTimestamp.toDate();

      // Agar current time expiry date se zyada ho gaya hai, toh VIP hata do
      if (DateTime.now().isAfter(expiryDate)) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isVip': false,
          'entryThemeActive': false,
        });
      }
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Recharge ya ID update hone par 15 ya 30 din ke liye VIP activate karne ka function
Future<void> grantVipPackage(String userId, int daysCount) async {
  // Current date mein 15 ya 30 din aage ka time jodd rahe hain
  DateTime expiryDate = DateTime.now().add(Duration(days: daysCount));

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'isVip': true,
    'vipExpiryDate': Timestamp.fromDate(expiryDate),
    'entryThemeActive': true,
  });
}

// 2. App khulte hi check karne ka function ki VIP pack expire toh nahi hua
Future<void> checkAndUpdateVipStatus(String userId) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists) {
    var data = userDoc.data() as Map<String, dynamic>;
    
    if (data['vipExpiryDate'] != null) {
      Timestamp expiryTimestamp = data['vipExpiryDate'];
      DateTime expiryDate = expiryTimestamp.toDate();

      // Agar time khatam ho chuka hai, toh VIP status automatic hata do
      if (DateTime.now().isAfter(expiryDate)) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isVip': false,
          'entryThemeActive': false,
        });
      }
    }
  }
}
