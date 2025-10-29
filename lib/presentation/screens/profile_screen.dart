import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'recipe_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    print('👤 [PROFILE] Cargando nombre de usuario');
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');
    print('👤 [PROFILE] Nombre de usuario: $userName');
    setState(() {
      _userName = userName;
    });
  }

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'RecetasDeliciosas',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text('Inicio'),
          ),
          TextButton(onPressed: () {}, child: const Text('Explorar')),
          TextButton(onPressed: () {}, child: const Text('Favoritos')),
          const SizedBox(width: 20),
          PopupMenuButton<String>(
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header del perfil
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
              child: Column(
                children: [
                  // Avatar y nombre
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1494790108755-2616b612b977?w=200',
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _userName ?? 'Ana García',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Amante de la cocina casera',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 30),

                  // Botón Crear Nueva Receta
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-recipe');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Crear Nueva Receta',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Sección Mis Recetas
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis Recetas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Grid de recetas
                  FutureBuilder<List<dynamic>>(
                    future: ApiService().obtenerMisRecetas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print('👤 [PROFILE] Cargando mis recetas...');
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        print(
                          '❌ [PROFILE] Error cargando recetas: ${snapshot.error}',
                        );
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Text(
                              'Error al cargar tus recetas: ${snapshot.error}',
                            ),
                          ),
                        );
                      }

                      final recetas = snapshot.data ?? [];
                      print('👤 [PROFILE] ${recetas.length} recetas cargadas');

                      if (recetas.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(60),
                            child: Text(
                              'No tienes recetas creadas aún.\n¡Crea tu primera receta!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: recetas.length,
                        itemBuilder: (context, index) {
                          final receta = recetas[index];
                          return _buildRecipeCard(receta);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> receta) {
    return GestureDetector(
      onTap: () => _navigateToRecipeDetail(_getRecipeId(receta)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRecipeString(receta, [
                        'titulo',
                        'title',
                        'name',
                        'nombre',
                      ]),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Tiempo de preparación: 30 min',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRecipeDetail(String recetaId) {
    print('👤 [PROFILE] Navegando a receta ID: $recetaId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recetaId: recetaId),
      ),
    );
  }

  Future<void> _handleLogout() async {
    print('🚪 [PROFILE] Iniciando logout');
    try {
      await ApiService().cerrarSesion();
      print('✅ [PROFILE] Logout exitoso');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      print('❌ [PROFILE] Error en logout: $e');
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
}
