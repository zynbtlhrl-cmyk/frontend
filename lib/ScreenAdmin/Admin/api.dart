import 'dart:convert';
import 'dart:io';
import 'package:app_flutter/ScreenAdmin/Admin/dashboard_page.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ApiService {
  // 🔥 حط IP مالك هنا
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // =====================
  // ADD CATEGORY
  // =====================

  static Future<String> addCategory(String name) async {
    final response = await http.post(
      Uri.parse("$baseUrl/categories"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"name": name}),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = jsonDecode(response.body);

    // 🔥 حماية من null
    final categoryData = data["data"] ?? data;

    if (response.statusCode == 200 || response.statusCode == 201) {
      DashboardPage.categories.add({
        "id": (categoryData["id"] ?? 0).toString(),
        "name": (categoryData["name"] ?? ""),
      });

      return "تمت الإضافة";
    }

    if (response.statusCode == 422) {
      if (data["errors"] != null && data["errors"]["name"] != null) {
        return data["errors"]["name"][0];
      }

      return "هذا القسم موجود بالفعل";
    }

    return "حدث خطأ";
  }

  //استرجاع بيانات بعد دخول للتطبيق
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/categories"),
      headers: {"Accept": "application/json"},
    );

    print("GET CATEGORIES: ${response.body}");

    final data = jsonDecode(response.body);

    if (data is Map && data["categories"] != null) {
      return List<Map<String, dynamic>>.from(data["categories"]);
    }

    return [];
  }

  //حدف القسم داله
  static Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/categories/$id"),
      headers: {"Accept": "application/json"},
    );

    print("DELETE STATUS: ${response.statusCode}");
  }

  //تعديل القسم
  static Future<void> updateCategory(int id, String name) async {
    final response = await http.put(
      Uri.parse("$baseUrl/categories/$id"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"name": name}),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("فشل تحديث القسم");
    }
  }

  // =====================
  // اضافه الكورس
  // =====================
  static Future<bool> addCourse(String name, int categoryId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/courses"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"name": name, "category_id": categoryId}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await http.get(
      Uri.parse("$baseUrl/courses"),
      headers: {"Accept": "application/json"},
    );

    print("GET COURSES: ${response.body}");

    final data = jsonDecode(response.body);

    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }

    if (data is Map && data["course"] != null) {
      return List<Map<String, dynamic>>.from(data["course"]);
    }

    return [];
  }

  //تعديل كورس
  static Future<void> updateCourse(int id, String name, int categoryId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/courses/$id"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"name": name, "category_id": categoryId}),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    // 🔥 مهم جداً
    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception("فشل تحديث الكورس");
    }
  }

  // حدف الكورس
  static Future<bool> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/courses/$id"),
      headers: {"Accept": "application/json"},
    );

    print("DELETE COURSE STATUS: ${response.statusCode}");
    print("DELETE COURSE BODY: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // =====================
  // ADD VIDEO (UPLOAD FILE)
  // =====================
  static Future<Map<String, dynamic>?> addVideo({
    required String title,
    required int courseId,
    required String fileName,
    required Uint8List videoBytes,
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/videos"));

      request.headers["Accept"] = "application/json";

      request.fields["title"] = title;
      request.fields["course_id"] = courseId.toString();

      request.files.add(
        http.MultipartFile.fromBytes("video", videoBytes, filename: fileName),
      );

      var response = await request.send();
      final body = await response.stream.bytesToString();

      print("STATUS: ${response.statusCode}");
      print("BODY: $body");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(body);

        // 🔥 رجّع الفيديو الجديد إذا موجود
        return decoded["data"] ?? decoded;
      }

      return null;
    } catch (e) {
      print("UPLOAD ERROR: $e");
      return null;
    }
  }

  static Future<int> getUsersCount() async {
    final response = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: {"Accept": "application/json"},
    );

    print("GET USERS: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // إذا API يرجع List
      if (data is List) {
        return data.length;
      }

      // إذا يرجع داخل key
      if (data is Map && data["users"] != null) {
        return (data["users"] as List).length;
      }
    }

    return 0;
  }
  //فيدديوهات

  static Future<List<dynamic>> getVideos() async {
    final response = await http.get(
      Uri.parse("$baseUrl/videos"),
      headers: {"Accept": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<void> updateVideo({
    required int id,
    required String title,
    required int courseId,
    File? videoFile,
  }) async {
    var request = http.MultipartRequest(
      "POST", // أو PUT حسب الراوت عندك
      Uri.parse("$baseUrl/videos/$id"),
    );

    request.fields['title'] = title;
    request.fields['course_id'] = courseId.toString();
    request.fields['_method'] = "PUT"; // مهم في Laravel

    if (videoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );
    }

    await request.send();
  }

  static Future<void> deleteVideo(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/videos/$id"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("فشل حذف الفيديو: ${response.body}");
    }
  }

  Future<void> removeFavorite(courseId) async {}

  Future<void> addFavorite(courseId) async {}

  Future<Object?> getFavorites() async {}
}
