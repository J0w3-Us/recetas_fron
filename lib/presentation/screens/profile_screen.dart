import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/create_recipe_widget.dart';
import 'login_screen.dart';
import 'recipe_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showCreateRecipe = false;

  void _toggleCreateRecipe() {
    setState(() {
      _showCreateRecipe = !_showCreateRecipe;
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
              child: _showCreateRecipe
                  ? _buildCreateRecipeView()
                  : _buildProfileView(),
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
          Text(
            'RecetasDeliciosas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),

          // Menú
          _buildNavLink('Inicio'),
          const SizedBox(width: 32),
          _buildNavLink('Explorar'),
          const SizedBox(width: 32),
          _buildNavLink('Favoritos'),
          const SizedBox(width: 32),

          // Notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),

          // Avatar
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Banner de perfil
          _buildProfileBanner(),
          const SizedBox(height: 40),
          // Botón crear receta
          SizedBox(
            width: 300,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _toggleCreateRecipe,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Crear Nueva Receta'),
            ),
          ),
          const SizedBox(height: 60),
          // Mis recetas
          _buildMyRecipes(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildProfileBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Ana García', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Amante de la cocina casera',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMyRecipes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Recetas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          FutureBuilder<List<dynamic>>(
            future: ApiService().obtenerMisRecetas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text('Error al cargar tus recetas: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final recetas = snapshot.data ?? [];
              if (recetas.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No tienes recetas creadas aún.\n¡Crea tu primera receta!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              // Organizar recetas en filas de 3
              final rows = <Widget>[];
              for (int i = 0; i < recetas.length; i += 3) {
                final rowRecetas = recetas.sublist(
                  i,
                  (i + 3).clamp(0, recetas.length),
                );
                rows.add(
                  Row(
                    children: [
                      for (int j = 0; j < rowRecetas.length; j++) ...[
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final receta =
                                  rowRecetas[j] as Map<String, dynamic>;
                              String getField(
                                List<String> keys, [
                                String def = 'Sin título',
                              ]) {
                                for (final k in keys) {
                                  final v = receta[k];
                                  if (v != null &&
                                      v.toString().trim().isNotEmpty)
                                    return v.toString();
                                }
                                return def;
                              }

                              String getId() =>
                                  (receta['id'] ??
                                          receta['_id'] ??
                                          receta['recetaId'] ??
                                          receta['receta_id'])
                                      ?.toString() ??
                                  '';

                              return RecipeCard(
                                title: getField([
                                  'titulo',
                                  'title',
                                  'name',
                                  'nombre',
                                ]),
                                description: 'Creado por ti',
                                imageUrl:
                                    receta['imagen_url'] ??
                                    receta['image_url'] ??
                                    receta['imagen'] ??
                                    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
                                onTap: () => _navigateToRecipeDetail(getId()),
                              );
                            },
                          ),
                        ),
                        if (j < rowRecetas.length - 1)
                          const SizedBox(width: 24),
                        if (j == rowRecetas.length - 1 && rowRecetas.length < 3)
                          ...List.generate(
                            3 - rowRecetas.length,
                            (index) => const Expanded(child: SizedBox()),
                          ),
                      ],
                    ],
                  ),
                );
                if (i + 3 < recetas.length) {
                  rows.add(const SizedBox(height: 24));
                }
              }

              return Column(children: rows);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToRecipeDetail(String recetaId) {
    if (recetaId.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID de receta inválido')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recetaId: recetaId),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await ApiService().cerrarSesion();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCreateRecipeView() {
    return Stack(
      children: [
        const CreateRecipeWidget(),
        Positioned(
          top: 20,
          left: 20,
          child: ElevatedButton.icon(
            onPressed: _toggleCreateRecipe,
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
