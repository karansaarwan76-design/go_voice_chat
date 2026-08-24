import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GoVoiceChatApp());
}

}

class AppTheme {
  final String name;
  final List<Color> backgroundGradient;
  final Color cardColor;

  AppTheme({required this.name, required this.backgroundGradient, required this.cardColor});
}

class GoVoiceChatApp extends StatefulWidget {
  const GoVoiceChatApp({Key? key}) : super(key: key);

  @override
  State<GoVoiceChatApp> createState() => _GoVoiceChatAppState();
}

class _GoVoiceChatAppState extends State<GoVoiceChatApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Voice Chat',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: const Color(0xFF0F1021),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 0. Login & Sign Up Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF2C1030), Color(0xFF0F1021), Color(0xFF050510)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.spatial_audio_off, color: Colors.pinkAccent, size: 70),
                const SizedBox(height: 10),
                const Text("Go Voice Chat 🎙️", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text("Login or Sign up to continue", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 30),
                
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: Colors.pinkAccent),
                    hintText: "Enter Mobile Number",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                
                if (otpSent) ...[
                  const SizedBox(height: 15),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_clock, color: Colors.amberAccent),
                      hintText: "Enter 4-Digit OTP",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ],

                const SizedBox(height: 25),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      if (_phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please enter phone number")));
                        return;
                      }
                      if (!otpSent) {
                        setState(() => otpSent = true);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📲 OTP Sent to your phone number!")));
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
                      }
                    },
                    child: Text(otpSent ? "Verify OTP & Login" : "Send OTP", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR", style: TextStyle(color: Colors.white54, fontSize: 12))),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✨ Google Account Selected! Logging in...")));
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
                    },
                    icon: const Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 30),
                    label: const Text("Continue with Gmail / Google", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Map<String, String>> joinedRoomsList = [];

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeBonusDialog(context);
    });
  }

  void _showWelcomeBonusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        title: const Text("🎁 Daily & Weekly Rewards!", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Welcome! Your daily & weekly rewards are ready:", style: TextStyle(color: Colors.white70)),
            SizedBox(height: 10),
            Text("🪙 5,000 Free Coins Added", style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            Text("🦁 3-Day Free Royal Entry Pass Active", style: TextStyle(color: Colors.pinkAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () => Navigator.pop(context),
            child: const Text("Claim Rewards!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeRoomsTab(),                        
      const MomentsVideosTab(),                        
      const MessagesTab(),                             
      const ProfileTab(),   
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF151628),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.video_collection), label: "Square"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
        ],
      ),
    );
  }
}

// --- 1. होम टैब (HomeRoomsTab) ---
class HomeRoomsTab extends StatefulWidget {
  const HomeRoomsTab({Key? key}) : super(key: key);

  @override
  State<HomeRoomsTab> createState() => _HomeRoomsTabState();
}

class _HomeRoomsTabState extends State<HomeRoomsTab> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _roomSubTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 4, vsync: this);
    _roomSubTabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF151628),
        title: TabBar(
          controller: _mainTabController,
          isScrollable: true,
          indicatorColor: Colors.pinkAccent,
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: "People"), Tab(text: "Room"), Tab(text: "Game"), Tab(text: "Explore"),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {})],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2C1030), Color(0xFF0F1021), Color(0xFF050510)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: TabBarView(
          controller: _mainTabController,
          children: [
            const Center(child: Text("People Nearby", style: TextStyle(color: Colors.white54))),
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.psychology_alt, color: Colors.white, size: 35),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("AI Vibe Match 🔮", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text("Find rooms based on your mood!", style: TextStyle(color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.pinkAccent, shape: const StadiumBorder()),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomScreen()));
                              },
                              child: const Text("Match Me", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            )
                          ],
                        ),
                      ),
                      TabBar(
                        controller: _roomSubTabController,
                        isScrollable: true,
                        indicatorColor: Colors.pinkAccent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        tabs: const [Tab(text: "Hot"), Tab(text: "Joined"), Tab(text: "Talent Show"), Tab(text: "Game"), Tab(text: "Dating"), Tab(text: "Party")],
                      ),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                controller: _roomSubTabController,
                children: [
                  _buildRoomGrid(context, isJoinedTab: false),
                  _buildRoomGrid(context, isJoinedTab: true),
                  const Center(child: Text("Talent Show Rooms", style: TextStyle(color: Colors.white54))),
                  const Center(child: Text("Game Rooms", style: TextStyle(color: Colors.white54))),
                  const Center(child: Text("Dating Rooms", style: TextStyle(color: Colors.white54))),
                  const Center(child: Text("Party Rooms", style: TextStyle(color: Colors.white54))),
                ],
              ),
            ),
            const Center(child: Text("Game Center", style: TextStyle(color: Colors.white54))),
            const Center(child: Text("Explore Community", style: TextStyle(color: Colors.white54))),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomGrid(BuildContext context, {required bool isJoinedTab}) {
    List<Map<String, String>> roomsToShow = isJoinedTab ? joinedRoomsList : [
      {"title": "✨jai ➳MAHAKALI✨di", "host": "KARAN", "count": "59", "tag": "Hot"},
      {"title": "🔥 Baba Pyare Ashram", "host": "Baba", "count": "46", "tag": "Party"},
      {"title": "💎 VIP High Class Room", "host": "Alisha", "count": "32", "tag": "Dating"},
      {"title": "🎵 Music & Chill Night", "host": "Rahul", "count": "18", "tag": "Talent"},
    ];

    if (isJoinedTab && roomsToShow.isEmpty) return const Center(child: Text("No joined rooms yet. Visit any room from Hot!", style: TextStyle(color: Colors.white54, fontSize: 12)));

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
      itemCount: roomsToShow.length,
      itemBuilder: (context, index) {
        var room = roomsToShow[index];
        return GestureDetector(
          onTap: () {
            if (!joinedRoomsList.any((r) => r['title'] == room['title'])) setState(() => joinedRoomsList.add(room));
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomScreen()));
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.pinkAccent.withOpacity(0.4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.2), borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                    child: const Center(child: Icon(Icons.mic, color: Colors.pinkAccent, size: 40)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room['title']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Host: ${room['host']}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(room['count']!, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- 2. स्क्वायर टैब ---
class MomentsVideosTab extends StatelessWidget {
  const MomentsVideosTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(title: const Text("Square & Moments 📹"), backgroundColor: const Color(0xFF151628)),
      body: ListView(
        children: [
          _buildMomentPost("KARAN", "✨ #i___love___my___jaan_@❤️+Alisha", "Enjoying the night in Go Voice Chat room! 🚀"),
        ],
      ),
    );
  }

  Widget _buildMomentPost(String name, String mention, String text) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 18, backgroundColor: Colors.pinkAccent, child: Text("K")),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(mention, style: const TextStyle(color: Colors.pinkAccent, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            height: 160,
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.pinkAccent, size: 45)),
          ),
        ],
      ),
    );
  }
}

// --- 3. मैसेज टैब ---
class MessagesTab extends StatelessWidget {
  const MessagesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(title: const Text("Messages & Inbox 💬"), backgroundColor: const Color(0xFF151628)),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.pink, child: Text("M")),
            title: const Text("❤️+Moon!! ♂36", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Not connected 📞", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
            trailing: const Text("01:52", style: TextStyle(color: Colors.grey, fontSize: 10)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailScreen())),
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(
        title: const Text("❤️+Moon!!"),
        backgroundColor: const Color(0xFF151628),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.greenAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📞 Calling user...")));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Align(alignment: Alignment.centerRight, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(12)), child: const Text("good morning my sweet heart"))),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(12)), child: const Text("i love you my sweet heart ❤️"))),
              ],
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ActionChip(label: const Text("😊 Hi"), onPressed: () {}), const SizedBox(width: 6),
                ActionChip(label: const Text("😘 Miss you"), onPressed: () {}), const SizedBox(width: 6),
                ActionChip(label: const Text("🌙 Good night"), onPressed: () {}), const SizedBox(width: 6),
                ActionChip(label: const Text("😀 Happy"), onPressed: () {}),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF151628),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.mic, color: Colors.pinkAccent), onPressed: () {}),
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: const TextField(decoration: InputDecoration(hintText: "Say something...", border: InputBorder.none, hintStyle: TextStyle(fontSize: 12))),
                  ),
                ),
                IconButton(icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent), onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () => _showChatActionSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChatActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151628),
      builder: (context) => Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(Icons.image, "Image", () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🖼️ Image Gallery Opened")));
            }),
            _buildActionItem(Icons.camera_alt, "Camera", () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📸 Camera Opened")));
            }),
            _buildActionItem(Icons.phone_in_talk, "Call", () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📞 Calling...")));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.white.withOpacity(0.1), child: Icon(icon, color: Colors.pinkAccent)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

// --- 4. प्रोफाइल टैब ('Me') ---
class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  late TabController _profileTabController;
  String userName = "KARAN";
  String userBio = "my___LOVE___⋆.✦ALISHA";

  @override
  void initState() {
    super.initState();
    _profileTabController = TabController(length: 4, vsync: this);
  }

  void _showDPMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151628),
      builder: (context) => Container(
        height: 140,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Profile Picture", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🖼️ Change DP Gallery Opened")));
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Change DP"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🔍 Viewing DP Fullscreen")));
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text("View DP"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController bioController = TextEditingController(text: userBio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        title: const Text("Edit Profile (Name & Bio)", style: TextStyle(color: Colors.pinkAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Bio / Status", labelStyle: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () {
              setState(() {
                userName = nameController.text;
                userBio = bioController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✨ Profile Updated Successfully!")));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _handleFeatureTap(String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        title: Text("✨ $label Center", style: const TextStyle(color: Colors.amberAccent)),
        content: Text("Explore and manage your $label features, level status, and privileges here!", style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)]),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _showDPMenu,
                                child: const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.face_retouching_natural, size: 40, color: Colors.pinkAccent)),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text("ID: 1528476546", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                      const SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📋 ID Copied to Clipboard!")));
                                        },
                                        child: const Icon(Icons.copy, size: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text("Glory Level: Dark Iron I", style: TextStyle(color: Colors.yellowAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
                                onPressed: _showEditProfileDialog,
                                tooltip: "Edit Profile Style",
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white, size: 26),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [Text("27", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("Friends", style: TextStyle(color: Colors.white70, fontSize: 10))]),
                          Column(children: [Text("10", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("Following", style: TextStyle(color: Colors.white70, fontSize: 10))]),
                          Column(children: [Text("627", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("Fans", style: TextStyle(color: Colors.white70, fontSize: 10))]),
                          Column(children: [Text("1171", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("Visitors", style: TextStyle(color: Colors.white70, fontSize: 10))]),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                
                // Wallets
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("My Account", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              SizedBox(height: 6),
                              Row(children: [Icon(Icons.diamond, color: Colors.cyanAccent, size: 16), SizedBox(width: 5), Text("1,500", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("My Ruby (Coins)", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              SizedBox(height: 6),
                              Row(children: [Icon(Icons.monetization_on, color: Colors.redAccent, size: 16), SizedBox(width: 5), Text("5,000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Daily & Weekly Rewards
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 24),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Daily & Week-to-Week Rewards", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("5,000 Coins + 3-Day Entry Active!", style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🎁 Daily & Weekly Coins Claimed Successfully!")));
                        },
                        child: const Text("Claim", style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children: [
                        GestureDetector(onTap: () => _handleFeatureTap("VIP"), child: _buildFeatureItem(Icons.star, "VIP", Colors.amber)),
                        GestureDetector(onTap: () => _handleFeatureTap("Glory Level"), child: _buildFeatureItem(Icons.shield, "Glory Level", Colors.blue)),
                        GestureDetector(onTap: () => _handleFeatureTap("Aristocracy"), child: _buildFeatureItem(Icons.workspace_premium, "Aristocracy", Colors.purple)),
                        GestureDetector(onTap: () => _handleFeatureTap("Game Level"), child: _buildFeatureItem(Icons.sports_esports, "Game Level", Colors.pink)),
                        GestureDetector(onTap: () => _handleFeatureTap("Family"), child: _buildFeatureItem(Icons.family_restroom, "Family", Colors.cyan)),
                        GestureDetector(onTap: () => _handleFeatureTap("Clubroom"), child: _buildFeatureItem(Icons.home_work, "Clubroom", Colors.indigo)),
                        GestureDetector(onTap: () => _handleFeatureTap("CP"), child: _buildFeatureItem(Icons.favorite, "CP", Colors.redAccent)),
                        GestureDetector(onTap: () => _handleFeatureTap("Store"), child: _buildFeatureItem(Icons.store, "Store", Colors.orange)),
                        GestureDetector(onTap: () => _handleFeatureTap("Dress up"), child: _buildFeatureItem(Icons.card_giftcard, "Dress up", Colors.teal)),
                        GestureDetector(onTap: () => _handleFeatureTap("My Gift"), child: _buildFeatureItem(Icons.redeem, "My Gift", Colors.deepOrange)),
                        GestureDetector(onTap: () => _handleFeatureTap("Mission Award"), child: _buildFeatureItem(Icons.military_tech, "Mission Award", Colors.green)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
                          child: _buildFeatureItem(Icons.feedback, "Feedback", Colors.lightBlue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: TabBar(
              controller: _profileTabController,
              indicatorColor: Colors.pinkAccent,
              labelColor: Colors.pinkAccent,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: "Moment"),
                Tab(text: "Profile"),
                Tab(text: "Honor"),
                Tab(text: "Relation"),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _profileTabController,
          children: [
            // Moment Tab
            ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Post your moment: Share your idea...", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.pinkAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📸 Moment Upload Gallery Opened!")));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ActionChip(label: const Text("@ Mention"), onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("👥 Tag users to mention")));
                    }),
                    const SizedBox(width: 8),
                    ActionChip(label: const Text("# Love"), onPressed: () {}),
                    const SizedBox(width: 8),
                    ActionChip(label: const Text("# Vibes"), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 10),
                Text(userBio, style: const TextStyle(color: Colors.pinkAccent, fontSize: 12)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: List.generate(9, (index) => Container(color: Colors.white24, child: const Center(child: Icon(Icons.image, color: Colors.white54)))),
                ),
              ],
            ),
            // Profile Tab
            ListView(
              padding: const EdgeInsets.all(15),
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: List.generate(9, (index) => Container(color: Colors.white24, child: const Center(child: Icon(Icons.image, color: Colors.white54)))),
                ),
                const SizedBox(height: 20),
                const Text("About me", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAboutTag("cute"),
                    _buildAboutTag("cooking"),
                    _buildAboutTag("romantic"),
                    _buildAboutTag("Rock music"),
                    _buildAboutTag("dog lover"),
                    _buildAboutTag("happy"),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow("Constellation", "♍ Virgo"),
                _buildInfoRow("Region", "🇮🇳 India"),
                _buildInfoRow("Joined GoVoice", "6 Years 7 Months"),
                _buildInfoRow("Bio", userBio),
                const SizedBox(height: 20),
                const Text("Family", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 25, backgroundColor: Colors.pinkAccent, child: Icon(Icons.group, color: Colors.white)),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("👑 KUR KUR KUR KUR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 4),
                          Text("ID: 170773   👥 38 Members", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Clubroom", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(radius: 25, backgroundColor: Colors.indigo, child: Icon(Icons.mic, color: Colors.white)),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("COFFEE WITH TI...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(height: 4),
                              Text("Lv8 • Clubroom", style: TextStyle(color: Colors.amberAccent, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(15)),
                        child: const Text("👤 0 Enter", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
            const Center(child: Text("Honor Badges & Achievements", style: TextStyle(color: Colors.white54))),
            const Center(child: Text("Relations & CP List", style: TextStyle(color: Colors.white54))),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// --- 5. रूम स्क्रीन (14 Seats & Voice Room) ---
class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final List<bool> seatMuted = List.generate(14, (index) => false);
  final List<String?> seatUsers = List.generate(14, (index) => null);
  final TextEditingController _msgController = TextEditingController();
  final List<String> _chatMessages = [
    "👑 Host: Welcome everyone to the royal room!",
    "💬 Alisha: Hello dear, lovely vibes here! ❤️",
    "🎁 Rahul sent a Magic Diamond to the host!"
  ];

  @override
  void initState() {
    super.initState();
    seatUsers[0] = "KARAN (Host)";
  }

  void _onSeatTap(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151628),
      builder: (context) => Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Seat No. ${index + 1} Management", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      seatUsers[index] = "KARAN";
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("🪑 You took Seat ${index + 1}")));
                  },
                  icon: const Icon(Icons.chair),
                  label: const Text("Take Seat"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: seatMuted[index] ? Colors.green : Colors.orange),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      seatMuted[index] = !seatMuted[index];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(seatMuted[index] ? "🔇 Seat Muted" : "🔊 Seat Unmuted")));
                  },
                  icon: Icon(seatMuted[index] ? Icons.mic : Icons.mic_off),
                  label: Text(seatMuted[index] ? "Unmute" : "Mute"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendRoomMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _chatMessages.add("KARAN: ${_msgController.text.trim()}");
    });
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("✨jai ➳MAHAKALI✨di (Room ID: 152847)"),
        backgroundColor: const Color(0xFF151628),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🔗 Room Link Copied!"))),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C1030), Color(0xFF0F1021), Color(0xFF050510)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 14,
                  itemBuilder: (context, index) {
                    bool isOccupied = seatUsers[index] != null;
                    return GestureDetector(
                      onTap: () => _onSeatTap(index),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isOccupied ? Colors.pinkAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                                child: Icon(
                                  index == 0 ? Icons.star : Icons.person,
                                  color: index == 0 ? Colors.amberAccent : Colors.white70,
                                  size: 26,
                                ),
                              ),
                              if (seatMuted[index])
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 9,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.mic_off, size: 10, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOccupied ? seatUsers[index]!.split(" ")[0] : "${index + 1}",
                            style: TextStyle(
                              color: isOccupied ? Colors.white : Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        _chatMessages[index],
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF151628),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.pinkAccent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🎤 Mic Toggled")));
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: "Say something to room...",
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendRoomMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.pinkAccent),
                    onPressed: _sendRoomMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.card_giftcard, color: Colors.amberAccent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🎁 Gift Panel Opened! Sent Rose to Host.")));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. Settings Screen ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(title: const Text("Settings"), backgroundColor: const Color(0xFF151628)),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
            child: Text("Account", style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ListTile(title: const Text("Account Binding"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
          ListTile(title: const Text("Change password"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
          const Divider(color: Colors.white12),
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Text("Function", style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ListTile(title: const Text("Notification Settings"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
          ListTile(title: const Text("Privacy Setting"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
          ListTile(title: const Text("Clear Cache"), trailing: const Text("22MB", style: TextStyle(color: Colors.white54, fontSize: 12)), onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🧹 Cache Cleared!")));
          }),
          ListTile(title: const Text("Clear Music Cache"), trailing: const Text("0MB", style: TextStyle(color: Colors.white54, fontSize: 12)), onTap: () {}),
          ListTile(title: const Text("Blacklist"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {
            _showBlacklistDialog(context);
          }),
          ListTile(title: const Text("Customized setting"), trailing: const Text("Dark Mode!", style: TextStyle(color: Colors.pinkAccent, fontSize: 12)), onTap: () {}),
          const Divider(color: Colors.white12),
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: Text("Other", style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ListTile(title: const Text("Check Version"), trailing: const Text("5.63.1", style: TextStyle(color: Colors.white54, fontSize: 12)), onTap: () {}),
          ListTile(title: const Text("Platform Policy"), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.2), foregroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              },
              child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showBlacklistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        title: const Text("Blacklist Management", style: TextStyle(color: Colors.white)),
        content: const Text("No users in blacklist currently.", style: TextStyle(color: Colors.white70)),
        actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }
}

// --- 7. Feedback Screen ---
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF0F1021),
      appBar: AppBar(title: const Text("Feedback & Support"), backgroundColor: const Color(0xFF151628)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tell us your feedback or report bugs:", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 15),
            TextField(
              controller: feedbackController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type your message here...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✨ Thank you for your feedback!")));
                },
                child: const Text("Submit Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
