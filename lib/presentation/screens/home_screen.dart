import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getRecipeString(
    Map<String, dynamic> receta,
    List<String> keys, [
    String fallback = 'Sin título',
  ]) {
    for (final k in keys) {
      final val = receta[k];
      if (val != null) {
        final s = val.toString();
        if (s.trim().isNotEmpty) return s;
      }
    }
    return fallback;
  }

  String _getRecipeId(Map<String, dynamic> receta) {
    return (receta['id'] ??
                receta['_id'] ??
                receta['recetaId'] ??
                receta['receta_id'])
            ?.toString() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'RecipeBrand',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Inicio',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black54),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().obtenerTodasLasRecetas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar las recetas: ${snapshot.error}'),
            );
          }

          final recetas = snapshot.data ?? [];

          if (recetas.isEmpty) {
            return const Center(child: Text('No hay recetas disponibles'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receta destacada del día
                _buildFeaturedRecipe(recetas.isNotEmpty ? recetas[0] : null),

                const SizedBox(height: 60),

                // Sección de Recetas Populares
                _buildPopularRecipes(recetas),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedRecipe(Map<String, dynamic>? receta) {
    if (receta == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      child: Row(
        children: [
          // Imagen de la receta
          Expanded(
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(
                    receta['imagen_url'] ??
                        receta['image_url'] ??
                        'https://images.unsplash.com/photo-1481931098730-318b6f776db0?w=600',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(width: 60),

          // Contenido de la receta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'RECETA DEL DÍA',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _getRecipeString(receta, [
                    'titulo',
                    'title',
                    'name',
                    'nombre',
                  ], 'Pasta Fresca al Pesto con Tomates Cherry'),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _getRecipeString(
                    receta,
                    ['descripcion', 'description'],
                    'Una explosión de sabor mediterráneo en tu paladar. Nuestra receta de día combina la frescura de la albahaca, el toque salado del parmesano y la dulzura de los tomates cherry para crear un plato inolvidable y fácil de preparar.',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () =>
                      _navigateToRecipeDetail(_getRecipeId(receta)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Preparar Ahora',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRecipes(List<dynamic> recetas) {
    final popularRecipes = recetas.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recetas Populares',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 40),

          Row(
            children: popularRecipes.asMap().entries.map((entry) {
              final index = entry.key;
              final receta = entry.value;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < popularRecipes.length - 1 ? 24 : 0,
                  ),
                  child: _buildPopularRecipeCard(receta),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildPopularRecipeCard(Map<String, dynamic> receta) {
    return GestureDetector(
      onTap: () => _navigateToRecipeDetail(_getRecipeId(receta)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    receta['imagen_url'] ??
                        receta['image_url'] ??
                        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getRecipeString(receta, [
                      'titulo',
                      'title',
                      'name',
                      'nombre',
                    ], 'Receta Deliciosa'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _getRecipeString(
                      receta,
                      ['descripcion', 'description'],
                      'Una deliciosa receta que te encantará preparar y disfrutar.',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecipeDetail(String recetaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recetaId: recetaId),
      ),
    );
  }
}
