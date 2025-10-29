import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_front/presentation/widgets/create_recipe_widget.dart';

void main() {
  group('CreateRecipeWidget Tests', () {
    testWidgets('should display all UI elements correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Verificar elementos principales
      expect(find.text('Comparte tu receta'), findsOneWidget);
      expect(
        find.text(
          'Rellena los detalles a continuación para añadir una nueva receta a nuestro libro de cocina.',
        ),
        findsOneWidget,
      );

      // Verificar campos del formulario
      expect(find.text('Título de la receta'), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
      expect(find.text('Subir Foto'), findsOneWidget);
      expect(find.text('Ingredientes'), findsOneWidget);
      expect(find.text('Pasos'), findsOneWidget);
      expect(find.text('Publicar Receta'), findsOneWidget);
    });

    testWidgets('should have initial form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Verificar campos de entrada iniciales
      expect(
        find.byType(TextFormField),
        findsNWidgets(5),
      ); // Título, descripción, 2 ingredientes, 1 paso

      // Verificar botones para añadir más elementos
      expect(find.text('Añadir Ingrediente'), findsOneWidget);
      expect(find.text('Añadir Paso'), findsOneWidget);
    });

    testWidgets('should add ingredient field when tapping add ingredient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Contar campos iniciales
      expect(find.byType(TextFormField), findsNWidgets(5));

      // Añadir ingrediente
      final addIngredientButton = find.text('Añadir Ingrediente');
      await tester.tap(addIngredientButton);
      await tester.pump();

      // Verificar que se añadió un campo más
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('should add step field when tapping add step', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Contar campos iniciales
      expect(find.byType(TextFormField), findsNWidgets(5));

      // Añadir paso
      final addStepButton = find.text('Añadir Paso');
      await tester.tap(addStepButton);
      await tester.pump();

      // Verificar que se añadió un campo más
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('should remove ingredient field when tapping delete', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Añadir un ingrediente extra para poder eliminar
      final addIngredientButton = find.text('Añadir Ingrediente');
      await tester.tap(addIngredientButton);
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(6));

      // Buscar y presionar botón de eliminar
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pump();

      // Verificar que se eliminó el campo
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('should remove step field when tapping delete', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Añadir un paso extra para poder eliminar
      final addStepButton = find.text('Añadir Paso');
      await tester.tap(addStepButton);
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(6));

      // Buscar y presionar botón de eliminar del paso
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.last);
      await tester.pump();

      // Verificar que se eliminó el campo
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('should display photo upload area', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Verificar elementos del área de subida de foto
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
      expect(find.text('Sube un archivo'), findsOneWidget);
      expect(find.text('o arrastra y suelta'), findsOneWidget);
      expect(find.text('PNG, JPG, GIF hasta 10MB'), findsOneWidget);
    });

    testWidgets('should display upload photo button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Verificar botón de subir foto
      expect(find.text('Subir Foto'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('should show numbered steps correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Verificar que el primer paso tiene número 1
      expect(find.text('1'), findsOneWidget);

      // Añadir otro paso
      final addStepButton = find.text('Añadir Paso');
      await tester.tap(addStepButton);
      await tester.pump();

      // Verificar que ahora hay números 1 y 2
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should fill form fields correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      final textFields = find.byType(TextFormField);

      // Llenar campos básicos
      await tester.enterText(textFields.at(0), 'Tarta de Manzana'); // Título
      await tester.enterText(
        textFields.at(1),
        'Una deliciosa tarta casera',
      ); // Descripción
      await tester.enterText(
        textFields.at(2),
        '3 manzanas',
      ); // Primer ingrediente
      await tester.enterText(
        textFields.at(3),
        '200g harina',
      ); // Segundo ingrediente
      await tester.enterText(
        textFields.at(4),
        'Pelar las manzanas',
      ); // Primer paso

      await tester.pump();

      // Verificar que los valores se llenaron
      expect(find.text('Tarta de Manzana'), findsOneWidget);
      expect(find.text('Una deliciosa tarta casera'), findsOneWidget);
      expect(find.text('3 manzanas'), findsOneWidget);
      expect(find.text('200g harina'), findsOneWidget);
      expect(find.text('Pelar las manzanas'), findsOneWidget);
    });

    testWidgets(
      'should show validation message when trying to submit without image',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
        );

        final textFields = find.byType(TextFormField);

        // Llenar solo los campos de texto (sin imagen)
        await tester.enterText(textFields.at(0), 'Tarta de Manzana');
        await tester.enterText(textFields.at(1), 'Una deliciosa tarta casera');
        await tester.enterText(textFields.at(2), '3 manzanas');
        await tester.enterText(textFields.at(4), 'Pelar las manzanas');

        // Intentar publicar
        final publishButton = find.text('Publicar Receta');
        await tester.tap(publishButton);
        await tester.pump();

        // Verificar mensaje de error por falta de imagen
        expect(
          find.text('Por favor, sube una imagen de la receta'),
          findsOneWidget,
        );
      },
    );

    testWidgets('should dispose controllers when widget is disposed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: const Scaffold(body: CreateRecipeWidget())),
      );

      // Cambiar a otra pantalla para disparar dispose
      await tester.pumpWidget(MaterialApp(home: Container()));

      // Si hay leaks de controllers, Flutter test lo detectará
      expect(tester.takeException(), isNull);
    });
  });
}
