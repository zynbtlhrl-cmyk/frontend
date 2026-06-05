import 'package:app_flutter/ScreenAdmin/Admin/dashboard_page.dart';
import 'package:app_flutter/ScreenLogin_Singup/Login.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({super.key});

  @override
  State<ProfileAdminScreen> createState() => _TestAdminScreenState();
}

class _TestAdminScreenState extends State<ProfileAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int index = 0;

  late List<Widget> pages;

  String userName = "Admin";
  String userEmail = "admin@gmail.com";

  @override
  void initState() {
    super.initState();

    pages = [
      DashboardPage(scaffoldKey: _scaffoldKey),

      ProfilePage(userName: userName, userEmail: userEmail, fromDrawer: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF10BAFD),
        fixedColor: Color.fromARGB(255, 255, 255, 255),
        currentIndex: index,

        onTap: (value) {
          setState(() {
            index = value;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "البروفايل"),
        ],
      ),
    );
  }
}

// ================= صفحة البروفايل =================

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final bool? fromDrawer;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.fromDrawer,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List users = [];

  List categories = [];
  List courses = [];
  List videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.fromDrawer ?? false,

        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blue,
                  backgroundImage: AssetImage('assets/image/admin.png'),
                ),

                const SizedBox(height: 15),

                Text(
                  widget.userName,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.userEmail,

                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // ================= data =================
                buildCard(
                  icon: Icons.people,

                  title: "عرض جميع المستخدمين",
                  titleColor: Colors.red,

                  onTap: () {
                    getUsers();
                  },
                ),

                // ================= CATEGORIES =================
                buildCard(
                  icon: Icons.topic,

                  title: "عرض جميع الأقسام",
                  titleColor: Colors.red,

                  onTap: getCategories,
                ),

                // ================= COURSES =================
                buildCard(
                  icon: Icons.menu_book,
                  title: "عرض جميع الكورسات",
                  titleColor: Colors.red,

                  onTap: () {
                    getCourses();
                  },
                ),

                // ================= VIDEOS =================
                buildCard(
                  icon: Icons.video_collection,
                  title: "عرض جميع الفيديوهات",
                  titleColor: Colors.red,

                  onTap: () {
                    getVideos();
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),

                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("تسجيل الخروج"),
                          content: const Text(
                            "هل أنت متأكد من تسجيل الخروج؟",
                            style: TextStyle(color: Colors.red),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("إلغاء"),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "خروج",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },

                    icon: const Icon(Icons.logout),

                    label: const Text("تسجيل الخروج"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= جلب المستخدمين =================
  Future<void> getUsers() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 24, 255, 178),
          ),
        );
      },
    );

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/users"),
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
          users = users.where((users) {
            return users['role'] != 'admin';
          }).toList();
        });

        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text("جميع المستخدمين"),

                  content: SizedBox(
                    width: double.maxFinite,
                    height: 400,

                    child: users.isEmpty
                        ? const Center(child: Text("لا يوجد مستخدمين"))
                        : ListView.separated(
                            itemCount: users.length,

                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),

                            itemBuilder: (context, index) {
                              final user = users[index];

                              return ListTile(
                                leading: const Icon(Icons.person),

                                title: Text(user['name'] ?? ''),

                                subtitle: Text(user['email'] ?? ''),

                                trailing: IconButton(
                                  color: const Color.fromARGB(
                                    255,
                                    243,
                                    109,
                                    56,
                                  ),

                                  icon: const Icon(Icons.delete),

                                  onPressed: () async {
                                    // تأكيد الحذف
                                    bool? confirm = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("تأكيد"),
                                          content: const Text(
                                            "هل تريد حذف المستخدم؟",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("إلغاء"),
                                            ),

                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text("حذف"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm != true) return;

                                    final userId = user['id'];

                                    final deleteResponse = await http.delete(
                                      Uri.parse(
                                        "http://127.0.0.1:8000/api/users/$userId",
                                      ),
                                    );

                                    if (deleteResponse.statusCode == 200) {
                                      setDialogState(() {
                                        users.removeAt(index);
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("تم حذف المستخدم"),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("فشل حذف المستخدم"),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),

                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("إغلاق"),
                    ),
                  ],
                );
              },
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("خطأ"),
              content: Text("فشل في جلب البيانات"),
            );
          },
        );
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("خطأ"),
            content: Text("حدث خطأ في الاتصال بالسيرفر"),
          );
        },
      );
    }
  } // ================= Dialog =================

  void showDialogList(String title, List<List<String>> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("جميع $title"),

          content: SizedBox(
            width: double.maxFinite,

            child: data.isEmpty
                ? const Text("لا يوجد بيانات")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,

                    itemBuilder: (context, index) {
                      // شرط إذا العنوان يساوي "المستخدمين"
                      bool isUsers = title == "المستخدمين";

                      return ListTile(
                        // إذا مستخدمين يظهر حذف
                        leading: isUsers
                            ? const Icon(Icons.delete, color: Colors.red)
                            : null,

                        title: Text(data[index][0]),
                      );
                    },
                  ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        );
      },
    );
  }
  // ================= Card =================

  Widget buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required MaterialColor titleColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(
        leading: Icon(icon, color: Colors.blue),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }

  Future<void> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/categories"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<List<String>> categoriesData = [];

        for (var item in data["categories"]) {
          categoriesData.add([item["name"].toString()]);
        }

        showDialogList("الأقسام", categoriesData);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/courses"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<List<String>> coursesData = [];

        for (var item in data["course"]) {
          coursesData.add([item["name"].toString()]);
        }

        showDialogList("الكورسات", coursesData);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getVideos() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/videos"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // تحويل البيانات
        List<List<String>> videosData = [];

        for (var item in data) {
          videosData.add([item["title"].toString()]);
        }

        // عرض جميع الفيديوهات
        showDialogList("الفيديوهات", videosData);
      }
    } catch (e) {
      print(e);
    }
  }
}
