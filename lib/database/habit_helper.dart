// lib/utils/database_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/habit_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE habits ( 
      id $idType, 
      title $textType,
      subtitle $textType,
      days $textType,
      color $integerType,
      isCompleted $integerType
    )
    ''');
  }

  // CREATE
  Future<Habit> create(Habit habit) async {
    final db = await instance.database;
    final id = await db.insert('habits', habit.toMap());
    return habit..id = id;
  }

  // READ All
  Future<List<Habit>> readAllHabits() async {
    final db = await instance.database;
    final result = await db.query('habits', orderBy: 'id DESC');
    return result.map((json) => Habit.fromMap(json)).toList();
  }

  // READ by Day
  Future<List<Habit>> readHabitsByDay(String day) async {
    final db = await instance.database;
    final result = await db.query(
      'habits',
      where: 'days LIKE ?',
      whereArgs: ['%$day%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Habit.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> update(Habit habit) async {
    final db = await instance.database;
    return db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // UPDATE Completion Status
  Future<void> toggleCompletion(Habit habit) async {
    habit.isCompleted = !habit.isCompleted;
    await update(habit);
  }

  // Reset all habits completion status (misalnya untuk hari baru)
  Future<void> resetAllCompletion() async {
    final db = await instance.database;
    await db.update('habits', {'isCompleted': 0});
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
