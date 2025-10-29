import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

/// Abre el selector de imágenes, redimensiona/comprime la imagen y devuelve
/// los bytes listos para subir o previsualizar.
Future<Uint8List?> pickAndCompressImage() async {
  final picker = ImagePicker();
  final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);

  if (imageFile == null) return null;

  final Uint8List originalBytes = await imageFile.readAsBytes();
  img.Image? originalImage = img.decodeImage(originalBytes);

  if (originalImage == null) return null;

  // Redimensionar a un ancho máximo de 1200px manteniendo la proporción.
  img.Image resizedImage = img.copyResize(originalImage, width: 1200);

  // Comprimir con una calidad de 75 (buen balance para el plan gratuito).
  final Uint8List compressedBytes = Uint8List.fromList(
    img.encodeJpg(resizedImage, quality: 75),
  );

  // Opcional: validar que el tamaño sea menor a 300KB
  if ((compressedBytes.lengthInBytes / 1024) > 300) {
    print('La imagen sigue siendo muy grande después de comprimir.');
    return null; // O re-comprimir con menor calidad
  }

  return compressedBytes;
}
