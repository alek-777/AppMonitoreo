import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/log-reg/infrastructure/models/user_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // REGISTRO DE USUARIO
  static Future<Map<String, dynamic>> registerUser(UserModel user) async {
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // LOGIN DE USUARIO
  static Future<Map<String, dynamic>> loginUser(UserModel user) async {
    final url = Uri.parse('$baseUrl/auth/signin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteCompany(int id) async {
    final encodedId = Uri.encodeComponent('$id');
    final url = Uri.parse('$baseUrl/company/$encodedId');

    try {
      final response = await http.delete(url);
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Compañía no encontrada',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // BUSCAR COMPAÑÍA POR NOMBRE
  static Future<Map<String, dynamic>> findCompanyByName(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final url = Uri.parse('$baseUrl/company/search/$encodedName');
    try {
      final response = await http.get(url);
      final body = response.body;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body);
        return {'success': true, 'data': decoded};
      } else {
        final decoded = body.isNotEmpty ? jsonDecode(body) : null;
        return {
          'success': false,
          'message': decoded['message'] ?? 'Compañía no encontrada',
        };
      }
    } catch (e) {
      debugPrint('$e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // CREAR COMPAÑÍA
  static Future<Map<String, dynamic>> createCompany(
    Map<String, String> companyData,
  ) async {
    final url = Uri.parse('$baseUrl/company');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(companyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Error al crear la compañía',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
