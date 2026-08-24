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

// यह चेक करेगा कि यूजर लॉगिन है या नहीं
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularIndicator());
        }
        if (snapshot.hasData) {
          return const VoiceChatRoomScreen(); // लॉगिन होने के बाद रूम खुलेगा
        }
        return const LoginScreen(); // लॉगिन न होने पर लॉगिन स्क्रीन दिखेगी
      },
    );
  }
}

// 1. लॉगिन स्क्रीन (Google & Phone)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Google Sign-In Function
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic, size: 80, color: Colors.deepPurpleAccent),
                const SizedBox(height: 20),
                const Text(
                  "Go Voice Chat",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 40),
                
                // Google Login Button
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
