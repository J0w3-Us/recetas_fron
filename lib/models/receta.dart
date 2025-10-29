// lib/models/receta.dart
class Receta {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String? imageUrl;
  final bool isPublic;
  final String userId;

  Receta({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    required this.isPublic,
    required this.userId,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      imageUrl: json['imageUrl'],
      isPublic: json['is_public'],
      userId: json['userId'],
    );
  }
}