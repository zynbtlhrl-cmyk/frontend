import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    String token = prefs.getString('token') ?? '';

    print("TOKEN FROM PROFILE = $token");

    try {
      final response = await dio.get(
        'http://127.0.0.1:8000/api/profile', //     1270.1
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print("PROFILE RESPONSE = ${response.data}");

      return response.data['user'];
    } catch (e) {
      print("PROFILE ERROR = $e");
      return null;
    }
  }
}

class CategoryService {
  Future<List<dynamic>> getVideos() async {
    try {
      final response = await dio.get(
        'http://127.0.0.1:8000/api/videos',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      print("🔥 RESPONSE: ${response.data}");

      return response.data['videos'];
    } catch (e) {
      print("🔥 DIO ERROR: $e");
      return [];
    }
  }

  final Dio dio = Dio();

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await dio.get('http://127.0.0.1:8000/api/categories');

      return response.data['categories'];
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }
}

class CourseService {
  final Dio dio = Dio();

  Future<List<dynamic>> getCourses() async {
    try {
      final response = await dio.get('http://127.0.0.1:8000/api/courses');

      return response.data['course'];
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }

  Future<List<dynamic>> getVideos() async {
    try {
      final response = await dio.get(
        'http://127.0.0.1:8000/api/videos',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      print("🔥 RESPONSE: ${response.data}");

      return response.data['videos'];
    } catch (e) {
      print("🔥 DIO ERROR: $e");
      return [];
    }
  }
}

class ApiFavorites {
  Future<List<dynamic>> getFavorites() async {
    final token = await getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/favorites'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      print("FAV RESPONSE: $data");

      if (data == null) return [];

      if (data is Map && data['favorites'] != null) {
        return List<Map<String, dynamic>>.from(data['favorites']);
      }

      return [];
    } catch (e) {
      print("FAV ERROR: $e");
      return [];
    }
  }

  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> addFavorit(int courseId) async {
    final token = await getToken();

    print("ADD TOKEN: $token");
    print("URL = $baseUrl/api/favorites/add");
    print("COURSE ID = $courseId");

    final response = await http.post(
      Uri.parse('$baseUrl/api/favorites/add'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'course_id': courseId}),
    );

    print("STATUS CODE = ${response.statusCode}");
    print("RESPONSE BODY = ${response.body}");
  }

  Future<void> removeFavorite(int courseId) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/favorites/remove'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'course_id': courseId}),
    );

    print(response.body);
  }
}

class VideoService {
  final Dio dio = Dio();

  Future<List<dynamic>> getVideos(int courseId) async {
    final response = await dio.get(
      'http://127.0.0.1:8000/api/videos?course_id=$courseId',
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print("COURSE ID = $courseId");
    print("VIDEOS RESPONSE = ${response.data}");

    if (response.data is List) return response.data;
    return response.data['videos'] ?? [];
  }
}
