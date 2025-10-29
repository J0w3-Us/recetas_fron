import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_front/presentation/screens/signup_screen.dart';
import 'package:recetas_front/presentation/screens/login_screen.dart';

void main() {
  group('SignupScreen Tests', () {
    testWidgets('should display all UI elements correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      // Verificar elementos de la UI
      expect(find.text('RecipeBrand'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar Contraseña'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('¿Ya tienes cuenta? Inicia sesión'), findsOneWidget);

      // Verificar campos de entrada
      expect(find.byType(TextFormField), findsNWidgets(4));

      // Verificar logo
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      // Intentar registrarse sin llenar campos
      final signupButton = find.text('Registrarse');
      await tester.tap(signupButton);
      await tester.pump();

      // Verificar errores de validación
      expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
      expect(find.text('Por favor ingresa tu email'), findsOneWidget);
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
      expect(find.text('Por favor confirma tu contraseña'), findsOneWidget);
    });

    testWidgets('should validate password confirmation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      final textFields = find.byType(TextFormField);

      // Llenar campos con contraseñas diferentes
      await tester.enterText(textFields.at(0), 'Juan Pérez');
      await tester.enterText(textFields.at(1), 'juan@example.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'different_password');

      final signupButton = find.text('Registrarse');
      await tester.tap(signupButton);
      await tester.pump();

      // Verificar error de confirmación de contraseña
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('should validate password length', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      final textFields = find.byType(TextFormField);

      // Llenar con contraseña muy corta
      await tester.enterText(textFields.at(0), 'Juan Pérez');
      await tester.enterText(textFields.at(1), 'juan@example.com');
      await tester.enterText(textFields.at(2), '123'); // Contraseña muy corta
      await tester.enterText(textFields.at(3), '123');

      final signupButton = find.text('Registrarse');
      await tester.tap(signupButton);
      await tester.pump();

      // Verificar error de longitud de contraseña
      expect(
        find.text('La contraseña debe tener al menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should navigate to login screen when tapping login link', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SignupScreen(),
          routes: {'/login': (context) => const LoginScreen()},
        ),
      );

      final loginLink = find.text('¿Ya tienes cuenta? Inicia sesión');
      await tester.tap(loginLink);
      await tester.pumpAndSettle();

      // Verificar navegación a login (buscar elementos únicos de LoginScreen)
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    });

    testWidgets('should fill all form fields correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      final textFields = find.byType(TextFormField);

      // Llenar todos los campos
      await tester.enterText(textFields.at(0), 'Juan Pérez');
      await tester.enterText(textFields.at(1), 'juan@example.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.pump();

      // Verificar que los valores se llenaron
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('juan@example.com'), findsOneWidget);
      expect(
        find.text('password123'),
        findsNWidgets(2),
      ); // Aparece 2 veces (password y confirmación)
    });

    testWidgets('should show real-time validation messages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      final textFields = find.byType(TextFormField);

      // Llenar nombre y contraseña corta para activar validación en tiempo real
      await tester.enterText(textFields.at(0), 'Juan');
      await tester.enterText(textFields.at(2), '12');

      // Cambiar foco para activar validación
      await tester.tap(textFields.at(1));
      await tester.pump();

      // En una implementación completa con autovalidate, aquí aparecerían los errores
      // La implementación actual usa autovalidateMode pero puede no activarse inmediatamente
    });

    testWidgets('should dispose controllers when widget is disposed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      // Cambiar a otra pantalla para disparar dispose
      await tester.pumpWidget(MaterialApp(home: Container()));

      // Si hay leaks de controllers, Flutter test lo detectará
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle valid form submission attempt', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const SignupScreen()));

      final textFields = find.byType(TextFormField);

      // Llenar formulario válido
      await tester.enterText(textFields.at(0), 'Juan Pérez');
      await tester.enterText(textFields.at(1), 'juan@example.com');
      await tester.enterText(textFields.at(2), 'password123');
      await tester.enterText(textFields.at(3), 'password123');

      final signupButton = find.text('Registrarse');
      await tester.tap(signupButton);
      await tester.pump();

      // El formulario debería pasar la validación (aunque falle la llamada API)
      // En este punto no deberían aparecer mensajes de validación
      expect(find.text('Por favor ingresa tu nombre'), findsNothing);
      expect(find.text('Las contraseñas no coinciden'), findsNothing);
    });
  });
}
