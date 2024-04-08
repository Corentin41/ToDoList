//import 'geopoint.dart';

class Todo {
  final int id;
  String title;
  String description;
  int priority;
  int isDone;
  final String? date;
  final String createdAt;
  final String? updatedAt;
  //#GeoPoint localisation;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isDone,
    this.date,
    required this.createdAt,
    this.updatedAt,
  });

  // Fonction qui permet de récupérer les données depuis la BDD
  factory Todo.fromSqfliteDatabase(Map<String, dynamic> todo) => Todo(
    id: todo['id']?.toInt() ?? 0,
    title: todo['title'] ?? '',
    description: todo['description'] ?? '',
    priority: todo['priority']?.toInt() ?? 2,
    isDone: todo['isDone']?.toInt() ?? 0,
    date: todo['date'] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(todo['created_at']).toIso8601String(),
    updatedAt: todo['updated_at'] == null
    // Vérifier s'il y a eu une modification
        ? null
        : DateTime.fromMillisecondsSinceEpoch(todo['updated_at']).toIso8601String(),
  );

}