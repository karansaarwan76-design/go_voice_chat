                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Sign in with Google", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
                const Text("OR", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 20),

                // Phone Number Field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Phone Number (+91...)",
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white54)),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(height: 15),

                // Phone OTP Button (Placeholder for verification flow)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // यहाँ फोन ओटीपी भेजने का कोड आगे जोड़ा जाएगा
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Phone OTP feature coming up next!")),
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

// 2. वॉयस चैट रूम स्क्रीन (14 सीट्स लेआउट)
class VoiceChatRoomScreen extends StatelessWidget {
  const VoiceChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Chat Room"),
        backgroundColor: const Color(0xFF1F1F1F),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Room ID: #101 | 14-Seater Live",
              style: TextStyle(color: Colors.white75, fontSize: 16),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // एक लाइन में 4 सीट्स
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 14, // कुल 14 सीट्स
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepPurpleAccent, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic_off, color: Colors.white54, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        "Seat ${index + 1}",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CircularIndicator extends StatelessWidget {
  const CircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
    );
  }
}
