import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class AttendanceApi {
  // Ajusta esta IP para que tu celu vea el backend
  static const String baseUrl = 'http://192.168.2.181:8000/api';

  final AuthStorage _storage = AuthStorage();

  Future<Map<String, dynamic>> marcarAsistencia({
    required String codigoBarra,
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      return {
        'ok': false,
        'message': 'No hay token de autenticación. Inicia sesión nuevamente.'
      };
    }

    final url = Uri.parse('$baseUrl/asistencia');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'codigo_barra': codigoBarra,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'ok': true,
        'message': data['message'] ?? 'Asistencia registrada correctamente.',
        'data': data,
      };
    } else {
      try {
        final data = jsonDecode(response.body);
        return {
          'ok': false,
          'message': data['message'] ?? 'Error al registrar asistencia.',
          'data': data,
        };
      } catch (_) {
        return {
          'ok': false,
          'message':
              'Error al registrar asistencia. Código: ${response.statusCode}',
        };
      }
    }
  }
}
