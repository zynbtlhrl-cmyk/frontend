import 'package:app_flutter/ScreenLogin_Singup/Login.dart';
import 'package:app_flutter/ScreenUsers/services/api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = await UserService().getProfile();

      if (!mounted) return;

      setState(() {
        name = user?['name'] ?? 'No Name';
        email = user?['email'] ?? 'No Email';
        isLoading = false;
      });
    } catch (e) {
      print("ERROR PROFILE: $e");

      setState(() {
        name = "Error";
        email = "Error";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        backgroundColor: const Color(0xFFDBC602),
        centerTitle: true,
        automaticallyImplyLeading: widget.showBackButton,

        title: const Text(
          "الملف الشخصي",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage("assets/image/users.jpg"),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 77, 77, 77),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      email,
                      style: const TextStyle(
                        color: Color.fromARGB(179, 83, 83, 83),
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: 200,
                      height: 55,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        icon: const Icon(Icons.logout, color: Colors.white),

                        label: const Text(
                          "تسجيل خروج",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),

                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("تسجيل الخروج"),
                                content: const Text(
                                  "هل أنت متأكد تريد تسجيل الخروج؟",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("إلغاء"),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "تأكيد",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
