import 'package:app_flutter/ScreenAdmin/Admin/Profile.dart';
import 'package:app_flutter/ScreenLogin_Singup/Singup.dart';
import 'package:app_flutter/ScreenUsers/user/MainScreenUser.dart';
import 'package:app_flutter/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _MyappState();
}

class _MyappState extends State<LoginScreen> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  String? email;
  String? password;
  String? role;

  bool isLoading = false;

  // ✅ الآن ترجع role مباشرة
  Future<String?> sendData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse("http://127.0.0.1:8000/api/login");

      var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email ?? "", "password": password ?? ""}),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data['token']);

        print("TOKEN SAVED = ${data['token']}");

        setState(() {
          role = data['user']['role'].toString().trim().toLowerCase();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(230, 24, 196, 1),
            content: Text("تم تسجيل الدخول بنجاح"),
          ),
        );

        return role;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("رجاء قم بادخال بيانات صحيح")),
        );

        return null;
      }
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("خطأ في الاتصال")));

      return null;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF155661),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.school, size: 100, color: Colors.black),
            const SizedBox(height: 20),
            const Text(
              'تعلم في اي وقت واي مكان',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              width: 300,
              child: Form(
                key: formstate,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    TextFormField(
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "الحقل فارغ";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        email = val;
                      },
                      decoration: InputDecoration(
                        labelText: "البريد الالكتروني",
                        icon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "الحقل فارغ";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        password = val;
                      },
                      decoration: InputDecoration(
                        labelText: "كلمة المرور",
                        icon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    isLoading
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            color: const Color(0xFF155661),
                            minWidth: 230,
                            height: 45,
                            textColor: Colors.white,
                            child: const Text("تسجيل دخول"),
                            onPressed: () async {
                              if (formstate.currentState!.validate()) {
                                String? userRole = await sendData();

                                if (userRole == "admin") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileAdminScreen(),
                                    ),
                                  );
                                } else if (userRole == "user") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                }
                              }
                            },
                          ),

                    const SizedBox(height: 10),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(text: "ليس لديك حساب؟ "),
                          TextSpan(
                            text: "انشاء حساب",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SingupScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
