import 'package:app_flutter/ScreenUsers/user/course_page.dart';
import 'package:app_flutter/ScreenUsers/user/favorites_page.dart';
import 'package:app_flutter/ScreenUsers/user/home_page.dart';
import 'package:app_flutter/ScreenUsers/user/prifile.dart';
import 'package:app_flutter/ScreenUsers/user/video_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  String? selectedCategory;
  int? selectedCategoryId;

  Map<String, dynamic>? selectedCourse;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      selectedCategory == null
          ? CategoriesScreen(
              onTapCategory: (int id, String category) {
                setState(() {
                  selectedCategory = category;
                  selectedCategoryId = id;
                });
              },
              onChangeTab: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )
          : selectedCourse == null
          ? CoursesScreen(
              title: selectedCategory!,
              categoryId: selectedCategoryId!,
              onTapCourse: (course) {
                setState(() {
                  selectedCourse =
                      course as Map<String, dynamic>?; // 🔥 Map كامل
                });
              },
            )
          : VideosScreen(
              courseName: selectedCourse!['name'],
              courseId: selectedCourse!['id'], // 🔥 مهم جداً
              onBack: () {
                setState(() {
                  selectedCourse = null;
                });
              },
            ),

      FavoritesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 187, 169, 8),
        currentIndex: currentIndex,
        selectedFontSize: 16,
        selectedIconTheme: const IconThemeData(color: Colors.blue, size: 30),
        selectedItemColor: Colors.white,

        onTap: (index) {
          setState(() {
            currentIndex = index;

            // reset navigation
            selectedCategory = null;
            selectedCourse = null;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "المفضلة"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}
