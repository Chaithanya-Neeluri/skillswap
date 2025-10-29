import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000"; // change if hosted

  static Future<List<dynamic>> searchTutors(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/search/search'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": query}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['tutors'];
    } else {
      throw Exception(data['message'] ?? "Error searching tutors");
    }
  }
}
