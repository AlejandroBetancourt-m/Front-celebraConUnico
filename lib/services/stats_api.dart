import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class StatsApi {
  // misma baseUrl que AuthApi
  static const String baseUrl = 'http://localhost:8000/api';

  final AuthStorage _storage = AuthStorage();

  Future<int?> getTotalAsistencias() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/resumen-total-asistencias');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_asistencias'] as int?;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>?> getResumenLocales() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/resumen-locales');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    }
    return null;
  }
}
