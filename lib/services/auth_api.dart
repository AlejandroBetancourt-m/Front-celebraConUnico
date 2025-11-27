import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  // Para pruebas en Flutter Web en el mismo PC:
  static const String baseUrl = 'http://localhost:8000/api';
  // Si luego pruebas en emulador Android:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<Map<String, dynamic>> register({
    required String rut,
    required String nombre,
    required String apellido,
    required String contrasena,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'ok': true,
        'token': data['token'],
        'user': data['user'],
      };
    } else {
      return {
        'ok': false,
        'message': data['message'] ?? 'Error al registrar usuario',
        'errors': data['errors'],
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String rut,
    required String contrasena,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'rut': rut,
        'contrasena': contrasena,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'ok': true,
        'token': data['token'],
        'user': data['user'],
      };
    } else {
      return {
        'ok': false,
        'message': data['message'] ?? 'Error al iniciar sesión',
      };
    }
  }
}
