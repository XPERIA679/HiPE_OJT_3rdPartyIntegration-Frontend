import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.68.102:8000/api';

  Future<List<dynamic>> getGeneralList() async {
    final response = await http.get(Uri.parse('$baseUrl/places'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<Map<String, dynamic>> getSingleCurrentDetails(
      String geoapifyId) async {
    final response = await http.get(Uri.parse('$baseUrl/place/$geoapifyId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<Map<String, dynamic>> getSingleFullDetails(String geoapifyId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/place/$geoapifyId/details'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load full place details');
    }
  }

  Future<void> sendCurrentLocation(double latitude, double longitude) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update-location'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, double>{
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send location data');
    }
  }
}
