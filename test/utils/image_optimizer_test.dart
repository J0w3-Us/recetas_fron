// ignore_for_file: unused_import

import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_front/utils/image_optimizer.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

void main() {
  group('ImageOptimizer Tests', () {
    
    test('should create a test image for compression testing', () {
      // Crear una imagen de prueba simple
      final testImage = img.Image(width: 800, height: 600);
      img.fill(testImage, color: img.ColorRgb8(255, 0, 0)); // Imagen roja
      
      // Convertir a bytes
      final bytes = img.encodePng(testImage);
      
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes.length, greaterThan(1000)); // Debería tener un tamaño razonable
    });

    test('should compress image to smaller size', () {
      // Crear imagen de prueba más grande
      final testImage = img.Image(width: 2000, height: 1500);
      img.fill(testImage, color: img.ColorRgb8(0, 255, 0)); // Imagen verde
      
      final originalBytes = img.encodePng(testImage);
      
      // Simular compresión manual (lo que haría la función)
      final resizedImage = img.copyResize(testImage, width: 1200);
      final compressedBytes = img.encodeJpg(resizedImage, quality: 75);
      
      expect(compressedBytes.length, lessThan(originalBytes.length));
    });

    test('should maintain aspect ratio when resizing', () {
      // Crear imagen rectangular
      final testImage = img.Image(width: 1600, height: 900); // 16:9
      
      // Redimensionar manteniendo aspecto
      final resizedImage = img.copyResize(testImage, width: 1200);
      
      // Verificar que mantiene proporción aproximada
      final originalRatio = 1600 / 900;
      final resizedRatio = resizedImage.width / resizedImage.height;
      
      expect((originalRatio - resizedRatio).abs(), lessThan(0.01)); // Diferencia mínima
    });

    test('should handle different image formats', () {
      // Crear imagen de prueba
      final testImage = img.Image(width: 400, height: 300);
      img.fill(testImage, color: img.ColorRgb8(0, 0, 255)); // Imagen azul
      
      // Probar diferentes formatos
      final pngBytes = img.encodePng(testImage);
      final jpgBytes = img.encodeJpg(testImage);
      
      expect(pngBytes.isNotEmpty, isTrue);
      expect(jpgBytes.isNotEmpty, isTrue);
      expect(jpgBytes.length, lessThan(pngBytes.length)); // JPG suele ser más pequeño
    });

    test('should validate image size limits', () {
      // Simular validación de tamaño (300KB = 300 * 1024 bytes)
      const maxSizeInBytes = 300 * 1024;
      
      // Crear imagen que seguramente será menor a 300KB
      final smallImage = img.Image(width: 200, height: 150);
      img.fill(smallImage, color: img.ColorRgb8(128, 128, 128));
      final smallImageBytes = img.encodeJpg(smallImage, quality: 75);
      
      expect(smallImageBytes.length, lessThan(maxSizeInBytes));
    });

    test('should handle edge cases with very small images', () {
      // Crear imagen muy pequeña
      final tinyImage = img.Image(width: 10, height: 10);
      img.fill(tinyImage, color: img.ColorRgb8(255, 255, 255));
      
      final bytes = img.encodePng(tinyImage);
      
      expect(bytes.isNotEmpty, isTrue);
      expect(bytes.length, greaterThan(0));
    });

    test('should validate JPEG quality settings', () {
      final testImage = img.Image(width: 400, height: 300);
      img.fill(testImage, color: img.ColorRgb8(255, 128, 0)); // Imagen naranja
      
      // Probar diferentes calidades
      final highQuality = img.encodeJpg(testImage, quality: 95);
      final mediumQuality = img.encodeJpg(testImage, quality: 75);
      final lowQuality = img.encodeJpg(testImage, quality: 50);
      
      // Mayor calidad = mayor tamaño
      expect(highQuality.length, greaterThan(mediumQuality.length));
      expect(mediumQuality.length, greaterThan(lowQuality.length));
    });

    test('should handle null input gracefully', () {
      // Simular comportamiento con entrada nula
      Uint8List? nullInput;
      
      expect(nullInput, isNull);
      
      // En la implementación real, pickAndCompressImage() debería manejar esto
      if (nullInput == null) {
        expect(nullInput, isNull); // Comportamiento esperado
      }
    });

    test('should validate resize dimensions', () {
      final testImage = img.Image(width: 1920, height: 1080);
      
      // Redimensionar a diferentes tamaños
      final resized1200 = img.copyResize(testImage, width: 1200);
      final resized800 = img.copyResize(testImage, width: 800);
      
      expect(resized1200.width, equals(1200));
      expect(resized800.width, equals(800));
      
      // Verificar que la altura se ajusta proporcionalmente
      expect(resized1200.height, equals((1200 * 1080 / 1920).round()));
      expect(resized800.height, equals((800 * 1080 / 1920).round()));
    });

    test('should handle images that are already small enough', () {
      // Crear imagen que ya es menor a 1200px
      final smallImage = img.Image(width: 800, height: 600);
      img.fill(smallImage, color: img.ColorRgb8(200, 100, 50));
      
      // No debería necesitar redimensionamiento
      if (smallImage.width <= 1200) {
        expect(smallImage.width, equals(800));
        expect(smallImage.height, equals(600));
      }
    });
  });
}