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

  /// Verificar conectividad del servidor
  Future<bool> verificarConexion() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el token actual es válido
  Future<bool> verificarTokenValido() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return false;
      }

      // Hacer una llamada simple para verificar el token
      final response = await http
          .get(Uri.parse('$_baseUrl/recetas'), headers: await _getHeaders())
          .timeout(const Duration(seconds: 5));

      final esValido = response.statusCode != 401;

      return esValido;
    } catch (e) {
      return false;
    }
  }

  /// Endpoint: POST /auth/register
  Future<Map<String, dynamic>> registrarUsuario(
    String nombre,
    String email,
    String password,
  ) async {
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

      final data = jsonDecode(response.body);
      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Error en el registro');
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Endpoint: POST /auth/login
  Future<Map<String, dynamic>> iniciarSesion(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Email o contraseña incorrectos');
      }

      if (data['session']?['access_token'] != null) {
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
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Endpoint: GET /recetas
  Future<List<dynamic>> obtenerTodasLasRecetas() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl/recetas'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
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

      return recetas;
    } catch (e) {
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
    try {
      // Transformar datos al formato que espera el backend
      final datosParaBackend = {
        'name': datosReceta['titulo'], // titulo -> name
        'description': datosReceta['descripcion'], // descripcion -> description
        'steps': datosReceta['pasos'], // pasos -> steps
        'ingredients':
            datosReceta['ingredientes'], // ingredientes -> ingredients
        if (datosReceta['imagen_url'] != null)
          'imagen_url': datosReceta['imagen_url'],
      };

      final headers = await _getHeaders();
      final body = jsonEncode(datosParaBackend);

      final response = await http.post(
        Uri.parse('$_baseUrl/recetas'),
        headers: headers,
        body: body,
      );

      // Intentar parsear la respuesta
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (jsonError) {
        throw Exception('Respuesta del servidor no válida: ${response.body}');
      }

      // Manejar diferentes códigos de estado
      if (response.statusCode == 400) {
        final errorMsg = data is Map
            ? (data['message'] ??
                  data['error'] ??
                  data['details'] ??
                  'Datos inválidos')
            : 'Datos inválidos enviados al servidor';

        throw Exception(
          'Error en los datos enviados: $errorMsg\n\n'
          'Verifica que todos los campos requeridos estén presentes:\n'
          '- titulo (string)\n'
          '- descripcion (string)\n'
          '- ingredientes (array)\n'
          '- pasos (array)\n'
          '- imagen_url (string, opcional)',
        );
      }

      // Manejar token inválido (401)
      if (response.statusCode == 401) {
        // Limpiar token inválido
        await cerrarSesion();

        throw Exception(
          'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
        );
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorMsg = data is Map
            ? (data['message'] ?? data['error'] ?? 'Error desconocido')
            : 'Error del servidor';

        throw Exception('Error al crear la receta: $errorMsg');
      }

      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar al servidor. Verifica que el backend esté ejecutándose.',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Endpoint: PUT /recetas/:id
  Future<Map<String, dynamic>> actualizarReceta(
    String recetaId,
    Map<String, dynamic> datosReceta,
  ) async {
    try {
      // Transformar datos al formato que espera el backend
      final datosParaBackend = {
        'name': datosReceta['titulo'], // titulo -> name
        'description': datosReceta['descripcion'], // descripcion -> description
        'steps': datosReceta['pasos'], // pasos -> steps
        'ingredients':
            datosReceta['ingredientes'], // ingredientes -> ingredients
        if (datosReceta['imagen_url'] != null)
          'imagen_url': datosReceta['imagen_url'],
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: await _getHeaders(),
        body: jsonEncode(datosParaBackend),
      );

      // Manejar diferentes códigos de estado
      if (response.statusCode == 404) {
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
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Si el status es exitoso pero no es JSON válido, asumir éxito
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

        throw Exception('Error al actualizar la receta: $errorMessage');
      }

      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar al servidor. Verifica que el backend esté ejecutándose en http://localhost:3000',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Endpoint: DELETE /recetas/:id
  Future<void> eliminarReceta(String recetaId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/recetas/$recetaId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'No se pudo eliminar la receta');
      }
    } catch (e) {
      rethrow;
    }
  }
}
