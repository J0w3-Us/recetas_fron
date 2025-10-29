import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';

class RecipeDetailWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String servings;
  final String difficulty;
  final List<String> ingredients;
  final List<Map<String, String>> steps;

  const RecipeDetailWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen hero
          Container(
            height: 400,
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Título y botones
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(width: 24),
                    CustomButton(
                      text: 'Imprimir',
                      onPressed: () {},
                      isOutlined: true,
                      icon: Icons.print,
                      backgroundColor: AppColors.secondary,
                      textColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'Guardar',
                      onPressed: () {},
                      icon: Icons.bookmark_outline,
                      backgroundColor: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Info cards
                Row(
                  children: [
                    _buildInfoCard(
                      context,
                      Icons.access_time,
                      time,
                      'Tiempo Total',
                    ),
                    const SizedBox(width: 24),
                    _buildInfoCard(
                      context,
                      Icons.people_outline,
                      servings,
                      'Porciones',
                    ),
                    const SizedBox(width: 24),
                    _buildInfoCard(
                      context,
                      Icons.bar_chart,
                      difficulty,
                      'Dificultad',
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // Ingredientes y Preparación
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildIngredients(context)),
                    const SizedBox(width: 60),
                    Expanded(flex: 6, child: _buildPreparation(context)),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 28),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredients(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredientes', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        ...ingredients.map(
          (ingredient) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ingredient,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preparación', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
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
                      if (step['title']?.isNotEmpty ?? false) ...[
                        Text(
                          step['title']!,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        step['description']!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
