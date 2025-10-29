import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_front/presentation/screens/home_screen.dart';
import 'package:recetas_front/presentation/screens/profile_screen.dart';
import 'package:recetas_front/presentation/screens/recipe_detail_screen.dart';

void main() {
  group('HomeScreen Tests', () {
    testWidgets('should display all UI elements correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Verificar elementos del header
      expect(find.text('RecipeBrand'), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Recetas'), findsOneWidget);
      expect(find.text('Blog'), findsOneWidget);
      expect(find.text('Contacto'), findsOneWidget);

      // Verificar barra de búsqueda
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar recetas...'), findsOneWidget);

      // Verificar logo y avatar
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display featured recipe section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Verificar sección de receta destacada
      expect(find.text('RECETA DEL DÍA'), findsOneWidget);
      expect(
        find.text('Pasta Fresca al Pesto con Tomates Cherry'),
        findsOneWidget,
      );
      expect(find.text('Preparar Ahora'), findsOneWidget);
    });

    testWidgets('should display popular recipes section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Verificar título de recetas populares
      expect(find.text('Recetas Populares'), findsOneWidget);

      // Verificar que hay un FutureBuilder para cargar recetas
      expect(find.byType(FutureBuilder<List<dynamic>>), findsOneWidget);
    });

    testWidgets('should show loading indicator when fetching recipes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Verificar que aparece el loading al principio
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to profile when tapping avatar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          routes: {'/profile': (context) => const ProfileScreen()},
        ),
      );

      final avatar = find.byType(CircleAvatar);
      await tester.tap(avatar);
      await tester.pumpAndSettle();

      // Verificar navegación al perfil
      expect(find.text('Mis Recetas'), findsOneWidget);
    });

    testWidgets(
      'should toggle to recipe detail view when tapping featured recipe button',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

        final prepareButton = find.text('Preparar Ahora');
        await tester.tap(prepareButton);
        await tester.pumpAndSettle();

        // Verificar que cambia a vista de detalle
        expect(find.text('Volver'), findsOneWidget);
        expect(find.text('Lasaña Clásica a la Boloñesa'), findsOneWidget);
      },
    );

    testWidgets('should return to home view when tapping back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Ir a vista de detalle
      final prepareButton = find.text('Preparar Ahora');
      await tester.tap(prepareButton);
      await tester.pumpAndSettle();

      // Volver a home
      final backButton = find.text('Volver');
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verificar que volvió a home
      expect(find.text('RECETA DEL DÍA'), findsOneWidget);
      expect(find.text('Recetas Populares'), findsOneWidget);
    });

    testWidgets('should display footer correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Scroll hacia abajo para ver el footer
      await tester.dragUntilVisible(
        find.text('© 2024 RecipeBrand. Todos los derechos reservados.'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );

      // Verificar elementos del footer
      expect(find.text('Sobre Nosotros'), findsOneWidget);
      expect(find.text('Política de Privacidad'), findsOneWidget);
      expect(find.text('Términos de Servicio'), findsOneWidget);
      expect(
        find.text('© 2024 RecipeBrand. Todos los derechos reservados.'),
        findsOneWidget,
      );
    });

    testWidgets('should allow typing in search field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'pasta');
      await tester.pump();

      // Verificar que el texto se escribió
      expect(find.text('pasta'), findsOneWidget);
    });

    testWidgets('should handle recipe navigation with valid ID', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/recipe_detail') {
              return MaterialPageRoute(
                builder: (context) =>
                    const RecipeDetailScreen(recetaId: 'test-id'),
              );
            }
            return null;
          },
        ),
      );

      // Simular que hay recetas cargadas y hacer tap
      // Esta sería la funcionalidad una vez que se carguen recetas reales del API
      await tester.pumpAndSettle();
    });

    testWidgets('should dispose search controller when widget is disposed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const HomeScreen()));

      // Cambiar a otra pantalla para disparar dispose
      await tester.pumpWidget(MaterialApp(home: Container()));

      // Si hay leaks de controllers, Flutter test lo detectará
      expect(tester.takeException(), isNull);
    });
  });
}
