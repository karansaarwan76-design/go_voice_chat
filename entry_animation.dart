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
