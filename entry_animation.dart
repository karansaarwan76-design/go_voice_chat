import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

// Top 3 Exclusive Entry Announcement Widget
class DynamicUserEntryAnnouncement extends StatefulWidget {
  final String username;
  final bool isVip;
  final String themeType; // 'lion', 'thor', ya 'car'
  final VoidCallback onAnimationFinished;

  const DynamicUserEntryAnnouncement({
    Key? key,
    required this.username,
    required this.isVip,
    required this.themeType,
    required this.onAnimationFinished,
  }) : super(key: key);

  @override
  State<DynamicUserEntryAnnouncement> createState() => _DynamicUserEntryAnnouncementState();
}

class _DynamicUserEntryAnnouncementState extends State<DynamicUserEntryAnnouncement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    if (widget.isVip) {
      _playThemeSound(widget.themeType);
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -2.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onAnimationFinished();
        });
      }
    });
  }

  void _playThemeSound(String theme) async {
    try {
      String soundUrl = 'https://www.myinstants.com/media/sounds/lion-roar.mp3'; // Lion default
      
      if (theme == 'thor') {
        soundUrl = 'https://www.myinstants.com/media/sounds/thunder.mp3'; // Thunder sound
      } else if (theme == 'car') {
        soundUrl = 'https://www.myinstants.com/media/sounds/car-rev.mp3'; // Car drift sound
      }

      await _audioPlayer.play(UrlSource(soundUrl));
    } catch (e) {
      print("Audio play error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Decoration getThemeDecoration() {
    if (!widget.isVip) {
      return const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF9013FE)]),
      );
    }

    switch (widget.themeType) {
      case 'thor':
        return const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]), // Electric Blue
        );
      case 'car':
        return const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFE52D27), Color(0xFFB31217)]), // Racing Red
        );
      case 'lion':
      default:
        return const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFF8B0000)]), // Royal Gold-Red
        );
    }
  }

  IconData getThemeIcon() {
    if (!widget.isVip) return Icons.person_rounded;
    switch (widget.themeType) {
      case 'thor':
        return Icons.flash_on_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'lion':
      default:
        return Icons.pets_rounded;
    }
  }

  @override
  Widget build(context) {
    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: (getThemeDecoration() as BoxDecoration).gradient,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: widget.isVip ? Colors.amber.withOpacity(0.8) : Colors.purple.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(getThemeIcon(), color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isVip ? "👑 VIP [${widget.themeType.toUpperCase()}] ENTRY!" : "WELCOME",
                          style: const TextStyle(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.username} room mein enter hue hain!",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

// Admin Testing Panel for these 3 Entries
class AdminEntryTestController extends StatefulWidget {
  const AdminEntryTestController({Key? key}) : super(key: key);

  @override
  State<AdminEntryTestController> createState() => _AdminEntryTestControllerState();
}

class _AdminEntryTestControllerState extends State<AdminEntryTestController> {
  String? activeUserName;
  String activeTheme = 'lion';
  bool showBanner = false;

  void triggerTest(String name, String theme) {
    setState(() {
      activeUserName = name;
      activeTheme = theme;
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
                "Exclusive Entry Testing Panel",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => triggerTest("Karan (Admin)", "lion"),
                icon: const Icon(Icons.pets, color: Colors.black),
                label: const Text("Test 🦁 Lion Entry", style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                onPressed: () => triggerTest("Karan (Admin)", "thor"),
                icon: const Icon(Icons.flash_on, color: Colors.black),
                label: const Text("Test ⚡ Thor Entry", style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => triggerTest("Karan (Admin)", "car"),
                icon: const Icon(Icons.directions_car, color: Colors.white),
                label: const Text("Test 🏎️ F1 Car Entry"),
              ),
            ],
          ),
        ),
        if (showBanner)
          DynamicUserEntryAnnouncement(
            username: activeUserName ?? "User",
            isVip: true,
            themeType: activeTheme,
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

// Automatic 15/30 Days VIP Expiry & Recharge Functions
Future<void> grantVipPackage(String userId, int daysCount) async {
  DateTime expiryDate = DateTime.now().add(Duration(days: daysCount));

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'isVip': true,
    'vipExpiryDate': Timestamp.fromDate(expiryDate),
    'entryThemeActive': true,
  });
}

Future<void> checkAndUpdateVipStatus(String userId) async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists) {
    var data = userDoc.data() as Map<String, dynamic>;
    
    if (data['vipExpiryDate'] != null) {
      Timestamp expiryTimestamp = data['vipExpiryDate'];
      DateTime expiryDate = expiryTimestamp.zone == null ? expiryTimestamp.toDate() : expiryTimestamp.toDate();

      if (DateTime.now().isAfter(expiryDate)) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isVip': false,
          'entryThemeActive': false,
        });
      }
    }
  }
}
