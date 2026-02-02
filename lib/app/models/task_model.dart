import 'package:flutter/material.dart';
import '../constants.dart';

// Models for Task, SubTask, Spam and Challenge
// A lightweight Spam Logic Service skeleton that uses flutter_local_notifications
// and timezone packages to schedule repeated notifications for locked challenges.
// NOTE: You must add `flutter_local_notifications` and `timezone` to your pubspec
// and initialize both (tz.initializeTimeZones() and plugin initialization) in
// your app startup code before using this service.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

enum ChallengeType { math, shake, tap }

class SubTask {
  String title;
  bool isDone;

  SubTask({required this.title, this.isDone = false});

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
    title: json['title'] as String? ?? '',
    isDone: json['isDone'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};
}

class Challenge {
  ChallengeType type;
  int difficulty;
  bool isLocked;

  Challenge({required this.type, this.difficulty = 1, this.isLocked = false});

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    type: ChallengeType.values.firstWhere(
      (e) => e.toString() == 'ChallengeType.' + (json['type'] ?? 'math'),
      orElse: () => ChallengeType.math,
    ),
    difficulty: json['difficulty'] as int? ?? 1,
    isLocked: json['isLocked'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'difficulty': difficulty,
    'isLocked': isLocked,
  };
}

class SpamSettings {
  bool isEnabled;
  int intervalSeconds;
  int maxRetries;
  bool isPersistent;

  SpamSettings({
    this.isEnabled = false,
    this.intervalSeconds = 30,
    this.maxRetries = 3,
    this.isPersistent = false,
  });

  factory SpamSettings.fromJson(Map<String, dynamic> json) => SpamSettings(
    isEnabled: json['isEnabled'] as bool? ?? false,
    intervalSeconds: json['intervalSeconds'] as int? ?? 30,
    maxRetries: json['maxRetries'] as int? ?? 3,
    isPersistent: json['isPersistent'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
    'intervalSeconds': intervalSeconds,
    'maxRetries': maxRetries,
    'isPersistent': isPersistent,
  };
}

class Schedule {
  DateTime? targetTime;
  List<int> repeatDays; // 1..7 for Mon..Sun (or use your mapping)
  bool isExact;

  Schedule({this.targetTime, this.repeatDays = const [], this.isExact = false});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    targetTime: json['targetTime'] != null
        ? DateTime.parse(json['targetTime'] as String)
        : null,
    repeatDays: (json['repeatDays'] as List<dynamic>?)?.cast<int>() ?? [],
    isExact: json['isExact'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'targetTime': targetTime?.toIso8601String(),
    'repeatDays': repeatDays,
    'isExact': isExact,
  };
}

class Task {
  String id;
  String title;
  String description;
  String category;
  String colorHex; // optional color stored as hex
  int priority; // 1..5

  Schedule schedule;
  SpamSettings spam;
  Challenge challenge;

  List<SubTask> subTasks;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.colorHex = '#FFFFFFFF',
    this.priority = 3,
    Schedule? schedule,
    SpamSettings? spam,
    Challenge? challenge,
    this.subTasks = const [],
  }) : schedule = schedule ?? Schedule(),
       spam = spam ?? SpamSettings(),
       challenge = challenge ?? Challenge(type: ChallengeType.math);

  // STATUS LOGIC: Main task is considered done only if ALL subtasks are done.
  bool get isDone => subTasks.isNotEmpty && subTasks.every((s) => s.isDone);

  // Toggle a subtask and return whether the whole task became done
  bool toggleSubTask(int index, bool done) {
    if (index < 0 || index >= subTasks.length) return isDone;
    subTasks[index].isDone = done;
    return isDone;
  }

  Color get doneButtonColor =>
      isDone ? AppConstants.success : AppConstants.pending;

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String? ?? UniqueKey().toString(),
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? '',
    colorHex: json['color'] as String? ?? '#FFFFFFFF',
    priority: json['priority'] as int? ?? 3,
    schedule: json['schedule'] != null
        ? Schedule.fromJson(json['schedule'])
        : Schedule(),
    spam: json['spam'] != null
        ? SpamSettings.fromJson(json['spam'])
        : SpamSettings(),
    challenge: json['challenge'] != null
        ? Challenge.fromJson(json['challenge'])
        : Challenge(type: ChallengeType.math),
    subTasks:
        (json['subTasks'] as List<dynamic>?)
            ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'color': colorHex,
    'priority': priority,
    'schedule': schedule.toJson(),
    'spam': spam.toJson(),
    'challenge': challenge.toJson(),
    'subTasks': subTasks.map((e) => e.toJson()).toList(),
  };
}

class SpamLogicService {
  final FlutterLocalNotificationsPlugin _plugin;

  SpamLogicService(this._plugin);

  Future<void> scheduleSpam(Task task) async {
    if (!task.spam.isEnabled) return;
    if (task.schedule.targetTime == null) return;

    // Construct the initial tz date
    final tz.TZDateTime scheduled = tz.TZDateTime.from(
      task.schedule.targetTime!,
      tz.local,
    );

    // If challenge is locked, we enforce repeating notifications that cannot be dismissed
    // until challenge completion. Implementation detail: we'll schedule repeating
    // notifications and check completion in app logic to cancel them.

    // NOTE: Android-only settings to make notifications persistent/dismissible would go
    // into NotificationDetails/android specifics. Here we demonstrate scheduling logic.

    final androidDetails = AndroidNotificationDetails(
      'spam_channel_${task.id}',
      'Spam Notifications',
      channelDescription: 'Repeated alarm for locked challenge',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: task
          .challenge
          .isLocked, // ongoing makes it persistent in some contexts
      autoCancel: !task.challenge.isLocked,
    );

    final details = NotificationDetails(android: androidDetails);

    // Schedule first occurrence
    await _plugin.zonedSchedule(
      id: task.id.hashCode,
      title: task.title,
      body: task.description,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // If locked and interval > 0, schedule additional repeating notifications
    if (task.challenge.isLocked && task.spam.intervalSeconds > 0) {
      // We'll schedule a periodic alarm using repeated zonedSchedule occurrences
      // Note: flutter_local_notifications doesn't provide arbitrary interval repeating
      // with zonedSchedule directly; a simple approach is to schedule multiple
      // instances or rely on platform alarm managers. Here is a minimal loop
      // scheduling next `maxRetries` occurrences spaced by `intervalSeconds`.

      for (int i = 1; i <= task.spam.maxRetries; i++) {
        final next = scheduled.add(
          Duration(seconds: task.spam.intervalSeconds * i),
        );
        await _plugin.zonedSchedule(
          id: task.id.hashCode + i,
          title: '${task.title} (reminder)',
          body: task.description,
          scheduledDate: tz.TZDateTime.from(next, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    }
  }

  Future<void> cancelSpam(Task task) async {
    // Cancel notifications associated with this task id
    await _plugin.cancel(id: task.id.hashCode);
    for (int i = 1; i <= task.spam.maxRetries; i++) {
      await _plugin.cancel(id: task.id.hashCode + i);
    }
  }
}
