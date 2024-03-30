import 'package:todolist/database/todo_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _database;

  // Fonction qui permet d'initialiser une BDD si elle n'existe pas
  Future<Database> get database async {
    // Si la BDD existe déjà
    if (_database != null) {
      return _database!;
    }
    // Sinon on crée la BDD
    else {
      _database = await _initialize();
      return _database!;
    }
  }

  // Fonction qui permet de récupérer le chemin de la BDD par défaut du device
  Future<String> get fullPath async {
    const name = 'todo.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  // Fonction qui permet de créer la BDD
  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  // Permet de créer une table dans notre BDD
  Future<void> create(Database database, int version) async =>
      await TodoDB().createTable(database);

}