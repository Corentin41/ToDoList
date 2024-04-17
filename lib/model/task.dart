

class Task {
  final int id;
  String name;
  String description;
  int priority;
  int isDone;
  final String? date;
  final String? lat;
  final String? lng;
  final String? address;
  final String createdAt;
  final String? updatedAt;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.isDone,
    this.date,
    this.lat,
    this.lng,
    this.address,
    required this.createdAt,
    this.updatedAt,
  });

  // Fonction qui permet de récupérer les données depuis la BDD
  factory Task.fromSqfliteDatabase(Map<String, dynamic> task) => Task(
    id: task['id']?.toInt() ?? 0,
    name: task['name'] ?? '',
    description: task['description'] ?? '',
    priority: task['priority']?.toInt() ?? 2,
    isDone: task['isDone']?.toInt() ?? 0,
    date: task['date'] ?? '',
    lat: task['lat'] ?? '',
    lng: task['lng'] ?? '',
    address: task['address'] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(task['created_at']).toIso8601String(),
    updatedAt: task['updated_at'] == null
    // Vérifier s'il y a eu une modification
        ? null
        : DateTime.fromMillisecondsSinceEpoch(task['updated_at']).toIso8601String(),
  );

  double getDoubleLat() {
    return double.parse(lat!);
  }

  double getDoubleLng() {
    return double.parse(lng!);
  }

}