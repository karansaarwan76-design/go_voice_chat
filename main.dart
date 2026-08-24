import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // रियल-टाइम डेटाबेस के लिए

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
        child: Text("Moments & Video Status Feed (Firestore Ready)", style: TextStyle(color: Colors.white54)),
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("VIP & SVIP Store", style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: const Center(
        child: Text("VIP Store Connected with Firestore", style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}

// 5. 14-सीटर वॉयस चैट रूम (Firestore Real-time Chat Integration)
class VoiceChatRoomScreen extends StatefulWidget {
  const VoiceChatRoomScreen({super.key});

  @override
  State<VoiceChatRoomScreen> createState() => _VoiceChatRoomScreenState();
}

class _VoiceChatRoomScreenState extends State<VoiceChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  Color _roomBgColor = const Color(0xFF241005);
  bool _isPkActive = false;

  final List<bool> _isSeatLocked = List.generate(14, (index) => false);
  final List<bool> _isMicMuted = List.generate(14, (index) => false);

  // फायरबेस में लाइव चैट भेजने का फंक्शन
  void _sendFirestoreMessage({String text = ""}) async {
    String msg = text.isNotEmpty ? text : _msgController.text.trim();
    if (msg.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc('room_101')
            .collection('chats')
            .add({
          'sender': 'KARAN',
          'message': msg,
          'timestamp': FieldValue.serverTimestamp(),
        });
        if (text.isEmpty) _msgController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending message: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _roomBgColor,
      appBar: AppBar(
        title: const Text("प्यारे बाबा 2 रूम (#101 - Live)", style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: const Color(0xFF1A0A02),
        actions: [
          IconButton(
            icon: Icon(Icons.sports_kabaddi, color: _isPkActive ? Colors.redAccent : Colors.white70),
            onPressed: () => setState(() => _isPkActive = !_isPkActive),
          ),
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.cyanAccent),
            onPressed: () {
              setState(() {
                _roomBgColor = _roomBgColor == const Color(0xFF241005) 
                    ? const Color(0xFF0D1B2A) 
                    : const Color(0xFF241005);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
            height: 240,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amberAccent, width: 3),
                      color: const Color(0xFF3A1C08),
                    ),
                    child: const Icon(Icons.mic, color: Colors.greenAccent, size: 26),
                  ),
                  const SizedBox(height: 2),
                  const Text("Host (VISHAL)", style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF331504),
                            border: Border.all(color: Colors.amber.withOpacity(0.4), width: 2),
                          ),
                          child: Center(
                            child: Text("S${index + 2}", style: const TextStyle(color: Colors.white70, fontSize: 8)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // रियल-टाइम फायरबेस चैट स्ट्रीमबिल्डर
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc('room_101')
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                }
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${data['sender'] ?? 'User'}: ${data['message'] ?? ''}",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    );
                  },
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
                  onPressed: () => _sendFirestoreMessage(text: "🔥"),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type live message...",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amberAccent),
                  onPressed: () => _sendFirestoreMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
