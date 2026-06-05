import 'package:app_flutter/ScreenAdmin/Admin/api.dart';
import 'package:app_flutter/ScreenUsers/services/api_service.dart'
    hide ApiService;
import 'package:app_flutter/ScreenUsers/user/MainScreenUser.dart';
import 'package:app_flutter/ScreenUsers/user/video_page.dart';
import 'package:flutter/material.dart';

class CoursesScreen extends StatefulWidget {
  final String title;
  final int categoryId;
  final Function(Map<String, dynamic> course)? onTapCourse;
  const CoursesScreen({
    super.key,
    required this.title,
    required this.categoryId,
    this.onTapCourse,
  });

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    loadFavorites();
    loadCourses();
  }

  int currentIndex = 0;
  List<dynamic> courses = [];

  bool isLoading = true;
  Set<int> favoriteIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 167, 166, 166),

      appBar: AppBar(
        backgroundColor: const Color(0xFFDBC602),
        centerTitle: true,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          },
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
          ? const Center(
              child: Text(
                "لا يوجد كورسات داخل هذا القسم",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final courseId = courses[index]['id'];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideosScreen(
                          courseName: courses[index]['name'],
                          courseId: courses[index]['id'],
                          onBack: () {},
                        ),
                      ),
                    );

                    await loadFavorites();
                  },

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courses[index]['name'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "القسم: ${courses[index]['category_id']}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () async {
                            try {
                              if (favoriteIds.contains(courseId)) {
                                await ApiFavorites().removeFavorite(courseId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تم حذف الكورس من المفضلة"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                await ApiFavorites().addFavorit(courseId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "تمت إضافة الكورس إلى المفضلة",
                                    ),
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      139,
                                      163,
                                      0,
                                    ),
                                  ),
                                );
                              }

                              // 🔥 أهم سطر: رجّع الحالة من السيرفر
                              await loadFavorites();
                            } catch (e) {
                              print("ERROR = $e");
                            }
                          },
                          icon: Icon(
                            favoriteIds.contains(courseId)
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> loadCourses() async {
    final data = await CourseService().getCourses();

    setState(() {
      courses = data
          .where((course) => course['category_id'] == widget.categoryId)
          .toList();

      isLoading = false;
    });
  }

  Future<void> loadFavorites() async {
    try {
      final favs = await ApiFavorites().getFavorites();

      if (favs is List) {
        setState(() {
          favoriteIds = Set<int>.from(favs.map((e) => e['course_id']));
        });
      }
    } catch (e) {
      print("ERROR LOAD FAVORITES: $e");
    }
  }
}
