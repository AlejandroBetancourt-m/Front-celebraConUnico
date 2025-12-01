// lib/services/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // ⚠️ Si pruebas en dispositivo físico, cambia localhost por la IP de tu PC.
  // Ejemplo: 'http://192.168.0.10:8000/api'
  static const String _baseUrl = 'http://192.168.1.210:8000/api';

  final http.Client _client = http.Client();

  /// 🔐 LOGIN -> POST /api/login
  Future<Map<String, dynamic>> login({
    required String rut,
    required String contrasena,
  }) async {
    final uri = Uri.parse('$_baseUrl/login');

    try {
      final resp = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'rut': rut,
          'contrasena': contrasena,
        }),
      );

      Map<String, dynamic> data = {};
      if (resp.body.isNotEmpty) {
        try {
          data = jsonDecode(resp.body) as Map<String, dynamic>;
        } catch (_) {
          // si viene algo raro, no rompemos la app
        }
      }

      if (resp.statusCode == 200) {
        // Tu Laravel devuelve:
        // {
        //   "message": "Login correcto",
        //   "user": { "id":.., "rut":.., "nombre":.., "apellido":..? },
        //   "token": "xxxx"
        // }
        final token = (data['token'] ?? '') as String;
        final user  = (data['user'] ?? {}) as Map<String, dynamic>;

        return {
          'ok': true,
          'token': token,
          'message': data['message'] ?? 'Login correcto',
          'user': user,
        };
      } else {
        // Errores tipo 401, 422, etc.
        String mensaje =
            data['message']?.toString() ?? 'Error al iniciar sesión';

        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstErrorList = errors.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            mensaje = firstErrorList.first.toString();
          }
        }

        return {
          'ok': false,
          'message': mensaje,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'message': 'Error de red al iniciar sesión: $e',
      };
    }
  }

  /// 📝 REGISTER -> POST /api/register
  Future<Map<String, dynamic>> register({
    required String rut,
    required String nombre,
    required String apellido,
    required String contrasena,
  }) async {
    final uri = Uri.parse('$_baseUrl/register');

    try {
      final resp = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'rut': rut,
          'nombre': nombre,
          'apellido': apellido,
          'contrasena': contrasena,
        }),
      );

      Map<String, dynamic> data = {};
      if (resp.body.isNotEmpty) {
        try {
          data = jsonDecode(resp.body) as Map<String, dynamic>;
        } catch (_) {}
      }

      if (resp.statusCode == 201) {
        // {
        //   "message": "Usuario registrado correctamente",
        //   "user": {...},
        //   "token": "xxxx"
        // }
        return {
          'ok': true,
          'token': (data['token'] ?? '') as String,
          'message':
              data['message'] ?? 'Usuario registrado correctamente',
          'user': data['user'] ?? {},
        };
      } else {
        String mensaje =
            data['message']?.toString() ?? 'Error al registrar usuario';

        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstErrorList = errors.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            mensaje = firstErrorList.first.toString();
          }
        }

        return {
          'ok': false,
          'message': mensaje,
        };
      }
    } catch (e) {
      return {
        'ok': false,
        'message': 'Error de red al registrar usuario: $e',
      };
    }
  }
}
