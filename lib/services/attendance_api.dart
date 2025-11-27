// lib/services/attendance_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_api.dart';
import 'auth_storage.dart';

class AttendanceApi {
  final AuthStorage _storage = AuthStorage();

  Future<Map<String, dynamic>> marcarAsistencia({
    required int localId,
    required String codigoBarra,
  }) async {
    // 1) Obtener token guardado (login previo)
    final token = await _storage.getToken();
    if (token == null) {
      return {
        'ok': false,
        'message': 'Token no disponible. Inicia sesión nuevamente.',
      };
    }

    // 2) Endpoint del backend
    final url = Uri.parse('${AuthApi.baseUrl}/asistencia');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'local_id': localId,
        'codigo_barra': codigoBarra,
      }),
    );

    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      // por si viene vacío o no es JSON
    }

    if (response.statusCode == 200) {
      // Asistencia registrada
      return {
        'ok': true,
        'message': data['message'] ?? 'Asistencia registrada correctamente',
        'registro': data['registro'],
      };
    }

    if (response.statusCode == 404) {
      // Entrada no encontrada para ese local + código
      return {
        'ok': false,
        'message': data['message'] ??
            'Entrada no encontrada para este local y código de barra.',
      };
    }

    if (response.statusCode == 409) {
      // Ya estaba en estado 'Asiste'
      return {
        'ok': false,
        'message': data['message'] ?? 'Este código ya fue utilizado.',
        'registro': data['registro'],
      };
    }

    // Otros errores (401, 500, etc.)
    return {
      'ok': false,
      'message':
          data['message'] ?? 'Error al marcar asistencia (${response.statusCode}).',
    };
  }
}
