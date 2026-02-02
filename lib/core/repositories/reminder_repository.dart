import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/models/reminder_model.dart';
import '../../core/utils/app_logger.dart';

class ReminderRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'reminders.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE reminders(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              category TEXT NOT NULL,
              priority TEXT NOT NULL,
              status TEXT NOT NULL,
              scheduling TEXT NOT NULL,
              spamConfiguration TEXT NOT NULL,
              metadata TEXT NOT NULL
            )
          ''');
          AppLogger.info('Reminders database created');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing reminders database', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('reminders');

      AppLogger.debug('Fetched ${maps.length} reminders from database');

      return List.generate(maps.length, (i) {
        return ReminderModel.fromJson({
          'id': maps[i]['id'],
          'title': maps[i]['title'],
          'description': maps[i]['description'],
          'category': jsonDecode(maps[i]['category']),
          'priority': jsonDecode(maps[i]['priority']),
          'status': jsonDecode(maps[i]['status']),
          'scheduling': jsonDecode(maps[i]['scheduling']),
          'spamConfiguration': jsonDecode(maps[i]['spamConfiguration']),
          'metadata': jsonDecode(maps[i]['metadata']),
        });
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching reminders', e, stackTrace);
      return [];
    }
  }

  Future<ReminderModel?> getReminderById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminders',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final map = maps.first;
      return ReminderModel.fromJson({
        'id': map['id'],
        'title': map['title'],
        'description': map['description'],
        'category': jsonDecode(map['category']),
        'priority': jsonDecode(map['priority']),
        'status': jsonDecode(map['status']),
        'scheduling': jsonDecode(map['scheduling']),
        'spamConfiguration': jsonDecode(map['spamConfiguration']),
        'metadata': jsonDecode(map['metadata']),
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching reminder by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> insertReminder(ReminderModel reminder) async {
    try {
      final db = await database;
      await db.insert('reminders', {
        'id': reminder.id,
        'title': reminder.title,
        'description': reminder.description,
        'category': jsonEncode(reminder.category.toJson()),
        'priority': jsonEncode(reminder.priority.toJson()),
        'status': jsonEncode(reminder.status.toJson()),
        'scheduling': jsonEncode(reminder.scheduling.toJson()),
        'spamConfiguration': jsonEncode(reminder.spamConfiguration.toJson()),
        'metadata': jsonEncode(reminder.metadata.toJson()),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      AppLogger.info('Reminder inserted: ${reminder.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Error inserting reminder', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    try {
      final db = await database;
      await db.update(
        'reminders',
        {
          'title': reminder.title,
          'description': reminder.description,
          'category': jsonEncode(reminder.category.toJson()),
          'priority': jsonEncode(reminder.priority.toJson()),
          'status': jsonEncode(reminder.status.toJson()),
          'scheduling': jsonEncode(reminder.scheduling.toJson()),
          'spamConfiguration': jsonEncode(reminder.spamConfiguration.toJson()),
          'metadata': jsonEncode(reminder.metadata.toJson()),
        },
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
      AppLogger.info('Reminder updated: ${reminder.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating reminder', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final db = await database;
      await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
      AppLogger.info('Reminder deleted: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting reminder', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ReminderModel>> getActiveReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders
          .where((r) => !r.status.isCompleted && r.status.isNotificationEnabled)
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching active reminders', e, stackTrace);
      return [];
    }
  }

  Future<List<ReminderModel>> getSpamEnabledReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders
          .where(
            (r) =>
                r.spamConfiguration.isSpamEnabled &&
                !r.status.isCompleted &&
                r.status.isNotificationEnabled,
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching spam-enabled reminders', e, stackTrace);
      return [];
    }
  }
}
