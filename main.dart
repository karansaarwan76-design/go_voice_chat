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
  int _currentIndex = 0; // डिफ़ॉल्ट Home टैब

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

// टैब 2: स्क्वायर स्क्रीन (Moments)
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
                              Text("KARAN", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("ID: 1526476546\nGlory Level: Dark Icon", style: TextStyle(color: Colors.white70, fontSize: 11)),
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
                            child: const Text("My Ruby (Coins)\n🪙 5,000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. प्रोफेशनल 14-सीटर वॉयस चैट रूम (स्क्रीनशॉट के जैसी थीम और यूनिक गिफ्ट्स के साथ)
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

  // यूनिक गिफ्ट्स की लिस्ट
  final List<Map<String, dynamic>> _uniqueGifts = [
    {"name": "Royal Bicycle 🚲", "price": "500 Diamonds", "icon": Icons.directions_bike},
    {"name": "Golden Crown 👑", "price": "1000 Diamonds", "icon": Icons.monetization_on},
    {"name": "Magic Rose 🌹", "price": "100 Diamonds", "icon": Icons.local_florist},
    {"name": "Super Car 🏎️", "price": "5000 Diamonds", "icon": Icons.directions_car},
  ];

  void _sendChatMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add("KARAN: ${_msgController.text.trim()}");
        _msgController.clear();
      });
    }
  }

  // यूनिक गिफ्ट्स भेजने का बॉटम शीट मेनू
  void _showGiftStore() {
    showModalBottomSheet(
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
                        _chatMessages.add("🎁 Gift Sent: ${gift["name"]} successfully!");
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("You sent ${gift["name"]}! 🎉")),
                      );
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
      backgroundColor: const Color(0xFF241005), // स्क्रीनशॉट जैसी प्रीमियम रॉयल ब्राउन थीम
      appBar: AppBar(
        title: const Text("प्यारे बाबा 2 रूम (#101)", style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: const Color(0xFF1A0A02),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
            onPressed: _showGiftStore,
            tooltip: "Unique Gifts",
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 14 सीट्स का लेआउट (ऊपर होस्ट + नीचे 13 गेस्ट सीट्स)
          SizedBox(
            height: 260,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // होस्ट सीट (Seat 1) - स्क्रीनशॉट जैसी बड़ी स्पेशल सीट
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amberAccent, width: 3),
                          color: const Color(0xFF3A1C08),
                        ),
                        child: const Icon(Icons.mic, color: Colors.greenAccent, size: 28),
                      ),
                      const SizedBox(height: 2),
                      const Text("Host (VISHAL)", style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // बाकी 13 सीट्स
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

          // रूम नोटिस बोर्ड (स्क्रीनशॉट के जैसा)
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

          // लाइव चैट और बबल्स सेक्शन
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

          // नीचे टाइपिंग और यूनिक गिफ्ट/म्यूजिक बटन पट्टी
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFF1A0A02),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
                  onPressed: _showGiftStore,
                  tooltip: "Unique Gifts",
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
                  onPressed: _sendChatMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
