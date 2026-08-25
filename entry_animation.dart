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

// 3. Automatic 15/30 Days VIP Expiry & Recharge Functions
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
      DateTime expiryDate = expiryTimestamp.toDate();

      if (DateTime.now().isAfter(expiryDate)) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isVip': false,
          'entryThemeActive': false,
        });
      }
    }
  }
}
