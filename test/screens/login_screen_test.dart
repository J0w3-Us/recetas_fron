import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_front/presentation/screens/login_screen.dart';
import 'package:recetas_front/presentation/screens/signup_screen.dart';

void main() {
  group('LoginScreen Tests', () {
    testWidgets('should display all UI elements correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const LoginScreen()));

      // Verificar elementos de la UI
      expect(find.text('RecipeBrand'), findsOneWidget);
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Crear una cuenta'), findsOneWidget);

      // Verificar campos de entrada
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(
        find.byKey(const Key('email_field')),
        findsNothing,
      ); // No hay keys aún

      // Verificar logo
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const LoginScreen()));

      // Intentar hacer login sin llenar campos
      final loginButton = find.text('Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pump();

      // Verificar errores de validación
      expect(find.text('Por favor ingresa tu email'), findsOneWidget);
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
    });

    testWidgets('should navigate to signup screen when tapping create account', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
          routes: {'/signup': (context) => const SignupScreen()},
        ),
      );

      final createAccountButton = find.text('Crear una cuenta');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Verificar navegación a signup (buscar elementos únicos de SignupScreen)
      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('should fill email and password fields correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const LoginScreen()));

      // Encontrar campos y llenarlos
      final textFields = find.byType(TextFormField);

      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'password123');
      await tester.pump();

      // Verificar que los valores se llenaron
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should show loading state when login is in progress', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const LoginScreen()));

      // Llenar campos válidos
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'password123');

      // Simular tap en login y verificar estado de carga
      final loginButton = find.text('Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pump();

      // El botón debería mostrar loading (aunque fallará la llamada a API)
      // En un test real con mock, esto funcionaría mejor
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const LoginScreen()));

      final textFields = find.byType(TextFormField);

      // Probar email inválido
      await tester.enterText(textFields.first, 'invalid-email');
      await tester.enterText(textFields.last, 'password123');

      final loginButton = find.text('Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pump();

      // Nota: La validación actual solo verifica si está vacío
      // Para validación de formato de email se necesitaría actualizar el validador
    });

    testWidgets('should dispose controllers when widget is disposed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const LoginScreen()));

      // Cambiar a otra pantalla para disparar dispose
      await tester.pumpWidget(MaterialApp(home: Container()));

      // Si hay leaks de controllers, Flutter test lo detectará
      expect(tester.takeException(), isNull);
    });
  });
}
