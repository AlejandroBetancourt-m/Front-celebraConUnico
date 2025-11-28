import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- TOKEN ---

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // --- INFO USUARIO ---

  Future<void> saveUserInfo({
    String? rut,
    String? nombre,
    String? lastName,
  }) async {
    if (rut != null) {
      await _storage.write(key: 'user_rut', value: rut);
    }
    if (nombre != null) {
      await _storage.write(key: 'user_first_name', value: nombre);
    }
    if (lastName != null) {
      await _storage.write(key: 'user_last_name', value: lastName);
    }

    // Opcional: también guardamos nombre completo
    final fullName = [
      if (nombre != null && nombre.isNotEmpty) nombre,
      if (lastName != null && lastName.isNotEmpty) lastName,
    ].join(' ');
    if (fullName.isNotEmpty) {
      await _storage.write(key: 'user_name', value: fullName);
    }
  }

  Future<String?> getUserName() async {
    // nombre completo (first + last)
    return _storage.read(key: 'user_name');
  }

  Future<String?> getUserFirstName() async {
    return _storage.read(key: 'user_first_name');
  }

  Future<String?> getUserLastName() async {
    return _storage.read(key: 'user_last_name');
  }

  Future<String?> getUserRut() async {
    return _storage.read(key: 'user_rut');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
