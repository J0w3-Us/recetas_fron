import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recetaId;

  const RecipeDetailScreen({super.key, required this.recetaId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ApiService _apiService = ApiService();
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
    _recetaFuture = _apiService.obtenerRecetaPorId(widget.recetaId);
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
                color: Colors.orange[600],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
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
          TextButton(onPressed: () {}, child: const Text('Inicio')),
          TextButton(onPressed: () {}, child: const Text('Categorías')),
          TextButton(onPressed: () {}, child: const Text('Populares')),
          TextButton(onPressed: () {}, child: const Text('Sobre Nosotros')),
          const SizedBox(width: 20),
          Container(
            width: 200,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.grey, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar recetas...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Imagen principal de la receta
                Container(
                  width: double.infinity,
                  height: 400,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(
                        receta['imagen_url'] ??
                            'https://images.unsplash.com/photo-1481931098730-318b6f776db0?w=600',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Contenido de la receta
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 40,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna izquierda - Título y botones
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título principal
                            Text(
                              _getStringFieldFrom(receta, [
                                'titulo',
                                'title',
                                'name',
                                'nombre',
                              ], 'Lasaña Clásica a la Boloñesa'),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Botones de acción
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.orange[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_border,
                                        color: Colors.orange[600],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Imprimir',
                                        style: TextStyle(
                                          color: Colors.orange[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Guardar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Información de tiempo, porciones y dificultad
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.access_time,
                                  '90 min',
                                  'Tiempo Total',
                                ),
                                const SizedBox(width: 40),
                                _buildInfoItem(
                                  Icons.people,
                                  '6 personas',
                                  'Porciones',
                                ),
                                const SizedBox(width: 40),
                                _buildInfoItem(
                                  Icons.signal_cellular_alt,
                                  'Intermedia',
                                  'Dificultad',
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Sección de Ingredientes
                            _buildIngredientsSection(receta),
                          ],
                        ),
                      ),

                      const SizedBox(width: 80),

                      // Columna derecha - Preparación
                      Expanded(flex: 2, child: _buildStepsSection(receta)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange[600], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildIngredientsSection(Map<String, dynamic> receta) {
    final ingredientes = _getListFieldFrom(receta, [
      'ingredientes',
      'ingredients',
    ]);

    // Si no hay ingredientes, usar una lista de ejemplo
    final ingredientesList = ingredientes.isEmpty
        ? [
            '500g de carne picada (mitad cerdo, mitad ternera)',
            '12 láminas de lasaña',
            '1 cebolla grande, picada',
            '2 dientes de ajo, picados',
            '800g de tomate triturado',
            '1L de leche entera',
            '60g de mantequilla',
            '60g de harina',
            '200g de queso Parmesano rallado',
            'Aceite de oliva, sal, pimienta y nuez moscada',
          ]
        : ingredientes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredientes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        ...ingredientesList.map<Widget>((ingrediente) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    ingrediente.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
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

    // Si no hay pasos, usar una lista de ejemplo
    final pasosList = pasos.isEmpty
        ? [
            'Salsa Boloñesa: Sofríe la cebolla y el ajo en aceite de oliva. Añade la carne picada y dorar. Incorpora el tomate triturado, sal, pimienta y cocinar a fuego lento durante 45 minutos.',
            'Salsa Bechamel: Derretir la mantequilla, añadir la harina y cocinar por 1 minuto. Verter la leche poco a poco, sin dejar de remover, hasta que espese. Sazonar con sal, pimienta y nuez moscada.',
            'Precalentar el horno a 180°C (350°F). Cocer las láminas de lasaña según las instrucciones del paquete si no son precocidas.',
            'Montaje: En una fuente para horno, pon una capa de bechamel, seguida de láminas de lasaña, salsa boloñesa, bechamel y queso Parmesano. Repetir hasta usar todos los ingredientes, acabando con una capa de bechamel y abundante queso.',
            'Horneado: Hornear durante 30-40 minutos o hasta que la superficie esté dorada y burbujeante. Dejar reposar 10 minutos antes de servir. ¡Buen provecho!',
          ]
        : pasos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preparación',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        ...pasosList.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final paso = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
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
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
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
