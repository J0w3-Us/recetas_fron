// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:3000/api';

  // --- MANEJO DE AUTENTICACIÓN (TOKEN) ---

  Future<void> _guardarToken(
    String token,
    String userId,
    String userName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recetas_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', userName);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('recetas_token');
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> cerrarSesion() async {
    print('🚪 [LOGOUT] Iniciando cierre de sesión');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recetas_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    print('✅ [LOGOUT] Sesión cerrada, datos eliminados');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===================================================================
  // ===      LLAMADAS A LOS ENDPOINTS DE LA API                     ===
  // ===================================================================

  /// Endpoint: POST /auth/register
  Future<Map<String, dynamic>> registrarUsuario(
    String nombre,
    String email,
    String password,
  ) async {
    print('🚀 [REGISTER] Iniciando registro para: $email');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name': nombre,
          'email': email,
          'password': password,
        }),
      );

      print('🚀 [REGISTER] Status: ${response.statusCode}');
      print('🚀 [REGISTER] Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode >= 400) {
        print(
          '❌ [REGISTER] Error: ${data['message'] ?? 'Error en el registro'}',
        );
        throw Exception(data['message'] ?? 'Error en el registro');
      }

      print('✅ [REGISTER] Usuario registrado exitosamente');
      return data;
    } catch (e) {
      print('❌ [REGISTER] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: POST /auth/login
  Future<Map<String, dynamic>> iniciarSesion(
    String email,
    String password,
  ) async {
    print('🔐 [LOGIN] Iniciando sesión para: $email');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('🔐 [LOGIN] Status: ${response.statusCode}');
      print('🔐 [LOGIN] Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode >= 400) {
        print(
          '❌ [LOGIN] Error: ${data['message'] ?? 'Email o contraseña incorrectos'}',
        );
        throw Exception(data['message'] ?? 'Email o contraseña incorrectos');
      }

      final session = data['session'];
      final user = session?['user'];
      if (session?['access_token'] != null && user?['id'] != null) {
        print('🔐 [LOGIN] Guardando token y datos de usuario');
        await _guardarToken(
          session['access_token'],
          user['id'],
          user['user_metadata']?['name'] ?? 'Usuario',
        );
        print('✅ [LOGIN] Token guardado exitosamente');
      } else {
        print('⚠️ [LOGIN] No se recibió token válido en la respuesta');
      }

      return data;
    } catch (e) {
      print('❌ [LOGIN] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: GET /recetas
  Future<List<dynamic>> obtenerTodasLasRecetas() async {
    print('📚 [GET_RECETAS] Obteniendo todas las recetas');
    try {
      final headers = await _getHeaders();
      print('📚 [GET_RECETAS] Headers: $headers');

      final response = await http.get(
        Uri.parse('$_baseUrl/recetas'),
        headers: headers,
      );

      print('📚 [GET_RECETAS] Status: ${response.statusCode}');
      print('📚 [GET_RECETAS] Response length: ${response.body.length} chars');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          '✅ [GET_RECETAS] ${data is List ? data.length : 'N/A'} recetas obtenidas',
        );
        return data is List ? data : [];
      } else {
        print(
          '❌ [GET_RECETAS] Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [GET_RECETAS] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: GET /recetas/mis-recetas
  Future<List<dynamic>> obtenerMisRecetas() async {
    print('👤 [MIS_RECETAS] Obteniendo mis recetas');
    try {
      final headers = await _getHeaders();
      print('👤 [MIS_RECETAS] Headers: $headers');

      final response = await http.get(
        Uri.parse('$_baseUrl/recetas/mis-recetas'),
        headers: headers,
      );

      print('👤 [MIS_RECETAS] Status: ${response.statusCode}');
      print('👤 [MIS_RECETAS] Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          '✅ [MIS_RECETAS] ${data is List ? data.length : 'N/A'} recetas obtenidas',
        );
        return data is List ? data : [];
      } else {
        print('❌ [MIS_RECETAS] Error: ${response.statusCode}');
        throw Exception('Failed to load my recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [MIS_RECETAS] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: GET /recetas/:id
  Future<Map<String, dynamic>> obtenerRecetaPorId(String recetaId) async {
    print('📖 [GET_RECETA] Obteniendo receta ID: $recetaId');
    try {
      final headers = await _getHeaders();
      print('📖 [GET_RECETA] Headers: $headers');

      final response = await http.get(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: headers,
      );

      print('📖 [GET_RECETA] Status: ${response.statusCode}');
      print('📖 [GET_RECETA] Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [GET_RECETA] Receta obtenida exitosamente');
        return data is Map<String, dynamic> ? data : {};
      } else {
        print('❌ [GET_RECETA] Error: ${response.statusCode}');
        throw Exception('Recipe not found: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [GET_RECETA] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: POST /recetas
  Future<Map<String, dynamic>> crearReceta(
    Map<String, dynamic> datosReceta,
  ) async {
    print('➕ [CREATE_RECETA] Creando nueva receta');
    print('➕ [CREATE_RECETA] Datos: $datosReceta');
    try {
      final headers = await _getHeaders();
      print('➕ [CREATE_RECETA] Headers: $headers');

      final body = jsonEncode(datosReceta);
      print('➕ [CREATE_RECETA] Body JSON: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/recetas'),
        headers: headers,
        body: body,
      );

      print('➕ [CREATE_RECETA] Status: ${response.statusCode}');
      print('➕ [CREATE_RECETA] Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode != 201) {
        print(
          '❌ [CREATE_RECETA] Error: ${data['message'] ?? 'Error al crear la receta'}',
        );
        throw Exception(data['message'] ?? 'Error al crear la receta');
      }

      print('✅ [CREATE_RECETA] Receta creada exitosamente');
      return data;
    } catch (e) {
      print('❌ [CREATE_RECETA] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: PUT /recetas/:id
  Future<Map<String, dynamic>> actualizarReceta(
    String recetaId,
    Map<String, dynamic> datosReceta,
  ) async {
    print('✏️ [UPDATE_RECETA] Actualizando receta ID: $recetaId');
    print('✏️ [UPDATE_RECETA] Datos: $datosReceta');
    try {
      final headers = await _getHeaders();
      print('✏️ [UPDATE_RECETA] Headers: $headers');

      final body = jsonEncode(datosReceta);
      print('✏️ [UPDATE_RECETA] Body JSON: $body');

      final response = await http.put(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: headers,
        body: body,
      );

      print('✏️ [UPDATE_RECETA] Status: ${response.statusCode}');
      print('✏️ [UPDATE_RECETA] Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        print(
          '❌ [UPDATE_RECETA] Error: ${data['message'] ?? 'Error al actualizar la receta'}',
        );
        throw Exception(data['message'] ?? 'Error al actualizar la receta');
      }

      print('✅ [UPDATE_RECETA] Receta actualizada exitosamente');
      return data;
    } catch (e) {
      print('❌ [UPDATE_RECETA] Excepción: $e');
      rethrow;
    }
  }

  /// Endpoint: DELETE /recetas/:id
  Future<void> eliminarReceta(String recetaId) async {
    print('🗑️ [DELETE_RECETA] Eliminando receta ID: $recetaId');
    try {
      final headers = await _getHeaders();
      print('🗑️ [DELETE_RECETA] Headers: $headers');

      final response = await http.delete(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: headers,
      );

      print('🗑️ [DELETE_RECETA] Status: ${response.statusCode}');
      print('🗑️ [DELETE_RECETA] Response: ${response.body}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        print('❌ [DELETE_RECETA] Error: ${response.statusCode}');
        throw Exception(
          'No se pudo eliminar la receta: ${response.statusCode}',
        );
      }

      print('✅ [DELETE_RECETA] Receta eliminada exitosamente');
    } catch (e) {
      print('❌ [DELETE_RECETA] Excepción: $e');
      rethrow;
    }
  }
}
