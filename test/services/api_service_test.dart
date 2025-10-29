import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:recetas_front/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      apiService = ApiService();
      mockClient = MockClient();
      SharedPreferences.setMockInitialValues({});
    });

    group('Token Management', () {
      test('should save and retrieve token correctly', () async {
        SharedPreferences.setMockInitialValues({'recetas_token': 'test_token'});

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('recetas_token', 'test_token');

        final token = prefs.getString('recetas_token');
        expect(token, equals('test_token'));
      });

      test('should clear token on logout', () async {
        SharedPreferences.setMockInitialValues({'recetas_token': 'test_token'});

        await apiService.cerrarSesion();

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('recetas_token');
        expect(token, isNull);
      });
    });

    group('User Registration', () {
      test('should register user successfully with valid data', () async {
        const responseBody =
            '{"message":"Usuario registrado exitosamente","user":{"id":"123","name":"Test User","email":"test@example.com"}}';

        // Mock successful response
        when(
          mockClient.post(
            Uri.parse('http://localhost:3000/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': 'Test User',
              'email': 'test@example.com',
              'password': 'password123',
            }),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 201));

        // Execute
        final result = await apiService.registrarUsuario(
          'Test User',
          'test@example.com',
          'password123',
        );

        // Verify
        expect(result['message'], equals('Usuario registrado exitosamente'));
        expect(result['user']['email'], equals('test@example.com'));
      });

      test('should throw exception on registration failure', () async {
        const responseBody = '{"message":"El email ya está registrado"}';

        when(
          mockClient.post(
            Uri.parse('http://localhost:3000/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 400));

        // Execute & Verify
        expect(
          () => apiService.registrarUsuario(
            'Test User',
            'test@example.com',
            'password123',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('User Login', () {
      test('should login successfully with valid credentials', () async {
        const responseBody =
            '{"message":"Login exitoso","session":{"access_token":"jwt_token_123"},"user":{"id":"123","email":"test@example.com"}}';

        when(
          mockClient.post(
            Uri.parse('http://localhost:3000/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': 'test@example.com',
              'password': 'password123',
            }),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        SharedPreferences.setMockInitialValues({});

        final result = await apiService.iniciarSesion(
          'test@example.com',
          'password123',
        );

        expect(result['message'], equals('Login exitoso'));
        expect(result['session']['access_token'], equals('jwt_token_123'));
      });

      test('should throw exception on invalid credentials', () async {
        const responseBody = '{"message":"Credenciales inválidas"}';

        when(
          mockClient.post(
            Uri.parse('http://localhost:3000/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 401));

        expect(
          () => apiService.iniciarSesion('test@example.com', 'wrong_password'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Recipe Operations', () {
      test('should fetch all recipes successfully', () async {
        const responseBody =
            '[{"id":"1","titulo":"Pasta","descripcion":"Deliciosa pasta"},{"id":"2","titulo":"Pizza","descripcion":"Pizza casera"}]';

        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await apiService.obtenerTodasLasRecetas();

        expect(result, isA<List>());
        expect(result.length, equals(2));
        expect(result[0]['titulo'], equals('Pasta'));
        expect(result[1]['titulo'], equals('Pizza'));
      });

      test('should handle wrapped response format', () async {
        const responseBody =
            '{"data":[{"id":"1","titulo":"Pasta","descripcion":"Deliciosa pasta"}],"total":1}';

        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await apiService.obtenerTodasLasRecetas();

        expect(result, isA<List>());
        expect(result.length, equals(1));
        expect(result[0]['titulo'], equals('Pasta'));
      });

      test('should fetch recipe by ID successfully', () async {
        const responseBody =
            '{"id":"1","titulo":"Pasta Carbonara","descripcion":"Receta clásica italiana","ingredientes":["pasta","huevos","bacon"],"pasos":["Hervir pasta","Mezclar ingredientes"]}';

        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await apiService.obtenerRecetaPorId('1');

        expect(result['titulo'], equals('Pasta Carbonara'));
        expect(result['ingredientes'], isA<List>());
        expect(result['pasos'], isA<List>());
      });

      test('should handle wrapped recipe response', () async {
        const responseBody =
            '{"data":{"id":"1","titulo":"Pasta Carbonara","descripcion":"Receta clásica italiana"}}';

        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await apiService.obtenerRecetaPorId('1');

        expect(result['titulo'], equals('Pasta Carbonara'));
      });

      test('should create recipe successfully', () async {
        const responseBody =
            '{"message":"Receta creada exitosamente","id":"123","titulo":"Nueva Receta"}';

        final recipeData = {
          'titulo': 'Nueva Receta',
          'descripcion': 'Una receta deliciosa',
          'ingredientes': ['ingrediente1', 'ingrediente2'],
          'pasos': ['paso1', 'paso2'],
        };

        when(
          mockClient.post(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: anyNamed('headers'),
            body: jsonEncode(recipeData),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 201));

        final result = await apiService.crearReceta(recipeData);

        expect(result['message'], equals('Receta creada exitosamente'));
        expect(result['titulo'], equals('Nueva Receta'));
      });

      test('should delete recipe successfully', () async {
        when(
          mockClient.delete(
            Uri.parse('http://localhost:3000/api/recetas/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('', 204));

        // Should not throw exception
        await apiService.eliminarReceta('1');
      });

      test(
        'should throw exception when deleting non-existent recipe',
        () async {
          const responseBody = '{"message":"Receta no encontrada"}';

          when(
            mockClient.delete(
              Uri.parse('http://localhost:3000/api/recetas/999'),
              headers: anyNamed('headers'),
            ),
          ).thenAnswer((_) async => http.Response(responseBody, 404));

          expect(
            () => apiService.eliminarReceta('999'),
            throwsA(isA<Exception>()),
          );
        },
      );
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: anyNamed('headers'),
          ),
        ).thenThrow(Exception('Network error'));

        expect(
          () => apiService.obtenerTodasLasRecetas(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed JSON response', () async {
        const responseBody = 'invalid json response';

        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        expect(
          () => apiService.obtenerTodasLasRecetas(),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Headers and Authentication', () {
      test('should include authorization header when token exists', () async {
        SharedPreferences.setMockInitialValues({'recetas_token': 'test_token'});

        const responseBody = '[]';

        when(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test_token',
            },
          ),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        await apiService.obtenerTodasLasRecetas();

        verify(
          mockClient.get(
            Uri.parse('http://localhost:3000/api/recetas'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test_token',
            },
          ),
        ).called(1);
      });

      test(
        'should not include authorization header when no token exists',
        () async {
          SharedPreferences.setMockInitialValues({});

          const responseBody = '[]';

          when(
            mockClient.get(
              Uri.parse('http://localhost:3000/api/recetas'),
              headers: {'Content-Type': 'application/json'},
            ),
          ).thenAnswer((_) async => http.Response(responseBody, 200));

          await apiService.obtenerTodasLasRecetas();

          verify(
            mockClient.get(
              Uri.parse('http://localhost:3000/api/recetas'),
              headers: {'Content-Type': 'application/json'},
            ),
          ).called(1);
        },
      );
    });
  });
}
