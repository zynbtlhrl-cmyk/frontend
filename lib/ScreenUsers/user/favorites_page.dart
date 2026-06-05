import 'package:flutter/material.dart';
import 'package:app_flutter/ScreenUsers/services/api_service.dart';
import 'package:app_flutter/ScreenUsers/user/video_page.dart';

class FavoritesScreen extends StatefulWidget {
  final bool showBackButton;

  const FavoritesScreen({super.key, this.showBackButton = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final data = await ApiFavorites().getFavorites();

      setState(() {
        favorites = data is List ? data : [];
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD FAVORITES: $e");
      setState(() {
        favorites = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المفضلات"),
        centerTitle: true,
        backgroundColor: const Color(0xFFDBC602),
        automaticallyImplyLeading: widget.showBackButton,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? const Center(
              child: Text(
                "لا يوجد كورسات مفضلة",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];

                // 🔥 حماية من null
                final course = fav['course'];

                if (course == null) {
                  return const SizedBox();
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),

                    leading: const Icon(
                      Icons.video_library,
                      color: Color(0xFFDBC602),
                      size: 35,
                    ),

                    title: Text(
                      course['name'] ?? 'No name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Text(
                      ("القسم: ${course['category_id'] ?? ''}"),
                      style: const TextStyle(fontSize: 12),
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideosScreen(
                            courseId: course['id'],
                            courseName: course['name'],
                            onBack: () {},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
