// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl =
      'http://localhost:3000/api'; // La URL donde corre tu API

  // --- Manejo del Token JWT ---

  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recetas_token', token);
  }

  Future<void> _guardarDatosUsuario(
    String token,
    String userId,
    String userName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recetas_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', userName);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('recetas_token');
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recetas_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===================================================================
  // ===      LLAMADAS A LOS ENDPOINTS DE TU API                     ===
  // ===================================================================

  /// Endpoint: POST /auth/register
  Future<Map<String, dynamic>> registrarUsuario(
    String nombre,
    String email,
    String password,
  ) async {
    print('🚀 [API] Intentando registrar usuario: $email');
    print('🚀 [API] URL: $_baseUrl/auth/register');
    print('🚀 [API] Datos: name=$nombre, email=$email');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nombre,
          'email': email,
          'password': password,
        }),
      );

      print('🚀 [API] Respuesta del servidor - Status: ${response.statusCode}');
      print('🚀 [API] Respuesta del servidor - Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode != 201) {
        print(
          '❌ [API] Error en registro: ${data['message'] ?? 'Error desconocido'}',
        );
        throw Exception(data['message'] ?? 'Error en el registro');
      }

      print('✅ [API] Usuario registrado exitosamente');
      return data;
    } catch (e) {
      print('❌ [API] Excepción durante registro: $e');
      rethrow;
    }
  }

  /// Endpoint: POST /auth/login
  Future<Map<String, dynamic>> iniciarSesion(
    String email,
    String password,
  ) async {
    print('🔐 [API] Intentando iniciar sesión: $email');
    print('🔐 [API] URL: $_baseUrl/auth/login');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('🔐 [API] Login - Status: ${response.statusCode}');
      print('🔐 [API] Login - Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        print(
          '❌ [API] Error en login: ${data['message'] ?? 'Email o contraseña incorrectos'}',
        );
        throw Exception(data['message'] ?? 'Email o contraseña incorrectos');
      }

      if (data['session']?['access_token'] != null) {
        print('✅ [API] Token recibido y guardado');
        final session = data['session'];
        final user = session['user'];
        // Guardar token, ID y nombre del usuario
        await _guardarDatosUsuario(
          session['access_token'],
          user['id']?.toString() ?? '',
          user['user_metadata']?['name']?.toString() ??
              user['email']?.toString() ??
              'Usuario',
        );
      } else {
        print('⚠️ [API] No se recibió token en la respuesta');
      }

      print('✅ [API] Login exitoso');
      return data;
    } catch (e) {
      print('❌ [API] Excepción durante login: $e');
      rethrow;
    }
  }

  /// Endpoint: GET /recetas
  Future<List<dynamic>> obtenerTodasLasRecetas() async {
    print('📚 [API] Obteniendo todas las recetas');
    print('📚 [API] URL: $_baseUrl/recetas');

    try {
      final headers = await _getHeaders();
      print('📚 [API] Headers: $headers');

      final response = await http.get(
        Uri.parse('$_baseUrl/recetas'),
        headers: headers,
      );

      print('📚 [API] Recetas - Status: ${response.statusCode}');
      print('📚 [API] Recetas - Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        print(
          '❌ [API] Error obteniendo recetas: ${data is Map ? data['message'] ?? data['error'] ?? 'No se pudieron cargar las recetas' : 'No se pudieron cargar las recetas'}',
        );
        throw Exception(
          data is Map
              ? data['message'] ??
                    data['error'] ??
                    'No se pudieron cargar las recetas'
              : 'No se pudieron cargar las recetas',
        );
      }

      // Normalizar distintas formas de respuesta JSON
      List<dynamic> recetas = [];
      if (data is List) {
        recetas = data;
      } else if (data is Map) {
        if (data['data'] is List)
          recetas = List.from(data['data']);
        else if (data['recetas'] is List)
          recetas = List.from(data['recetas']);
        else if (data['rows'] is List)
          recetas = List.from(data['rows']);
        else if (data['recipes'] is List)
          recetas = List.from(data['recipes']);
        else if (data['result'] is List)
          recetas = List.from(data['result']);
      }

      print('✅ [API] ${recetas.length} recetas obtenidas (normalizado)');
      return recetas;
    } catch (e) {
      print('❌ [API] Excepción obteniendo recetas: $e');
      rethrow;
    }
  }

  /// Endpoint: GET /recetas/mis-recetas
  Future<List<dynamic>> obtenerMisRecetas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recetas/mis-recetas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        data is Map
            ? data['message'] ?? 'No se pudieron cargar tus recetas'
            : 'No se pudieron cargar tus recetas',
      );
    }

    if (data is List) return data;
    if (data is Map) {
      if (data['data'] is List) return List.from(data['data']);
      if (data['recetas'] is List) return List.from(data['recetas']);
      if (data['rows'] is List) return List.from(data['rows']);
    }
    return <dynamic>[];
  }

  /// Endpoint: GET /recetas/:id
  Future<Map<String, dynamic>> obtenerRecetaPorId(String recetaId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recetas/$recetaId'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        data is Map
            ? data['message'] ?? 'Receta no encontrada'
            : 'Receta no encontrada',
      );
    }

    if (data is Map) {
      if (data['data'] is Map) return Map<String, dynamic>.from(data['data']);
      if (data['receta'] is Map)
        return Map<String, dynamic>.from(data['receta']);
      // If the response is already the receta object
      return Map<String, dynamic>.from(data);
    }

    // Fallback empty map
    return <String, dynamic>{};
  }

  /// Endpoint: POST /recetas
  Future<Map<String, dynamic>> crearReceta(
    Map<String, dynamic> datosReceta,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recetas'),
      headers: await _getHeaders(),
      body: jsonEncode(datosReceta),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201)
      throw Exception(data['message'] ?? 'Error al crear la receta');
    return data;
  }

  /// Endpoint: PUT /recetas/:id
  Future<Map<String, dynamic>> actualizarReceta(
    String recetaId,
    Map<String, dynamic> datosReceta,
  ) async {
    print('✏️ [API] Actualizando receta ID: $recetaId');
    print('✏️ [API] URL: $_baseUrl/recetas/$recetaId');
    print('✏️ [API] Datos: $datosReceta');

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: await _getHeaders(),
        body: jsonEncode(datosReceta),
      );

      print('✏️ [API] Actualizar - Status: ${response.statusCode}');
      print('✏️ [API] Actualizar - Body: ${response.body}');

      // Manejar diferentes códigos de estado
      if (response.statusCode == 404) {
        print('❌ [API] Receta no encontrada o endpoint no implementado');
        throw Exception(
          'El endpoint de actualización no está disponible en el servidor. '
          'Por favor, implementa PUT /api/recetas/:id en tu backend.',
        );
      }

      // Intentar parsear la respuesta JSON
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (jsonError) {
        print('❌ [API] Error parseando JSON: $jsonError');
        print('❌ [API] Raw response: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Si el status es exitoso pero no es JSON válido, asumir éxito
          print('✅ [API] Actualización exitosa (respuesta no-JSON)');
          return {
            'success': true,
            'message': 'Receta actualizada exitosamente',
          };
        } else {
          throw Exception(
            'Error del servidor (${response.statusCode}): Respuesta inválida. '
            'Verifica que el backend esté funcionando correctamente.',
          );
        }
      }

      // Verificar código de estado después de parsear JSON
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = data is Map
            ? (data['message'] ?? data['error'] ?? 'Error desconocido')
            : 'Error del servidor';

        print('❌ [API] Error actualizando receta: $errorMessage');
        throw Exception('Error al actualizar la receta: $errorMessage');
      }

      print('✅ [API] Receta actualizada exitosamente');
      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } on http.ClientException catch (e) {
      print('❌ [API] Error de conexión: $e');
      throw Exception(
        'No se pudo conectar al servidor. Verifica que el backend esté ejecutándose en http://localhost:3000',
      );
    } catch (e) {
      print('❌ [API] Excepción actualizando receta: $e');
      rethrow;
    }
  }

  /// Endpoint: DELETE /recetas/:id
  Future<void> eliminarReceta(String recetaId) async {
    print('🗑️ [API] Eliminando receta ID: $recetaId');
    print('🗑️ [API] URL: $_baseUrl/recetas/$recetaId');

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: await _getHeaders(),
      );

      print('🗑️ [API] Eliminar - Status: ${response.statusCode}');
      print('🗑️ [API] Eliminar - Body: ${response.body}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        final data = jsonDecode(response.body);
        print(
          '❌ [API] Error eliminando receta: ${data['message'] ?? 'Error desconocido'}',
        );
        throw Exception(data['message'] ?? 'No se pudo eliminar la receta');
      }

      print('✅ [API] Receta eliminada exitosamente');
    } catch (e) {
      print('❌ [API] Excepción eliminando receta: $e');
      rethrow;
    }
  }
}
