import 'package:credestest/modelClass.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    // Create the tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        projectName TEXT,
        imagePath TEXT,
        dueDate TEXT
      )
    ''');

    // Corrected subtasks table creation
    await db.execute('''
      CREATE TABLE subtasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        projectId TEXT,
        isCompleted INTEGER
      )
    ''');
  }

  // Task-related functions
  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Subtask-related functions
  Future<void> insertSubtasks(List<SubTaskModel> subtasks) async {
    final db = await database;
    final batch = db.batch();
    for (var subtask in subtasks) {
      batch.insert('subtasks', subtask.toMap());
    }
    await batch.commit();
  }

  Future<List<SubTaskModel>> getSubtasksForProject(String projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subtasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
    return List.generate(maps.length, (i) {
      return SubTaskModel.fromMap(maps[i]);
    });
  }

  Future<void> updateSubtask(SubTaskModel subtask) async {
    final db = await database;
    await db.update(
      'subtasks',
      subtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<void> deleteSubtask(int id) async {
    final db = await database;
    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }
}
