import 'package:equatable/equatable.dart';

/// SubTask model for task checklist items
class SubTask extends Equatable {
  final String id;
  final String title;
  final bool isDone;

  const SubTask({required this.id, required this.title, this.isDone = false});

  SubTask copyWith({String? id, String? title, bool? isDone}) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String? ?? DateTime.now().toIso8601String(),
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  @override
  List<Object?> get props => [id, title, isDone];
}

/// Task model with sublist support
class TaskModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority;
  final DateTime? targetTime;
  final List<SubTask> subTasks;
  final bool isNotificationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = '',
    this.priority = 3,
    this.targetTime,
    this.subTasks = const [],
    this.isNotificationEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Task is complete only when ALL subtasks are done
  bool get isCompleted =>
      subTasks.isNotEmpty && subTasks.every((s) => s.isDone);

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? priority,
    DateTime? targetTime,
    List<SubTask>? subTasks,
    bool? isNotificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      targetTime: targetTime ?? this.targetTime,
      subTasks: subTasks ?? this.subTasks,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return TaskModel(
      id: json['id'] as String? ?? now.toIso8601String(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      priority: json['priority'] as int? ?? 3,
      targetTime: json['targetTime'] != null
          ? DateTime.tryParse(json['targetTime'] as String)
          : null,
      subTasks:
          (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : now,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    priority,
    targetTime,
    subTasks,
    isNotificationEnabled,
    createdAt,
    updatedAt,
  ];
}
