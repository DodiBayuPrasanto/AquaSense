import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  
  static const String baseUrl = 'http://192.168.137.1:5000';

  Future<Map<String, dynamic>> checkAnomaly(List<Map<String, dynamic>> dataBuffer) async {
    try {
      final url = Uri.parse('$baseUrl/predict');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"data": dataBuffer}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke Server AI. Pastikan IP benar dan Server menyala.");
    }
  }
}