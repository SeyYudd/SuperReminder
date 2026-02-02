import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../utils/app_logger.dart';

/// Repository for task CRUD operations
class TaskRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'super_reminder.db');

      AppLogger.info('Initializing database at: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              category TEXT,
              priority INTEGER DEFAULT 3,
              targetTime TEXT,
              subTasks TEXT,
              isNotificationEnabled INTEGER DEFAULT 0
            )
          ''');
          AppLogger.info('Database tables created successfully');
        },
      );
    } catch (e, stack) {
      AppLogger.error('Failed to initialize database', e, stack);
      rethrow;
    }
  }

  Future<List<TaskModel>> getAllTasks() async {
    try {
      final db = await database;
      final result = await db.query('tasks', orderBy: 'targetTime DESC');

      AppLogger.debug('Fetched ${result.length} tasks from database');

      return result.map((json) {
        final subTasksJson = json['subTasks'] as String?;
        final subTasks = subTasksJson != null && subTasksJson.isNotEmpty
            ? (jsonDecode(subTasksJson) as List)
                  .map((e) => SubTask.fromJson(e))
                  .toList()
            : <SubTask>[];

        return TaskModel(
          id: json['id'] as String,
          title: json['title'] as String,
          description: json['description'] as String? ?? '',
          category: json['category'] as String? ?? '',
          priority: json['priority'] as int? ?? 3,
          targetTime: json['targetTime'] != null
              ? DateTime.tryParse(json['targetTime'] as String)
              : null,
          subTasks: subTasks,
          isNotificationEnabled:
              (json['isNotificationEnabled'] as int? ?? 0) == 1,
          createdAt: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
          updatedAt: json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
        );
      }).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to fetch tasks', e, stack);
      return [];
    }
  }

  Future<void> insertTask(TaskModel task) async {
    try {
      final db = await database;
      await db.insert('tasks', {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'priority': task.priority,
        'targetTime': task.targetTime?.toIso8601String(),
        'subTasks': jsonEncode(task.subTasks.map((e) => e.toJson()).toList()),
        'isNotificationEnabled': task.isNotificationEnabled ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      AppLogger.info('Task inserted: ${task.title}');
    } catch (e, stack) {
      AppLogger.error('Failed to insert task', e, stack);
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await database;
      await db.update(
        'tasks',
        {
          'title': task.title,
          'description': task.description,
          'category': task.category,
          'priority': task.priority,
          'targetTime': task.targetTime?.toIso8601String(),
          'subTasks': jsonEncode(task.subTasks.map((e) => e.toJson()).toList()),
          'isNotificationEnabled': task.isNotificationEnabled ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [task.id],
      );
      AppLogger.info('Task updated: ${task.title}');
    } catch (e, stack) {
      AppLogger.error('Failed to update task', e, stack);
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final db = await database;
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
      AppLogger.info('Task deleted: $id');
    } catch (e, stack) {
      AppLogger.error('Failed to delete task', e, stack);
      rethrow;
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    try {
      final db = await database;
      final result = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );

      if (result.isEmpty) {
        AppLogger.warning('Task not found: $taskId');
        return;
      }

      final taskData = result.first;
      final subTasksJson = taskData['subTasks'] as String?;

      if (subTasksJson == null || subTasksJson.isEmpty) {
        AppLogger.warning('No subtasks found for task: $taskId');
        return;
      }

      final subTasks = (jsonDecode(subTasksJson) as List)
          .map((e) => SubTask.fromJson(e))
          .toList();

      final index = subTasks.indexWhere((s) => s.id == subTaskId);
      if (index != -1) {
        subTasks[index] = subTasks[index].copyWith(
          isDone: !subTasks[index].isDone,
        );

        await db.update(
          'tasks',
          {'subTasks': jsonEncode(subTasks.map((e) => e.toJson()).toList())},
          where: 'id = ?',
          whereArgs: [taskId],
        );
        AppLogger.debug('Subtask toggled: $subTaskId');
      }
    } catch (e, stack) {
      AppLogger.error('Failed to toggle subtask', e, stack);
      rethrow;
    }
  }
}
