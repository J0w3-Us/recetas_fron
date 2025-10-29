import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_detail_widget.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showRecipeDetail = false;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleRecipeDetail() {
    setState(() {
      _showRecipeDetail = !_showRecipeDetail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Contenido
            Expanded(
              child: _showRecipeDetail
                  ? _buildRecipeDetailView()
                  : _buildHomeView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Logo
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text('RecipeBrand', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),

          // Barra de búsqueda
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const Spacer(),

          // Menú
          _buildNavLink('Inicio'),
          const SizedBox(width: 32),
          _buildNavLink('Recetas'),
          const SizedBox(width: 32),
          _buildNavLink('Blog'),
          const SizedBox(width: 32),
          _buildNavLink('Contacto'),
          const SizedBox(width: 24),

          // Avatar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Receta destacada
          _buildFeaturedRecipe(),
          const SizedBox(height: 60),
          // Recetas populares
          _buildPopularRecipes(),
          const SizedBox(height: 60),
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFeaturedRecipe() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        children: [
          // Imagen
          Expanded(
            flex: 5,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 60),

          // Información
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECETA DEL DÍA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pasta Fresca al Pesto con Tomates Cherry',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Una explosión de sabor mediterráneo en tu paladar. Nuestra receta del día combina la frescura de la albahaca, el toque salado del parmesano y la dulzura de los tomates cherry para crear un plato inolvidable y fácil de preparar.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _toggleRecipeDetail,
                  child: const Text('Preparar Ahora'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRecipes() {
    return Column(
      children: [
        Text(
          'Recetas Populares',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: FutureBuilder<List<dynamic>>(
            future: () {
              print(
                '🏠 [HOME] Iniciando carga de recetas desde el FutureBuilder',
              );
              return ApiService().obtenerTodasLasRecetas();
            }(),
            builder: (context, snapshot) {
              print(
                '🏠 [HOME] FutureBuilder - Estado: ${snapshot.connectionState}',
              );

              if (snapshot.connectionState == ConnectionState.waiting) {
                print('🏠 [HOME] Esperando respuesta de la API...');
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print('❌ [HOME] Error en FutureBuilder: ${snapshot.error}');
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text('Error al cargar las recetas: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final recetas = snapshot.data ?? [];
              print('🏠 [HOME] Recetas recibidas: ${recetas.length}');

              if (recetas.isEmpty) {
                print('⚠️ [HOME] No se encontraron recetas');
                return const Center(child: Text('No hay recetas disponibles'));
              }

              // Mostrar las primeras 3 recetas
              final recetasLimitadas = recetas.take(3).toList();
              print(
                '🏠 [HOME] Mostrando ${recetasLimitadas.length} recetas en la UI',
              );

              return Row(
                children: recetasLimitadas.asMap().entries.map((entry) {
                  final receta = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: entry.key < recetasLimitadas.length - 1 ? 24 : 0,
                      ),
                      child: RecipeCard(
                        title: _getRecipeString(receta, [
                          'titulo',
                          'title',
                          'name',
                          'nombre',
                        ], 'Sin título'),
                        description: _getRecipeString(receta, [
                          'descripcion',
                          'description',
                        ], 'Sin descripción'),
                        imageUrl:
                            receta['imagen_url'] ??
                            receta['image_url'] ??
                            receta['imagen'] ??
                            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
                        onTap: () =>
                            _navigateToRecipeDetail(_getRecipeId(receta)),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Sobre Nosotros'),
              const SizedBox(width: 40),
              _buildFooterLink('Política de Privacidad'),
              const SizedBox(width: 40),
              _buildFooterLink('Términos de Servicio'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.camera_alt),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.link),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.chat),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2024 RecipeBrand. Todos los derechos reservados.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: Icon(icon, size: 18, color: Colors.grey[700]),
    );
  }

  Widget _buildRecipeDetailView() {
    return Stack(
      children: [
        RecipeDetailWidget(
          title: 'Lasaña Clásica a la Boloñesa',
          imageUrl:
              'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=1200',
          time: '90 min',
          servings: '8 personas',
          difficulty: 'Intermedia',
          ingredients: const [
            '500g de carne picada (mitad cerdo, mitad ternera)',
            '12 láminas de lasaña',
            '1 cebolla grande, picada',
            '2 dientes de ajo, picados',
            '800g de tomate triturado',
            '1L de leche',
            '60g de mantequilla',
            '60g de harina',
            '200g de queso Parmesano rallado',
            'Aceite de oliva, sal, pimienta y nuez moscada',
          ],
          steps: const [
            {
              'title': 'Salsa Boloñesa:',
              'description':
                  'Sofríe la cebolla y el ajo en aceite de oliva. Añade la carne picada y dora. Incorpora el tomate triturado, sal, pimienta y cocina a fuego lento durante 45 minutos.',
            },
            {
              'title': 'Salsa Bechamel:',
              'description':
                  'Derrite la mantequilla, añade la harina y cocina por 1 minuto (roux). Vierte la leche poco a poco, sin dejar de remover, hasta que espese. Sazona con sal, pimienta y nuez moscada.',
            },
            {
              'title': '',
              'description':
                  'Precalienta el horno a 180°C (350°F). Cocer las láminas de lasaña según las instrucciones del paquete, si no son precocidas.',
            },
            {
              'title': 'Montaje:',
              'description':
                  'En una fuente de horno, poner una capa de bechamel, seguida de láminas de lasaña, salsa boloñesa, bechamel y queso Parmesano. Repetir hasta terminar los ingredientes, acabando con una capa de bechamel y abundante queso.',
            },
            {
              'title': 'Horneado:',
              'description':
                  'Hornear durante 30-40 minutos, o hasta que la superficie esté dorada y burbujante. Dejar reposar 10 minutos antes de servir. ¡Buen provecho!',
            },
          ],
        ),
        Positioned(
          top: 20,
          left: 20,
          child: ElevatedButton.icon(
            onPressed: _toggleRecipeDetail,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Volver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
