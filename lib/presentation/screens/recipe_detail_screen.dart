import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recetaId;

  const RecipeDetailScreen({super.key, required this.recetaId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _recetaFuture;
  String? _currentUserId;

  // Helpers to read API fields that may have different names
  String _getStringFieldFrom(
    Map<String, dynamic> receta,
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final k in keys) {
      final v = receta[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return fallback;
  }

  List<dynamic> _getListFieldFrom(
    Map<String, dynamic> receta,
    List<String> keys,
  ) {
    for (final k in keys) {
      final v = receta[k];
      if (v is List<dynamic>) return v;
    }
    return <dynamic>[];
  }

  String _getRecipeId(Map<String, dynamic> receta) {
    return (receta['id'] ??
                receta['_id'] ??
                receta['recetaId'] ??
                receta['receta_id'])
            ?.toString() ??
        '';
  }

  String _getUserId(Map<String, dynamic> receta) {
    return (receta['userId'] ?? receta['user_id'] ?? receta['usuario_id'])
            ?.toString() ??
        '';
  }

  @override
  void initState() {
    super.initState();
    _recetaFuture = _apiService.obtenerRecetaPorId(widget.recetaId);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = await _apiService.getCurrentUserId();
    setState(() {}); // Actualiza la UI cuando el ID del usuario está disponible
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recetaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final receta = snapshot.data!;
          // Use class-level helpers (_getStringFieldFrom / _getListFieldFrom) below
          return CustomScrollView(
            slivers: [
              // Header con imagen
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                actions: _buildAppBarActions(receta),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        receta['imagen_url'] ??
                            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 64,
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido de la receta
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        _getStringFieldFrom(receta, [
                          'titulo',
                          'title',
                          'name',
                          'nombre',
                        ], 'Sin título'),
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      Text(
                        _getStringFieldFrom(receta, [
                          'descripcion',
                          'description',
                        ], 'Sin descripción'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Información adicional
                      Row(
                        children: [
                          _buildInfoCard(Icons.access_time, 'Tiempo', '30 min'),
                          const SizedBox(width: 16),
                          _buildInfoCard(Icons.people, 'Porciones', '4'),
                          const SizedBox(width: 16),
                          _buildInfoCard(Icons.star, 'Dificultad', 'Medio'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Contenido de la receta (ingredientes y pasos)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ingredientes
                          Expanded(
                            flex: 1,
                            child: _buildIngredientsSection(receta),
                          ),
                          const SizedBox(width: 32),

                          // Pasos
                          Expanded(flex: 2, child: _buildStepsSection(receta)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(Map<String, dynamic> receta) {
    final ingredientes = _getListFieldFrom(receta, [
      'ingredientes',
      'ingredients',
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredientes',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...ingredientes.map<Widget>((ingrediente) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    ingrediente.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepsSection(Map<String, dynamic> receta) {
    final pasos = _getListFieldFrom(receta, ['pasos', 'preparacion', 'steps']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preparación',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...pasos.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final paso = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 16),
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
                  child: Text(
                    paso.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildAppBarActions(Map<String, dynamic> receta) {
    if (_currentUserId == null) return [];

    final recetaUserId = _getUserId(receta);

    // Solo mostrar botones si el usuario actual es el dueño de la receta
    if (recetaUserId == _currentUserId) {
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEditRecipe(receta),
          tooltip: 'Editar receta',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () =>
              _mostrarDialogoEliminar(context, _getRecipeId(receta)),
          tooltip: 'Eliminar receta',
        ),
      ];
    }

    return [];
  }

  void _navigateToEditRecipe(Map<String, dynamic> receta) async {
    print('🔧 [RECIPE_DETAIL] Navegando a pantalla de edición');
    print('🔧 [RECIPE_DETAIL] Datos de receta: ${receta.keys.toList()}');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditRecipeScreen(receta: receta)),
    );

    print('🔧 [RECIPE_DETAIL] Resultado de edición: $result');

    // Si se actualizó la receta, recargar los datos
    if (result == true) {
      print('🔧 [RECIPE_DETAIL] Receta actualizada, recargando datos...');
      setState(() {
        _recetaFuture = _apiService.obtenerRecetaPorId(widget.recetaId);
      });
    }
  }

  void _mostrarDialogoEliminar(BuildContext context, String recetaId) {
    print('🗑️ [RECIPE_DETAIL] Iniciando proceso de eliminación');
    print('🗑️ [RECIPE_DETAIL] ID de receta: $recetaId');
    
    if (recetaId.trim().isEmpty) {
      print('❌ [RECIPE_DETAIL] ID de receta vacío o inválido');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID de receta inválido')));
      return;
    }

    print('🗑️ [RECIPE_DETAIL] Mostrando diálogo de confirmación');
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta receta? Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () async {
                print('🗑️ [RECIPE_DETAIL] Usuario confirmó eliminación');
                Navigator.of(ctx).pop(); // Cerrar diálogo
                await _eliminarReceta(recetaId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarReceta(String recetaId) async {
    try {
      print('🗑️ [RECIPE_DETAIL] Iniciando proceso de eliminación para receta: $recetaId');
      
      // Mostrar indicador de carga
      print('🗑️ [RECIPE_DETAIL] Mostrando indicador de carga');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Eliminando receta...'),
            ],
          ),
        ),
      );

      print('🗑️ [RECIPE_DETAIL] Llamando a API para eliminar receta');
      await _apiService.eliminarReceta(recetaId);

      if (mounted) {
        print('🗑️ [RECIPE_DETAIL] Eliminación exitosa, cerrando diálogos y navegando');
        Navigator.of(context).pop(); // Cerrar indicador de carga
        Navigator.of(context).pop(); // Volver a la pantalla anterior

        print('✅ [RECIPE_DETAIL] Mostrando mensaje de éxito');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receta eliminada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar indicador de carga

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la receta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
