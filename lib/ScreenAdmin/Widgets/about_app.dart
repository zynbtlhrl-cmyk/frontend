import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حول التطبيق"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text('''
منصة إدارة تعليمية متكاملة تم تطويرها لتسهيل عملية
 رفع وتنظيم المحتوى التعليمي، بما يشمل الكورسات، الفيديوهات، والأقسام.

تم تصميمها لتكون سهلة الاستخدام وتدعم إدارة المحتوى بكفاءة عالية.

تم تطوير التطبيق باستخدام Flutter و Laravel API.
          ''', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
