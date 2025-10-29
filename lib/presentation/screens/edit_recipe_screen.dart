import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class EditRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> receta;

  const EditRecipeScreen({super.key, required this.receta});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _imagenUrlController;
  late List<TextEditingController> _ingredientesControllers;
  late List<TextEditingController> _pasosControllers;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final receta = widget.receta;

    // Obtener título con soporte para múltiples nombres de campo
    final titulo = _getStringField(receta, [
      'titulo',
      'title',
      'name',
      'nombre',
    ]);
    final descripcion = _getStringField(receta, ['descripcion', 'description']);
    final imagenUrl = _getStringField(receta, [
      'imagen_url',
      'image_url',
      'imagen',
    ]);

    _tituloController = TextEditingController(text: titulo);
    _descripcionController = TextEditingController(text: descripcion);
    _imagenUrlController = TextEditingController(text: imagenUrl);

    // Obtener ingredientes
    final ingredientes = _getListField(receta, ['ingredientes', 'ingredients']);
    _ingredientesControllers = ingredientes
        .map(
          (ingrediente) => TextEditingController(text: ingrediente.toString()),
        )
        .toList();
    if (_ingredientesControllers.isEmpty) {
      _ingredientesControllers.add(TextEditingController());
    }

    // Obtener pasos
    final pasos = _getListField(receta, ['pasos', 'steps', 'preparacion']);
    _pasosControllers = pasos
        .map((paso) => TextEditingController(text: paso.toString()))
        .toList();
    if (_pasosControllers.isEmpty) {
      _pasosControllers.add(TextEditingController());
    }
  }

  String _getStringField(
    Map<String, dynamic> data,
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  List<dynamic> _getListField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List<dynamic>) return value;
    }
    return <dynamic>[];
  }

  String _getRecipeId() {
    return (widget.receta['id'] ??
                widget.receta['_id'] ??
                widget.receta['recetaId'] ??
                widget.receta['receta_id'])
            ?.toString() ??
        '';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _imagenUrlController.dispose();
    for (final controller in _ingredientesControllers) {
      controller.dispose();
    }
    for (final controller in _pasosControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Editar Receta'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _guardarReceta, child: const Text('Guardar')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Información Básica',
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _tituloController,
                      label: 'Título de la receta',
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
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La descripción es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _imagenUrlController,
                      label: 'URL de la imagen (opcional)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildSection(
                title: 'Ingredientes',
                child: _buildIngredientesSection(),
              ),

              const SizedBox(height: 32),

              _buildSection(
                title: 'Pasos de preparación',
                child: _buildPasosSection(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColors.backgroundSecondary,
      ),
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }

  Widget _buildIngredientesSection() {
    return Column(
      children: [
        ..._ingredientesControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Ingrediente ${index + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                    ),
                    validator: (value) {
                      if (index == 0 &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Debe haber al menos un ingrediente';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (_ingredientesControllers.length > 1)
                  IconButton(
                    onPressed: () => _removerIngrediente(index),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _agregarIngrediente,
            icon: const Icon(Icons.add),
            label: const Text('Agregar ingrediente'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasosSection() {
    return Column(
      children: [
        ..._pasosControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(top: 12, right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Paso ${index + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (index == 0 &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Debe haber al menos un paso';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (_pasosControllers.length > 1)
                  IconButton(
                    onPressed: () => _removerPaso(index),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _agregarPaso,
            icon: const Icon(Icons.add),
            label: const Text('Agregar paso'),
          ),
        ),
      ],
    );
  }

  void _agregarIngrediente() {
    setState(() {
      _ingredientesControllers.add(TextEditingController());
    });
  }

  void _removerIngrediente(int index) {
    if (_ingredientesControllers.length > 1) {
      setState(() {
        _ingredientesControllers[index].dispose();
        _ingredientesControllers.removeAt(index);
      });
    }
  }

  void _agregarPaso() {
    setState(() {
      _pasosControllers.add(TextEditingController());
    });
  }

  void _removerPaso(int index) {
    if (_pasosControllers.length > 1) {
      setState(() {
        _pasosControllers[index].dispose();
        _pasosControllers.removeAt(index);
      });
    }
  }

  Future<void> _guardarReceta() async {
    print('📝 [EDIT_RECIPE] Iniciando guardado de receta...');

    if (!_formKey.currentState!.validate()) {
      print('❌ [EDIT_RECIPE] Validación del formulario falló');
      return;
    }

    final recetaId = _getRecipeId();
    print('📝 [EDIT_RECIPE] ID de receta obtenido: $recetaId');

    if (recetaId.isEmpty) {
      print('❌ [EDIT_RECIPE] ID de receta vacío o inválido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID de receta inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('📝 [EDIT_RECIPE] Iniciando estado de carga...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('📝 [EDIT_RECIPE] Preparando datos para actualización...');

      // Filtrar ingredientes y pasos vacíos
      final ingredientes = _ingredientesControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final pasos = _pasosControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      print(
        '📝 [EDIT_RECIPE] Ingredientes procesados: ${ingredientes.length} elementos',
      );
      print('📝 [EDIT_RECIPE] Pasos procesados: ${pasos.length} elementos');

      final datosActualizados = {
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'ingredientes': ingredientes,
        'pasos': pasos,
        if (_imagenUrlController.text.trim().isNotEmpty)
          'imagen_url': _imagenUrlController.text.trim(),
      };

      print('📝 [EDIT_RECIPE] Datos preparados: $datosActualizados');

      print('📝 [EDIT_RECIPE] Llamando API para actualizar receta...');
      await _apiService.actualizarReceta(recetaId, datosActualizados);

      if (mounted) {
        print(
          '✅ [EDIT_RECIPE] Receta actualizada exitosamente, navegando de vuelta...',
        );
        Navigator.pop(context, true); // Regresar con resultado exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Receta actualizada con éxito!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ [EDIT_RECIPE] Error durante actualización: $e');
      print('❌ [EDIT_RECIPE] Tipo de error: ${e.runtimeType}');

      if (mounted) {
        String errorMessage = 'Error al actualizar la receta';

        // Personalizar mensaje según el tipo de error
        final errorString = e.toString();
        print('📝 [EDIT_RECIPE] Analizando tipo de error: $errorString');

        if (errorString.contains('endpoint no está disponible')) {
          print('📝 [EDIT_RECIPE] Error de endpoint no disponible detectado');
          // Mostrar información para desarrolladores
          _showDeveloperInfo(context);
          return;
        } else if (errorString.contains('No se pudo conectar')) {
          print('📝 [EDIT_RECIPE] Error de conexión detectado');
          errorMessage =
              'No se pudo conectar al servidor.\n'
              'Verifica que el backend esté ejecutándose.';
        } else if (errorString.contains('404')) {
          print('📝 [EDIT_RECIPE] Error 404 detectado');
          errorMessage =
              'Receta no encontrada o función no implementada en el servidor.';
        } else if (errorString.contains('403')) {
          print('📝 [EDIT_RECIPE] Error 403 detectado');
          errorMessage = 'No tienes permisos para editar esta receta.';
        } else if (errorString.contains('400')) {
          print('📝 [EDIT_RECIPE] Error 400 detectado');
          errorMessage = 'Datos inválidos. Verifica todos los campos.';
        } else {
          print('📝 [EDIT_RECIPE] Error genérico detectado');
        }

        // Mostrar diálogo de error más detallado
        print('📝 [EDIT_RECIPE] Mostrando diálogo de error al usuario');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error al actualizar'),
                ],
              ),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        print('📝 [EDIT_RECIPE] Finalizando estado de carga...');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Función en desarrollo'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'La función de editar recetas está lista en el frontend, pero necesita que el backend implemente el endpoint correspondiente.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'Para el desarrollador del backend:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '• Implementar: PUT /api/recetas/:id\n'
                  '• Validar permisos de usuario\n'
                  '• Retornar JSON con receta actualizada\n'
                  '• Ver API_DOCUMENTATION.md para detalles',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                SizedBox(height: 16),
                Text(
                  'Una vez implementado, esta función funcionará automáticamente.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Volver a la pantalla anterior
              },
              child: const Text('Volver'),
            ),
          ],
        );
      },
    );
  }
}
