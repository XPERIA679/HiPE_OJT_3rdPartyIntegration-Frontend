import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.56.1:8000/api';

  Future<List<dynamic>> getGeneralList() async {
    final response = await http.get(Uri.parse('$baseUrl/places'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    print('Failed to load places. Status code: ${response.statusCode}');
    throw Exception('Failed to load places: ${response.reasonPhrase}');
  }

  Future<Map<String, dynamic>> getSingleCurrentDetails(
      String geoapifyId) async {
    final response = await http.get(Uri.parse('$baseUrl/place/$geoapifyId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    print('Failed to load place details. Status code: ${response.statusCode}');
    throw Exception('Failed to load place details: ${response.reasonPhrase}');
  }

  Future<Map<String, dynamic>> getSingleFullDetails(String geoapifyId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/place/$geoapifyId/details'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    print(
        'Failed to load full place details. Status code: ${response.statusCode}');
    throw Exception(
        'Failed to load full place details: ${response.reasonPhrase}');
  }
}
