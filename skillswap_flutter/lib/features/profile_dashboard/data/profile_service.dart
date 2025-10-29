import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";

  // 🔹 Helper: Get token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // 🔹 Get Profile (uses JWT token)
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _getToken();
    if (token == null) {
      return {"success": false, "message": "No token found"};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {"success": true, "user": data["user"]};
    } else {
      return {"success": false, "message": data["message"]};
    }
  }

  // 🔹 Add Skill
  static Future<Map<String, dynamic>> addSkill(String skillName) async {
    final token = await _getToken();
    if (token == null) {
      return {"success": false, "message": "No token found"};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/skill/add-skill'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"skillName": skillName}),
    );

    final data = jsonDecode(response.body);
    return {"success": response.statusCode == 200, ...data};
  }

  // 🔹 Generate Quiz via OpenAI
  static Future<List<dynamic>> generateQuiz(String skillName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/skill/generate-quiz'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"skillName": skillName}),
    );
    print("Response body: ${response.body}");

    final data = jsonDecode(response.body);
    return data['quiz'];
  }

  // 🔹 Update Skill Proficiency (after quiz)
  static Future<Map<String, dynamic>> updateProficiency(
      String skillName, double proficiency) async {
    final token = await _getToken();
    if (token == null) {
      return {"success": false, "message": "No token found"};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/skill/update-skill-proficiency'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "skillName": skillName,
        "proficiency": proficiency,
      }),
    );

    final data = jsonDecode(response.body);
    return {"success": response.statusCode == 200, ...data};
  }
}
