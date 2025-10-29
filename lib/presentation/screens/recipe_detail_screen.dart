import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recetaId;

  const RecipeDetailScreen({super.key, required this.recetaId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Map<String, dynamic>> _recetaFuture;

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

  @override
  void initState() {
    super.initState();
    _recetaFuture = ApiService().obtenerRecetaPorId(widget.recetaId);
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
}
