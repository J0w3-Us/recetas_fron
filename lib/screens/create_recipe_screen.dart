import 'package:flutter/material.dart';
import '../presentation/widgets/create_recipe_widget.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

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
          const SizedBox(width: 20),
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 16,
            child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: const CreateRecipeWidget(),
    );
  }
}
