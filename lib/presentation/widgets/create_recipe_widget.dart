import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../widgets/custom_button.dart';

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



    setState(() => _isLoading = true);

    try {
      // Preparar datos de la receta

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

      // Validar que tengamos datos mínimos requeridos
      if (ingredientes.isEmpty) {
        throw Exception('Debes agregar al menos un ingrediente');
      }

      if (pasos.isEmpty) {
        throw Exception('Debes agregar al menos un paso');
      }

      // Crear receta sin imagen por ahora, ya que la base de datos no tiene la columna image_url
      final datosReceta = {
        'name': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients': ingredientes,
        'steps': pasos,
      };

      await ApiService().crearReceta(datosReceta);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Receta publicada con éxito!'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        // Mostrar diálogo de error detallado
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error al Crear Receta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No se pudo crear la receta:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(e.toString().replaceFirst('Exception: ', '')),
                  const SizedBox(height: 16),
                  const Text(
                    '💡 Información para desarrolladores:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verifica que:\n'
                    '• El backend esté ejecutándose en localhost:3000\n'
                    '• El endpoint POST /api/recetas esté implementado\n'
                    '• Los datos enviados tengan el formato correcto\n'
                    '• Revisa los logs en la consola para más detalles',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es obligatorio';
                      }
                      if (value.trim().length < 3) {
                        return 'El título debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un ingrediente';
                  }
                  return null;
                },
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
              decoration: BoxDecoration(
                color: Colors.blue[600],
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Describe este paso';
                  }
                  return null;
                },
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
