//import 'geopoint.dart';

class Todo {
  final int id;
  String title;
  int isDone;
  final String? date;
  final String createdAt;
  final String? updatedAt;
  final String? lat;
  final String? lng;

  Todo({
    required this.id,
    required this.title,
    required this.isDone,
    this.date,
    required this.createdAt,
    this.updatedAt,
    this.lat,
    this.lng
  });

  // Fonction qui permet de récupérer les données depuis la BDD
  factory Todo.fromSqfliteDatabase(Map<String, dynamic> todo) => Todo(
    id: todo['id']?.toInt() ?? 0,
    title: todo['title'] ?? '',
    isDone: todo['isDone']?.toInt() ?? 0,
    date: todo['date'] ?? '',
    lat: todo['lat'] ?? '',
    lng: todo['lng'] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(todo['created_at']).toIso8601String(),
    updatedAt: todo['updated_at'] == null
    // Vérifier s'il y a eu une modification
        ? null
        : DateTime.fromMillisecondsSinceEpoch(todo['updated_at']).toIso8601String(),
  );

  double getDoubleLat() {
    return double.parse(lat!);
  }

  double getDoubleLng() {
    return double.parse(lng!);
  }

}