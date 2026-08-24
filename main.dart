import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GoVoiceChatApp());
}

class GoVoiceChatApp extends StatelessWidget {
  const GoVoiceChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Voice Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// 1. लॉगिन स्क्रीन
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Login Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic_rounded, size: 80, color: Colors.pinkAccent),
                const SizedBox(height: 20),
                const Text(
                  "Go Voice Chat",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Sign in with Google", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
                const Text("OR", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Phone Number (+91...)",
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent)),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Phone OTP verification ready!")),
                    );
                  },
                  child: const Text("Get OTP", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. मुख्य नेविगेशन स्क्रीन (नीचे 4 टैब्स)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SquareScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1A1A2E),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Square'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}

// टैब 1: होम स्क्रीन (वॉयस रूम)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Rooms"),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VoiceChatRoomScreen()),
            );
          },
          child: const Text("Join 'प्यारे बाबा 2' Room (#101)", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

// टैब 2: स्क्वायर स्क्रीन
class SquareScreen extends StatelessWidget {
  const SquareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Square Moments"),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: const Center(
        child: Text("Moments & Video Status Feed", style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}

// टैब 3: मैसेज स्क्रीन
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages & Friends"),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: const Center(
        child: Text("Direct Chats & Calling", style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}

// टैब 4: प्रोफाइल स्क्रीन ('Me')
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: Colors.pink),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("KARAN (Master Owner)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("ID: 1526476546\n👑 VIP Gold Member", style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () => FirebaseAuth.instance.signOut(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                            child: const Text("My Account\n💎 1,500", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                            child: const Text("My Ruby\n🪙 5,000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2C),
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.amberAccent),
                ),
                icon: const Icon(Icons.workspace_premium, color: Colors.amberAccent),
                label: const Text("VIP / SVIP Badge & Frame Store", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VipStoreScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.pinkAccent),
                ),
                icon: const Icon(Icons.admin_panel_settings, color: Colors.pinkAccent),
                label: const Text("App Admin & Moderator Panel", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppAdminDashboardScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VipStoreScreen extends StatelessWidget {
  const VipStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> badges = [
      {"name": "Dark Icon VIP Badge", "price": "999 Diamonds", "type": "Badge"},
      {"name": "Royal SVIP Crown Frame", "price": "2999 Diamonds", "type": "Frame"},
      {"name": "Golden Dragon Entry Effect", "price": "4999 Diamonds", "type": "Effect"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("VIP & SVIP Store", style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final item = badges[index];
          return Card(
            color: const Color(0xFF1E1E2C),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.verified, color: Colors.amberAccent, size: 36),
              title: Text(item["name"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("Price: ${item["price"]}", style: const TextStyle(color: Colors.white54)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Successfully purchased ${item["name"]}! 🎉")),
                  );
                },
                child: const Text("Buy", style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppAdminDashboardScreen extends StatelessWidget {
  const AppAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("App Admin & Moderator Dashboard", style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("System Overview", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(10)),
                  child: const Column(
                    children: [
                      Text("Total Users", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      SizedBox(height: 5),
                      Text("1,245", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(10)),
                  child: const Column(
                    children: [
                      Text("Active Rooms", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      SizedBox(height: 5),
                      Text("38", style: TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 5. 14-सीटर वॉयस चैट रूम स्क्रीन (PK Battle, Voice Changer, Theme, Games, Gifts के साथ)
class VoiceChatRoomScreen extends StatefulWidget {
  const VoiceChatRoomScreen({super.key});

  @override
  State<VoiceChatRoomScreen> createState() => _VoiceChatRoomScreenState();
}

class _VoiceChatRoomScreenState extends State<VoiceChatRoomScreen> {
  final List<String> _chatMessages = [
    "प्यारे बाबा 2: Welcome to the official room!",
    "@KARAN WC DEAR 🍻",
    "@missyoull very good baby"
  ];
  final TextEditingController _msgController = TextEditingController();

  Color _roomBgColor = const Color(0xFF241005);
  bool _isPkActive = false; // PK बैटल स्टेटस

  final List<bool> _isSeatLocked = List.generate(14, (index) => false);
  final List<bool> _isMicMuted = List.generate(14, (index) => false);

  final List<Map<String, dynamic>> _uniqueGifts = [
    {"name": "Royal Bicycle 🚲", "icon": Icons.directions_bike},
    {"name": "Golden Crown 👑", "icon": Icons.monetization_on},
    {"name": "Magic Rose 🌹", "icon": Icons.local_florist},
    {"name": "Super Car 🏎️", "icon": Icons.directions_car},
  ];

  final List<String> _customEmojis = ["🔥", "🍻", "🌹", "👑", "✨", "💎", "🎉", "❤️", "🚀", "🥰"];

  void _sendChatMessage({String text = ""}) {
    String msgToSend = text.isNotEmpty ? text : _msgController.text.trim();
    if (msgToSend.isNotEmpty) {
      setState(() {
        _chatMessages.add("KARAN: $msgToSend");
        if (text.isEmpty) _msgController.clear();
      });
    }
  }

  // वॉइस चेंजर डायलॉग
  void _showVoiceChangerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text("🎙️ Magic Voice Changer", style: TextStyle(color: Colors.amberAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.white54),
              title: const Text("Normal Voice", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice set to Normal")));
              },
            ),
            ListTile(
              leading: const Icon(Icons.child_care, color: Colors.pinkAccent),
              title: const Text("Kid / Baby Voice", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice changed to Kid! 👶")));
              },
            ),
            ListTile(
              leading: const Icon(Icons.android, color: Colors.greenAccent),
              title: const Text("Robot Voice", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice changed to Robot! 🤖")));
              },
            ),
          ],
        ),
      ),
    );
  }

  // PK बैटल शुरू करने का फंक्शन
  void _togglePkBattle() {
    setState(() {
      _isPkActive = !_isPkActive;
      if (_isPkActive) {
        _chatMessages.add("⚔️ Room PK Battle Started against opposing room!");
      } else {
        _chatMessages.add("⚔️ PK Battle Ended.");
      }
    });
  }

  void _showThemeChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text("🎨 Change Room Theme", style: TextStyle(color: Colors.amberAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Royal Brown (Default)", style: TextStyle(color: Colors.white)),
              trailing: const CircleAvatar(backgroundColor: Color(0xFF241005), radius: 15),
              onTap: () {
                setState(() => _roomBgColor = const Color(0xFF241005));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Dark Neon Night", style: TextStyle(color: Colors.white)),
              trailing: const CircleAvatar(backgroundColor: Color(0xFF0D1B2A), radius: 15),
              onTap: () {
                setState(() => _roomBgColor = const Color(0xFF0D1B2A));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Romantic Pink Velvet", style: TextStyle(color: Colors.white)),
              trailing: const CircleAvatar(backgroundColor: Color(0xFF2C0735), radius: 15),
              onTap: () {
                setState(() => _roomBgColor = const Color(0xFF2C0735));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("😊 Custom Emoji Pack", style: TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _customEmojis.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _sendChatMessage(text: _customEmojis[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(_customEmojis[index], style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGamesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎲 Room Mini-Games", style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.casino, color: Colors.greenAccent, size: 30),
              title: const Text("Ludo King Room", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Play Ludo with room members", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _chatMessages.add("🎲 Ludo Game Started in Room! Join now.");
                });
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.sports_baseball, color: Colors.pinkAccent, size: 30),
              title: const Text("Carrom Board", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Play Carrom with friends on seats", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _chatMessages.add("🎯 Carrom Board Game Started! Join now.");
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLuckyGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text("🎰 Lucky Spin Game", style: TextStyle(color: Colors.amberAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Spin the wheel to win 💎 Diamonds or 🪙 Rubies!", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
              ),
              child: const Center(
                child: Icon(Icons.star, size: 50, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _chatMessages.add("🎰 Lucky Spin: You won 500 Diamonds! 🎉");
              });
            },
            child: const Text("Spin Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAdminSeatOptions(int seatIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Control: Seat ${seatIndex + 1} ${seatIndex == 0 ? '(Host)' : ''}", 
              style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(_isSeatLocked[seatIndex] ? Icons.lock_open : Icons.lock, color: Colors.white),
              title: Text(_isSeatLocked[seatIndex] ? "Unlock Seat" : "Lock Seat", style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isSeatLocked[seatIndex] = !_isSeatLocked[seatIndex];
                });
              },
            ),
            ListTile(
              leading: Icon(_isMicMuted[seatIndex] ? Icons.mic : Icons.mic_off, color: Colors.greenAccent),
              title: Text(_isMicMuted[seatIndex] ? "Unmute Mic" : "Mute Mic", style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isMicMuted[seatIndex] = !_isMicMuted[seatIndex];
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.redAccent),
              title: const Text("Kick from Seat", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User kicked from seat 🚫")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftStore() {
    showModalButtonSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎁 Send Unique Room Gifts", style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemCount: _uniqueGifts.length,
                itemBuilder: (context, index) {
                  final gift = _uniqueGifts[index];
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2A3D)),
                    icon: Icon(gift["icon"], color: Colors.pinkAccent),
                    label: Text(gift["name"], style: const TextStyle(color: Colors.white, fontSize: 12)),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _chatMessages.add("🎁 Gift Sent: ${gift["name"]}!");
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _roomBgColor,
      appBar: AppBar(
        title: const Text("प्यारे बाबा 2 रूम (#101)", style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: const Color(0xFF1A0A02),
        actions: [
          // PK बैटल टॉगल बटन
          IconButton(
            icon: Icon(Icons.sports_kabaddi, color: _isPkActive ? Colors.redAccent : Colors.white70),
            onPressed: _togglePkBattle,
            tooltip: "Toggle PK Battle",
          ),
          // वॉइस चेंजर बटन
          IconButton(
            icon: const Icon(Icons.settings_voice, color: Colors.orangeAccent),
            onPressed: _showVoiceChangerDialog,
            tooltip: "Voice Changer",
          ),
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.cyanAccent),
            onPressed: _showThemeChangeDialog,
            tooltip: "Change Room Theme",
          ),
          IconButton(
            icon: const Icon(Icons.sports_esports, color: Colors.greenAccent),
            onPressed: _showGamesMenu,
            tooltip: "Ludo & Carrom Games",
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
            onPressed: _showGiftStore,
            tooltip: "Gifts",
          ),
        ],
      ),
      body: Column(
        children: [
          // यदि PK बैटल एक्टिव है तो ऊपर PK स्कोर प्रोग्रेस बार दिखेगा
          if (_isPkActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Team A: 12,450 💎", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                  Text("VS", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  Text("Team B: 9,820 💎", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          SizedBox(
            height: 260,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showAdminSeatOptions(0),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isSeatLocked[0] ? Colors.redAccent : Colors.amberAccent, 
                              width: 3
                            ),
                            color: const Color(0xFF3A1C08),
                          ),
                          child: Icon(
                            _isSeatLocked[0] ? Icons.lock : (_isMicMuted[0] ? Icons.mic_off : Icons.mic),
                            color: _isSeatLocked[0] ? Colors.redAccent : Colors.greenAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text("Host (VISHAL)", style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: 13,
                      itemBuilder: (context, index) {
                        int seatIdx = index + 1;
                        return GestureDetector(
                          onTap: () => _showAdminSeatOptions(seatIdx),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF331504),
                              border: Border.all(
                                color: _isSeatLocked[seatIdx] ? Colors.redAccent : Colors.amber.withOpacity(0.4), 
                                width: 2
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSeatLocked[seatIdx] ? Icons.lock : (_isMicMuted[seatIdx] ? Icons.mic_off : Icons.mic),
                                  color: _isSeatLocked[seatIdx] ? Colors.redAccent : Colors.white70,
                                  size: 14,
                                ),
                                Text("S${seatIdx + 1}", style: const TextStyle(color: Colors.white70, fontSize: 8)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Text(
              "Room Notice: प्यारे बाबा 2 के रूम के एडमिन न किसी को ऐड करते हैं... (OWNER: VISHAL 🍻)",
              style: TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_chatMessages[index], style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFF1A0A02),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.amberAccent),
                  onPressed: _showEmojiPicker,
                  tooltip: "Custom Emoji Pack",
                ),
                IconButton(
                  icon: const Icon(Icons.sports_esports, color: Colors.greenAccent),
                  onPressed: _showGamesMenu,
                ),
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
                  onPressed: _showGiftStore,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Say something...",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amberAccent),
                  onPressed: () => _sendChatMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
