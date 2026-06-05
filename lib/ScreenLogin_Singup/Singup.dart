import 'dart:convert';
import 'package:app_flutter/ScreenLogin_Singup/Login.dart';
import 'package:app_flutter/ScreenUsers/user/MainScreenUser.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({super.key});

  @override
  State<SingupScreen> createState() => _MyappState();
}

class _MyappState extends State<SingupScreen> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  String? username;
  String? email;
  String? password;

  bool isLoading = false;

  // 🔥 إرسال البيانات
  Future<void> sendData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse("http://127.0.0.1:8000/api/signup");

      var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": username,
          "email": email,
          "password": password,
        }),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        print("TOKEN SAVED = ${data['token']}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تم إنشاء الحساب بنجاح")));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );

        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("البريد أو البيانات غير صحيحة")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("خطأ في الاتصال")));
    }

    setState(() {
      isLoading = false;
    });
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
            const SizedBox(height: 10),

            const Icon(
              Icons.school,
              size: 100,
              color: Color.fromARGB(255, 16, 42, 54),
            ),

            const Text(
              'تعلم في اي وقت واي مكان',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              constraints: const BoxConstraints(minHeight: 50),
              width: 300,

              child: Form(
                key: formstate,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),

                    // الاسم
                    TextFormField(
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "رجاء قم بإدخال الاسم";
                        }
                        return null;
                      },
                      onChanged: (val) => username = val,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.person),
                        labelText: "الاسم",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // الايميل
                    TextFormField(
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "رجاء قم بإدخال البريد الالكتروني";
                        }
                        if (!v.contains("@")) {
                          return "بريد غير صالح";
                        }
                        return null;
                      },
                      onChanged: (val) => email = val,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.email),
                        labelText: "البريد الالكتروني",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // الباسورد
                    TextFormField(
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "رجاء قم بإدخال كلمة المرور";
                        }
                        if (v.length < 6) {
                          return "كلمة المرور قصيرة";
                        }
                        return null;
                      },
                      onChanged: (val) => password = val,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        labelText: "كلمة المرور",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // زر التسجيل (مهم جداً)
                    isLoading
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            color: const Color(0xFF155661),
                            minWidth: 230,
                            height: 45,
                            textColor: Colors.white,
                            onPressed: () {
                              if (formstate.currentState!.validate()) {
                                sendData();
                              }
                            },
                            child: const Text("تسجيل حساب"),
                          ),

                    const SizedBox(height: 10),

                    // الانتقال للوجين
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(text: "لديك حساب؟ "),
                          TextSpan(
                            text: "تسجيل دخول",
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
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
