import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Receta'),
      ),
      body: const Center(
        child: Text('Aquí se creará una nueva receta'),
      ),
    );
  }
}