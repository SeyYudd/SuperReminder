import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:super_reminder/app/controllers/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = "tasks";
  static const String _reminderTable = "reminders";

  static Future<void> initDB() async {
    if (_db != null) {
      return;
    }
    try {
      String path = await getDatabasesPath() + 'tasks.db';
      _db = await openDatabase(
        path,
        version: _version,
        onCreate: (db, version) {
          debugPrint("creating a new one");
          return db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title STRING, note TEXT, date STRING, "
            "startTime STRING, endTime STRING, "
            "remind INTEGER, repeat STRING, "
            "color INTEGER, "
            "isCompleted INTEGER, "
            "dateArr STRING)",
          );
        },
      );
      // create reminders table for new schema
      await _db!.execute('''
        CREATE TABLE IF NOT EXISTS $_reminderTable(
          id TEXT PRIMARY KEY,
          title TEXT,
          description TEXT,
          display TEXT,
          schedule TEXT,
          spam TEXT,
          challenge TEXT,
          status TEXT
        )
      ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<int> insert(Task? task) async {
    debugPrint("insert function called");
    return await _db?.insert(_tableName, task!.toJson()) ?? 1;
  }

  // Reminders CRUD - store JSON blobs for flexible schema
  static Future<int> insertReminder(Map<String, dynamic> reminder) async {
    return await _db!.insert(_reminderTable, reminder);
  }

  static Future<List<Map<String, dynamic>>> queryReminders() async {
    return await _db!.query(_reminderTable);
  }

  static Future<int> updateReminder(
      String id, Map<String, dynamic> reminder) async {
    return await _db!
        .update(_reminderTable, reminder, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteReminder(String id) async {
    return await _db!.delete(_reminderTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    debugPrint("query called");
    return await _db!.query(_tableName);
  }

  static delete(Task task) async {
    return await _db!.delete(_tableName, where: 'id=?', whereArgs: [task.id]);
  }

  static update(int id) async {
    return await _db!.rawUpdate('''
      UPDATE tasks
      SET isCompleted = ?
      WHERE id= ?
    ''', [1, id]);
  }

  static updateDaily(int id, String dateTime) async {
    //  String dateTimeStr = "[" + dateTime.toString() + "]";

    return await _db!.rawUpdate('''
      UPDATE tasks
      SET dateArr = ?
      WHERE id= ?      
    ''', [dateTime, id]);
  }

  static getById(
    int id,
  ) async {
    //   return await _db!.query(_tableName, where: "id = " + id.toString());
    return await _db!
        .rawQuery('Select dateArr from tasks where id = $id');
  }
}
