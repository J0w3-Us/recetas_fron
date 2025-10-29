import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Imagen hero
                    _buildHeroImage(),

                    // Contenido principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          // Título y botones
                          _buildTitleSection(),
                          const SizedBox(height: 40),
                          // Info cards (tiempo, porciones, dificultad)
                          _buildInfoCards(),
                          const SizedBox(height: 50),
                          // Ingredientes y Preparación
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: _buildIngredients()),
                              const SizedBox(width: 60),
                              Expanded(flex: 6, child: _buildPreparation()),
                            ],
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) {
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
              color: Colors.orange[400],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'RecetasDeliciosas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),

          // Menú de navegación
          _buildNavLink('Inicio'),
          const SizedBox(width: 32),
          _buildNavLink('Categorías'),
          const SizedBox(width: 32),
          _buildNavLink('Populares'),
          const SizedBox(width: 32),
          _buildNavLink('Sobre Nosotros'),
          const SizedBox(width: 32),

          // Buscador
          Container(
            width: 200,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=1200',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Lasaña Clásica a la Boloñesa',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Botón Imprimir
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.print, size: 18),
          label: const Text('Imprimir'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange[600],
            side: BorderSide(color: Colors.orange[600]!),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Guardar
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.bookmark_outline, size: 18),
          label: const Text('Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        _buildInfoCard(Icons.access_time, '90 min', 'Tiempo Total'),
        const SizedBox(width: 24),
        _buildInfoCard(Icons.people_outline, '8 personas', 'Porciones'),
        const SizedBox(width: 24),
        _buildInfoCard(Icons.bar_chart, 'Intermedia', 'Dificultad'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange[600], size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredientes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        _buildIngredientItem(
          '500g de carne picada (mitad cerdo, mitad ternera)',
        ),
        _buildIngredientItem('12 láminas de lasaña'),
        _buildIngredientItem('1 cebolla grande, picada'),
        _buildIngredientItem('2 dientes de ajo, picados'),
        _buildIngredientItem('800g de tomate triturado'),
        _buildIngredientItem('1L de leche'),
        _buildIngredientItem('60g de mantequilla'),
        _buildIngredientItem('60g de harina'),
        _buildIngredientItem('200g de queso Parmesano rallado'),
        _buildIngredientItem('Aceite de oliva, sal, pimienta y nuez moscada'),
      ],
    );
  }

  Widget _buildIngredientItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preparación',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        _buildPreparationStep(
          1,
          'Salsa Boloñesa:',
          'Sofríe la cebolla y el ajo en aceite de oliva. Añade la carne picada y dora. Incorpora el tomate triturado, sal, pimienta y cocina a fuego lento durante 45 minutos.',
        ),
        _buildPreparationStep(
          2,
          'Salsa Bechamel:',
          'Derrite la mantequilla, añade la harina y cocina por 1 minuto (roux). Vierte la leche poco a poco, sin dejar de remover, hasta que espese. Sazona con sal, pimienta y nuez moscada.',
        ),
        _buildPreparationStep(
          3,
          '',
          'Precalienta el horno a 180°C (350°F). Cocer las láminas de lasaña según las instrucciones del paquete, si no son precocidas.',
        ),
        _buildPreparationStep(
          4,
          'Montaje:',
          'En una fuente de horno, poner una capa de bechamel, seguida de láminas de lasaña, salsa boloñesa, bechamel y queso Parmesano. Repetir hasta terminar los ingredientes, acabando con una capa de bechamel y abundante queso.',
        ),
        _buildPreparationStep(
          5,
          'Horneado:',
          'Hornear durante 30-40 minutos, o hasta que la superficie esté dorada y burbujante. Dejar reposar 10 minutos antes de servir. ¡Buen provecho!',
        ),
      ],
    );
  }

  Widget _buildPreparationStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.orange[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
