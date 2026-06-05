import 'package:app_flutter/ScreenAdmin/Admin/Profile.dart';
import 'package:app_flutter/ScreenAdmin/Widgets/about_app.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_flutter/ScreenAdmin/Admin/api.dart';
import 'dart:io';
import 'dart:typed_data';

class DashboardPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  static List<Map<String, dynamic>> user = [];
  static List<Map<String, dynamic>> categories = [];
  static List<Map<String, dynamic>> courses = [];
  static List<Map<String, dynamic>> videosList = [];
  static int usersCount = 0;
  const DashboardPage({super.key, required this.scaffoldKey});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int users = 2;
  int videos = 22;
  int coursesCount = 0;
  int categoriesCount = 0;

  bool isValidCourse(String? value) {
    if (value == null) return false;
    return DashboardPage.courses.any((e) => e[0] == value);
  }

  //استرجاع بيانات بعد دخول للتطبيق
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      loadCategories(),
      loadCourses(),
      loadUsers(),
      loadVideos(),
    ]);
  }

  // ================= إضافة قسم =================
  void addCategory() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("إضافة قسم"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "اسم القسم",
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),

          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();

              final messenger = ScaffoldMessenger.maybeOf(dialogContext);

              if (name.isEmpty) {
                Navigator.pop(dialogContext);

                messenger?.showSnackBar(
                  const SnackBar(content: Text("اكتب اسم القسم")),
                );
                return;
              }

              // 🔴 منع التكرار (يبقى مثل ما هو)
              if (DashboardPage.categories.any((e) => e[1] == name)) {
                Navigator.pop(dialogContext);

                messenger?.showSnackBar(
                  const SnackBar(content: Text("هذا القسم موجود مسبقاً")),
                );
                return;
              }

              try {
                // 🔥 التعديل الوحيد هنا
                await ApiService.addCategory(name);

                setState(() {
                  categoriesCount = categoriesCount + 1;
                });

                Navigator.pop(dialogContext);

                messenger?.showSnackBar(
                  const SnackBar(content: Text("تم إضافة القسم")),
                );
              } catch (e) {
                Navigator.pop(dialogContext);

                messenger?.showSnackBar(SnackBar(content: Text("خطأ: $e")));
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // ================= تعديل قسم =================
  void editCategory(int index) {
    final controller = TextEditingController(
      text: DashboardPage.categories[index]["name"] ?? "",
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("تعديل القسم"),
        content: TextField(controller: controller),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),

          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final id = DashboardPage.categories[index]["id"];

              // منع التكرار
              if (DashboardPage.categories.any(
                (e) => e["name"] == name && e["id"] != id,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("هذا القسم موجود مسبقاً")),
                );
                return;
              }

              try {
                await ApiService.updateCategory(int.parse(id.toString()), name);

                setState(() {
                  DashboardPage.categories[index]["name"] = name;
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("تم تعديل القسم")));
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // ================= حذف قسم =================
  void deleteCategory(int index) async {
    final id = DashboardPage.categories[index]["id"].toString();

    try {
      await ApiService.deleteCategory(int.parse(id));

      setState(() {
        DashboardPage.categories.removeAt(index);
        categoriesCount--;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم حذف القسم")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }

  // ================= حذف =================
  void confirmDelete(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد من الحذف؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }

  //اضافه الكورس
  void addCourse() {
    if (DashboardPage.categories.isEmpty) {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("أضف قسم أولاً")));
      });

      return;
    }

    final controller = TextEditingController();
    String? selected;

    final List<String> categoryNames = DashboardPage.categories
        .map((e) => e["name"].toString())
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("إضافة كورس"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "اسم الكورس",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selected,
                    hint: const Text("اختر القسم"),
                    items: categoryNames.map((name) {
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        selected = v;
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("إلغاء"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();

                    if (name.isEmpty || selected == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("املأ جميع الحقول")),
                      );
                      return;
                    }

                    // منع التكرار
                    if (DashboardPage.courses.any((e) => e["name"] == name)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("هذا الكورس موجود مسبقاً"),
                        ),
                      );
                      return;
                    }

                    // 🔥 هنا التصليح المهم (جيب ID الحقيقي للقسم)
                    final category = DashboardPage.categories.firstWhere(
                      (e) => e["name"] == selected,
                    );

                    final int categoryId = int.parse(category["id"].toString());

                    // إرسال للـ API
                    final success = await ApiService.addCourse(
                      name,

                      categoryId,
                    );

                    if (success == true) {
                      setState(() {
                        DashboardPage.courses.add({
                          "id": DateTime.now().millisecondsSinceEpoch,
                          "name": name,
                          "category_name": selected!,
                        });

                        coursesCount = DashboardPage.courses.length;
                      });

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تمت إضافة الكورس")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("فشل إضافة الكورس")),
                      );
                    }
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= تعديل كورس =================
  void editCourse(int index) {
    final course = DashboardPage.courses[index];

    final controller = TextEditingController(
      text: course["name"]?.toString() ?? "",
    );

    int? selectedCategoryId = int.tryParse(course["category_id"].toString());

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("تعديل كورس"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "اسم الكورس"),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: selectedCategoryId,

                  items: DashboardPage.categories.map((e) {
                    final id = int.parse(e["id"].toString());

                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(e["name"].toString()),
                    );
                  }).toList(),

                  onChanged: (v) {
                    setStateDialog(() {
                      selectedCategoryId = v; // ✅ هذا المهم
                    });
                  },

                  decoration: const InputDecoration(labelText: "اختر قسم"),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("إلغاء"),
              ),

              ElevatedButton(
                onPressed: () async {
                  final newName = controller.text.trim();

                  if (newName.isEmpty || selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("أكمل البيانات")),
                    );
                    return;
                  }

                  try {
                    await ApiService.updateCourse(
                      int.parse(course["id"].toString()),
                      newName,
                      selectedCategoryId!,
                    );

                    setState(() {
                      DashboardPage.courses[index] = {
                        "id": course["id"],
                        "name": newName,
                        "category_id": selectedCategoryId,
                        "category_name": DashboardPage.categories.firstWhere(
                          (e) =>
                              int.tryParse(e["id"].toString()) ==
                              selectedCategoryId,
                        )["name"],
                      };
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم تعديل الكورس")),
                    );
                  } catch (e) {
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
                  }
                },
                child: const Text("تعديل"),
              ),
            ],
          );
        },
      ),
    );
  }

  //===========  إضافة فيديو =============
  void addVideo() {
    if (DashboardPage.courses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("أضف كورس أولاً")));
      return;
    }

    final titleController = TextEditingController();

    int? selectedCourse;
    String? fileName;
    Uint8List? fileBytes;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("إضافة فيديو"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "عنوان الفيديو",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<int>(
                      value: selectedCourse,
                      hint: const Text("اختر الكورس"),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: DashboardPage.courses.map((course) {
                        return DropdownMenuItem<int>(
                          value: course["id"],
                          child: Text(course["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedCourse = value;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              try {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.video,
                                      withData: true,
                                    );

                                if (result == null) return;

                                final file = result.files.single;

                                if (file.bytes == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("لا يمكن قراءة الملف"),
                                    ),
                                  );
                                  return;
                                }

                                setStateDialog(() {
                                  fileName = file.name;
                                  fileBytes = file.bytes;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("خطأ بالملف: $e")),
                                );
                              }
                            },
                      icon: const Icon(Icons.video_file),
                      label: const Text("اختيار فيديو"),
                    ),

                    if (fileName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          fileName!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("إلغاء"),
                ),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final title = titleController.text.trim();

                          if (title.isEmpty ||
                              selectedCourse == null ||
                              fileBytes == null ||
                              fileName == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("املأ جميع الحقول")),
                            );
                            return;
                          }

                          setStateDialog(() {
                            isLoading = true;
                          });

                          try {
                            await ApiService.addVideo(
                              title: title,
                              courseId: selectedCourse!,
                              fileName: fileName!,
                              videoBytes: fileBytes!,
                            );

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم رفع الفيديو")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
                          } finally {
                            setStateDialog(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("حفظ"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= تعديل فيديو =================
  void editVideo(int index) {
    final item = DashboardPage.videosList[index];

    final titleController = TextEditingController(
      text: item["title"].toString(),
    );

    int? selectedCourseId = int.tryParse(item["course_id"].toString());

    String? fileName = item["file_name"];
    File? selectedVideoFile;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("تعديل فيديو"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "عنوان الفيديو",
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<int>(
                      value:
                          DashboardPage.courses.any(
                            (c) =>
                                int.tryParse(c["id"].toString()) ==
                                selectedCourseId,
                          )
                          ? selectedCourseId
                          : null,

                      items: DashboardPage.courses.map((course) {
                        final id = int.tryParse(course["id"].toString());

                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(course["name"].toString()),
                        );
                      }).toList(),

                      onChanged: (v) {
                        setStateDialog(() {
                          selectedCourseId = v;
                        });
                      },

                      decoration: const InputDecoration(labelText: "اختر كورس"),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      selectedVideoFile != null
                          ? selectedVideoFile!.path.split('/').last
                          : (fileName ?? ""),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.video,
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            setStateDialog(() {
                              selectedVideoFile = File(
                                result.files.single.path!,
                              );
                            });
                          }
                        } catch (e) {
                          print("FilePicker error: $e");
                        }
                      },
                      child: const Text("اختيار فيديو جديد"),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("إلغاء"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();

                    if (title.isEmpty || selectedCourseId == null) return;

                    await ApiService.updateVideo(
                      id: int.parse(item["id"].toString()),
                      title: title,
                      courseId: selectedCourseId!,
                      videoFile: selectedVideoFile,
                    );

                    setState(() {
                      DashboardPage.videosList[index] = {
                        ...item,
                        "title": title,
                        "course_id": selectedCourseId,
                        "course_name": DashboardPage.courses.firstWhere(
                          (c) =>
                              int.parse(c["id"].toString()) == selectedCourseId,
                        )["name"],
                        "file_name": selectedVideoFile != null
                            ? selectedVideoFile!.path.split('/').last
                            : fileName,
                      };
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم تعديل الفيديو")),
                    );
                  },
                  child: const Text("تعديل"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/image/admin.png'),
              ),
              accountName: const Text(
                "المدير",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("admin@gmail.com"),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("صفحتي"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userName: "",
                      userEmail: "",
                      fromDrawer: true,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("حول التطبيق"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutApp()),
                );
              },
            ),
          ],
        ),
      ),

      // key: widget.scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 226, 226, 226),
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
        backgroundColor: Color(0xFF10BAFD),
      ),

      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // ================= GRID =================
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              dashboardCard(
                "المستخدمين",
                DashboardPage.usersCount,
                Icons.people,
                Colors.red,
              ),
              dashboardCard(
                "الاقسام",
                DashboardPage.categories.length,
                Icons.folder,
                Colors.blue,
              ),
              dashboardCard(
                "الكورسات",
                DashboardPage.courses.length,
                Icons.book,
                Colors.green,
              ),
              dashboardCard(
                "الفيديوهات",
                DashboardPage.videosList.length,
                Icons.play_circle,
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ================= CATEGORIES =================حدوفات  وتعديلات قسم
          sectionBox(
            title: "الأقسام",
            button: "إضافة قسم",
            onTap: addCategory,
            child: DashboardPage.categories.isEmpty
                ? const Text("لا يوجد أقسام")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: DashboardPage.categories.length,
                    itemBuilder: (context, index) {
                      final item = DashboardPage.categories[index];

                      return listItem(
                        title: item["name"] ?? "",
                        sub:
                            "عدد الكورسات: ${DashboardPage.courses.where((c) {
                              return int.tryParse(c["category_id"].toString()) == int.tryParse(item["id"].toString());
                            }).length}",
                        onEdit: () => editCategory(index),
                        onDelete: () {
                          confirmDelete(() async {
                            try {
                              deleteCategory(index);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("تم حذف القسم")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("خطأ: $e")),
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          // ================= COURSES =================
          sectionBox(
            title: "الكورسات",
            button: "إضافة كورس",
            onTap: addCourse,
            child: DashboardPage.courses.isEmpty
                ? const Text("لا يوجد كورسات")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: DashboardPage.courses.length,
                    itemBuilder: (context, index) {
                      final item = DashboardPage.courses[index];

                      return listItem(
                        title: item.isNotEmpty
                            ? (item["name"]?.toString() ?? "بدون اسم")
                            : "بدون اسم",
                        sub:
                            "عدد الفيديوهات: ${DashboardPage.videosList.where((c) => c[1] == item[0]).length}",
                        onEdit: () => editCourse(index),
                        onDelete: () {
                          confirmDelete(() async {
                            try {
                              final success = await ApiService.deleteCourse(
                                int.parse(
                                  DashboardPage.courses[index]["id"].toString(),
                                ),
                              );

                              if (success) {
                                setState(() {
                                  DashboardPage.courses.removeAt(index);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تم حذف الكورس"),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("خطأ: $e")),
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
          ),

          // ================= VIDEOS =================
          sectionBox(
            title: "الفيديوهات",
            button: "إضافة فيديو",
            onTap: addVideo,
            child: DashboardPage.videosList.isEmpty
                ? const Text("لا يوجد فيديوهات")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: DashboardPage.videosList.length,
                    itemBuilder: (context, index) {
                      final item = DashboardPage.videosList[index];

                      return listItem(
                        title: item["title"] ?? "بدون عنوان",
                        sub:
                            "الكورس: ${item["course"] != null ? item["course"]["name"] : "غير معروف"}",
                        onEdit: () => editVideo(index),
                        onDelete: () async {
                          confirmDelete(() async {
                            try {
                              await ApiService.deleteVideo(item["id"]);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم الحدف الفيديو')),
                              );

                              setState(() {
                                DashboardPage.videosList.removeAt(index);
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("خطأ بالحذف: $e")),
                              );
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= باقي الويجت =================
  Widget listItem({
    required String title,
    required String sub,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(String title, int count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text("$count"),
          Text(title, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  Widget sectionBox({
    required String title,
    required String button,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              TextButton(onPressed: onTap, child: Text(button)),
            ],
          ),
          child,
        ],
      ),
    );
  }

  //استرجاع بيانات بعد دخول للتطبيق
  Future<void> loadCategories() async {
    try {
      final data = await ApiService.getCategories();

      if (!mounted) return;

      setState(() {
        DashboardPage.categories.clear();

        for (var item in data) {
          DashboardPage.categories.add({
            "id": item["id"],
            "name": item["name"],
          });
        }

        categoriesCount = DashboardPage.categories.length;
      });

      print("CATEGORIES => ${DashboardPage.categories}");
    } catch (e) {
      print("loadCategories ERROR: $e");
    }
  }

  Future<void> loadCourses() async {
    try {
      final courses = await ApiService.getCourses();

      print("COURSES RESPONSE => $courses");

      if (!mounted) return;

      setState(() {
        DashboardPage.courses.clear();

        for (var item in courses) {
          DashboardPage.courses.add({
            "id": item["id"],
            "name": item["name"],
            "category_id": item["category_id"],
            "category_name": item["category_name"] ?? "",
          });
        }
      });

      print("COURSES => ${DashboardPage.courses}");
    } catch (e) {
      print("loadCourses ERROR => $e");
    }
  }

  Future<void> loadUsers() async {
    final count = await ApiService.getUsersCount();

    setState(() {
      DashboardPage.usersCount = count;
    });
  }

  Future<void> loadVideos() async {
    try {
      final data = await ApiService.getVideos();

      if (!mounted) return;

      setState(() {
        if (data is List) {
          DashboardPage.videosList = List<Map<String, dynamic>>.from(data);
        }
      });
    } catch (e) {
      print("loadVideos ERROR: $e");
    }
  }
}
