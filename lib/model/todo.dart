//import 'geopoint.dart';

class Todo {
  final int id;
  String title;
  bool isDone;
  final String? date;
  final String createdAt;
  final String? updatedAt;
  //#GeoPoint localisation;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.date,
    required this.createdAt,
    this.updatedAt,
  });

  // Fonction qui permet de récupérer les données depuis la BDD
  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
    id: map['id']?.toInt() ?? 0,
    title: map['title'] ?? '',
    //isDone: map['isDone'],
    date: map['date'] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']).toIso8601String(),
    updatedAt: map['updated_at'] == null
    // Vérifier s'il y a eu une modification
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['updated_at']).toIso8601String(),
  );

}