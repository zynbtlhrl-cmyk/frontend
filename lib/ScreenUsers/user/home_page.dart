import 'package:app_flutter/ScreenUsers/services/api_service.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(int categoryId, String category) onTapCategory;
  final Function(int tabIndex) onChangeTab;

  const CategoriesScreen({
    super.key,
    required this.onTapCategory,
    required this.onChangeTab,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List categories = [];
  bool loading = true;
  String name = "Loading...";

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProfile();
  }

  Future<void> loadCategories() async {
    try {
      final data = await CategoryService().getCategories();

      if (!mounted) return;

      setState(() {
        categories = data is List ? data : [];
        loading = false;
      });
    } catch (e) {
      print("LOAD ERROR: $e");

      if (!mounted) return;

      setState(() {
        categories = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                "  $name اهلاً بيك ",

                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.deepOrange),
              title: const Text("المفضلات"),
              onTap: () {
                Navigator.pop(context);
                widget.onChangeTab(1);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text("حسابي"),
              onTap: () {
                Navigator.pop(context);
                widget.onChangeTab(2);
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFFDBC602),
        title: const Text("الاقسام"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(
              child: Text(
                'لا يوجد أقسام',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(150, 107, 107, 107),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = (categories[index] is Map)
                    ? categories[index]
                    : {};

                final id = item['id'];
                final name = item['name']?.toString() ?? '';

                return InkWell(
                  onTap: () {
                    widget.onTapCategory(id, name);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.library_books, color: Colors.white),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> loadProfile() async {
    try {
      final user = await UserService().getProfile();

      if (!mounted) return;

      setState(() {
        name = user?['name'] ?? 'No Name';
      });
    } catch (e) {
      print("ERROR PROFILE: $e");
    }
  }
}
