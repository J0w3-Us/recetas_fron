import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../../utils/image_optimizer.dart';

class CreateRecipeWidget extends StatefulWidget {
  const CreateRecipeWidget({super.key});

  @override
  State<CreateRecipeWidget> createState() => _CreateRecipeWidgetState();
}

class _CreateRecipeWidgetState extends State<CreateRecipeWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];
  Uint8List? _compressedImageData;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que haya imagen
    if (_compressedImageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, sube una imagen de la receta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Preparar ingredientes (filtrar vacíos)
      final ingredientes = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Preparar pasos (filtrar vacíos)
      final pasos = _stepControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Para esta demo, usamos una URL de imagen placeholder
      // En una implementación real, aquí subirías _compressedImageData a Supabase Storage
      final datosReceta = {
        'titulo': _titleController.text.trim(),
        'descripcion': _descriptionController.text.trim(),
        'ingredientes': ingredientes,
        'pasos': pasos,
        'imagen_url':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600', // Placeholder
      };

      await ApiService().crearReceta(datosReceta);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Receta publicada con éxito!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la receta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal
                  Center(
                    child: Text(
                      'Comparte tu receta',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Rellena los detalles a continuación para añadir una nueva receta a nuestro libro de cocina.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campo Título
                  Text(
                    'Título de la receta',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Tarta de Manzana Clásica',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo Descripción
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe brevemente tu receta...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subir Foto
                  Text(
                    'Subir Foto',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildPhotoUpload(),
                  const SizedBox(height: 8),

                  // Botón explícito para subir/cambiar foto (opción adicional)
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final data = await pickAndCompressImage();
                        if (data != null) {
                          setState(() {
                            _compressedImageData = data;
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        _compressedImageData == null
                            ? 'Subir Foto'
                            : 'Cambiar Foto',
                      ),
                    ),
                  ),

                  if (_compressedImageData != null)
                    Center(
                      child: Column(
                        children: [
                          Image.memory(_compressedImageData!, height: 180),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _compressedImageData = null;
                              });
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar foto'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Ingredientes
                  Text(
                    'Ingredientes',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  ..._buildIngredientFields(),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Añadir Ingrediente'),
                  ),
                  const SizedBox(height: 32),

                  // Pasos
                  Text('Pasos', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 12),
                  ..._buildStepFields(),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Añadir Paso'),
                  ),
                  const SizedBox(height: 48),

                  // Botón Publicar
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: CustomButton(
                        text: 'Publicar Receta',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: InkWell(
        onTap: () async {
          // Abrir selector y comprimir la imagen
          final data = await pickAndCompressImage();
          if (data != null) {
            setState(() {
              _compressedImageData = data;
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sube un archivo',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'o arrastra y suelta',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'PNG, JPG, GIF hasta 10MB',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIngredientFields() {
    return List.generate(_ingredientControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ingredientControllers[index],
                decoration: const InputDecoration(
                  hintText: 'Ej: 1 taza de harina',
                ),
              ),
            ),
            if (_ingredientControllers.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                onPressed: () => _removeIngredient(index),
              ),
            ],
          ],
        ),
      );
    });
  }

  List<Widget> _buildStepFields() {
    return List.generate(_stepControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stepControllers[index],
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Describe este paso...',
                ),
              ),
            ),
            if (_stepControllers.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                onPressed: () => _removeStep(index),
              ),
            ],
          ],
        ),
      );
    });
  }
}
