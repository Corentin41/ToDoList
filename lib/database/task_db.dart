import 'package:todolist/database/database_service.dart';
import 'package:sqflite/sqflite.dart';
import '../model/task.dart';

class TaskDB {
  // Nom de la table
  final tableName = 'tasks';

  // Fonction qui permet de créer la table
  Future<void> createTable(Database database) async {
    await database.execute('CREATE TABLE $tableName '
        '(id INTEGER PRIMARY KEY,'
        ' name TEXT NOT NULL,'
        ' description TEXT NOT NULL,'
        ' priority INT NOT NULL,'
        ' isDone INT NOT NULL,'
        ' date TEXT,'
        ' lat TEXT,'
        ' lng TEXT,'
        ' address TEXT,'
        ' created_at INTEGER NOT NULL DEFAULT (cast(strftime(\'%s\',\'now\') as int)),'
        ' updated_at INTEGER'
        ')');
  }

  // Fonction qui permet d'insérer des données dans notre BDD
  Future<int> create({required String name, String? description, int? priority, String? date, String? lat, String? lng, String? address}) async {
    // Vérifier que la BDD existe
    final database = await DatabaseService().database;
    // Si oui alors on peut insérer des données
    return await database.rawInsert(
      '''INSERT INTO $tableName (name, description, priority, isDone, date, lat, lng, address, created_at) VALUES (?,?,?,?,?,?,?,?,?)''',
      // Par défaut isDone est à false (valeur 0) car la tâche créée n'est pas terminée
      [name, description, priority, 0, date, lat, lng, address, DateTime.now().millisecondsSinceEpoch],
    );
  }

  // Fonction pour récupérer les données de notre BDD (par date de création)
  Future<List<Task>> fetchAll(String sortPref) async {
    final database = await DatabaseService().database;
    final tasks = await database.rawQuery(
        '''SELECT * FROM $tableName ORDER BY isDone, $sortPref, created_at'''
    );
    return tasks.map((task) => Task.fromSqfliteDatabase(task)).toList();
  }

  // Fonction pour récupérer une tâche à partir de son id
  Future<Task> fetchById(int id) async {
    final database = await DatabaseService().database;
    final task = await database.rawQuery('''SELECT * FROM $tableName WHERE id = ?''', [id]);
    return Task.fromSqfliteDatabase(task.first);
  }

  // Fonction pour modifier une donnée dans la BDD à partir d'un id
  Future<int> update({required int id, String? name, String? description, int? priority, int? isDone, String? date, String? lat, String? lng, String? address}) async {
    final database = await DatabaseService().database;
    return await database.update(
        tableName,
        {
          // Faire une vérification sur l'existence de la donnée
          if (name != null) 'name' : name,
          if (description != null) 'description' : description,
          if (priority != null) 'priority' : priority,
          if (isDone != null) 'isDone' : isDone,
          if (date != null) 'date' : date,
          if (lat != null) 'lat' : lat,
          if (lng != null) 'lng' : lng,
          if (address != null) 'address' : address,
          'updated_at' : DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id]
    );
  }

  // Fonction pour supprimer une donnée de la BDD en fonction de son id
  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ?;''', [id]);
  }

}