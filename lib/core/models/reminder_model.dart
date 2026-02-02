import 'package:equatable/equatable.dart';

/// Scheduling mode enumeration
enum SchedulingMode { exact, inexact }

/// Frequency enumeration
enum ReminderFrequency { once, daily, weekly, custom }

/// Category model for reminder categorization
class ReminderCategory extends Equatable {
  final String tag;
  final String icon;
  final String color;

  const ReminderCategory({
    required this.tag,
    required this.icon,
    required this.color,
  });

  factory ReminderCategory.fromJson(Map<String, dynamic> json) {
    return ReminderCategory(
      tag: json['tag'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tag': tag, 'icon': icon, 'color': color};
  }

  @override
  List<Object?> get props => [tag, icon, color];
}

/// Priority configuration for reminder
class ReminderPriority extends Equatable {
  final int level; // 1-5
  final String channelId;

  const ReminderPriority({required this.level, required this.channelId});

  factory ReminderPriority.fromJson(Map<String, dynamic> json) {
    return ReminderPriority(
      level: json['level'] as int,
      channelId: json['channelId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'level': level, 'channelId': channelId};
  }

  @override
  List<Object?> get props => [level, channelId];
}

/// Status tracking for reminder
class ReminderStatus extends Equatable {
  final bool isCompleted;
  final bool isNotificationEnabled;
  final bool isSnoozed;

  const ReminderStatus({
    required this.isCompleted,
    required this.isNotificationEnabled,
    required this.isSnoozed,
  });

  factory ReminderStatus.fromJson(Map<String, dynamic> json) {
    return ReminderStatus(
      isCompleted: json['isCompleted'] as bool,
      isNotificationEnabled: json['isNotificationEnabled'] as bool,
      isSnoozed: json['isSnoozed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCompleted': isCompleted,
      'isNotificationEnabled': isNotificationEnabled,
      'isSnoozed': isSnoozed,
    };
  }

  ReminderStatus copyWith({
    bool? isCompleted,
    bool? isNotificationEnabled,
    bool? isSnoozed,
  }) {
    return ReminderStatus(
      isCompleted: isCompleted ?? this.isCompleted,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      isSnoozed: isSnoozed ?? this.isSnoozed,
    );
  }

  @override
  List<Object?> get props => [isCompleted, isNotificationEnabled, isSnoozed];
}

/// Scheduling configuration for reminder
class ReminderScheduling extends Equatable {
  final SchedulingMode mode;
  final ReminderFrequency frequency;
  final DateTime targetTimestamp;
  final List<int> repeatDays; // 0-6 (Sunday-Saturday)
  final int reminderWindow; // in minutes

  const ReminderScheduling({
    required this.mode,
    required this.frequency,
    required this.targetTimestamp,
    required this.repeatDays,
    required this.reminderWindow,
  });

  factory ReminderScheduling.fromJson(Map<String, dynamic> json) {
    return ReminderScheduling(
      mode: SchedulingMode.values.firstWhere(
        (e) => e.name == json['mode'].toString().toLowerCase(),
        orElse: () => SchedulingMode.exact,
      ),
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'].toString().toLowerCase(),
        orElse: () => ReminderFrequency.once,
      ),
      targetTimestamp: DateTime.parse(json['targetTimestamp'] as String),
      repeatDays: (json['repeatDays'] as List<dynamic>).cast<int>(),
      reminderWindow: json['reminderWindow'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name.toUpperCase(),
      'frequency': frequency.name.toUpperCase(),
      'targetTimestamp': targetTimestamp.toIso8601String(),
      'repeatDays': repeatDays,
      'reminderWindow': reminderWindow,
    };
  }

  @override
  List<Object?> get props => [
    mode,
    frequency,
    targetTimestamp,
    repeatDays,
    reminderWindow,
  ];
}

/// Spam intensity configuration
class SpamIntensity extends Equatable {
  final int intervalSeconds;
  final List<int> vibrationPattern;
  final String soundUri;

  const SpamIntensity({
    required this.intervalSeconds,
    required this.vibrationPattern,
    required this.soundUri,
  });

  factory SpamIntensity.fromJson(Map<String, dynamic> json) {
    return SpamIntensity(
      intervalSeconds: json['intervalSeconds'] as int,
      vibrationPattern: (json['vibrationPattern'] as List<dynamic>).cast<int>(),
      soundUri: json['soundUri'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intervalSeconds': intervalSeconds,
      'vibrationPattern': vibrationPattern,
      'soundUri': soundUri,
    };
  }

  @override
  List<Object?> get props => [intervalSeconds, vibrationPattern, soundUri];
}

/// Spam constraints configuration
class SpamConstraints extends Equatable {
  final int maxSpamCount;
  final bool stopOnAppOpen;
  final bool ignoreDoNotDisturb;

  const SpamConstraints({
    required this.maxSpamCount,
    required this.stopOnAppOpen,
    required this.ignoreDoNotDisturb,
  });

  factory SpamConstraints.fromJson(Map<String, dynamic> json) {
    return SpamConstraints(
      maxSpamCount: json['maxSpamCount'] as int,
      stopOnAppOpen: json['stopOnAppOpen'] as bool,
      ignoreDoNotDisturb: json['ignoreDoNotDisturb'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxSpamCount': maxSpamCount,
      'stopOnAppOpen': stopOnAppOpen,
      'ignoreDoNotDisturb': ignoreDoNotDisturb,
    };
  }

  @override
  List<Object?> get props => [maxSpamCount, stopOnAppOpen, ignoreDoNotDisturb];
}

/// Spam configuration for aggressive reminders
class SpamConfiguration extends Equatable {
  final bool isSpamEnabled;
  final SpamIntensity intensity;
  final SpamConstraints constraints;
  final bool autoDeleteAfterShow;

  const SpamConfiguration({
    required this.isSpamEnabled,
    required this.intensity,
    required this.constraints,
    required this.autoDeleteAfterShow,
  });

  factory SpamConfiguration.fromJson(Map<String, dynamic> json) {
    return SpamConfiguration(
      isSpamEnabled: json['isSpamEnabled'] as bool,
      intensity: SpamIntensity.fromJson(
        json['intensity'] as Map<String, dynamic>,
      ),
      constraints: SpamConstraints.fromJson(
        json['constraints'] as Map<String, dynamic>,
      ),
      autoDeleteAfterShow: json['autoDeleteAfterShow'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSpamEnabled': isSpamEnabled,
      'intensity': intensity.toJson(),
      'constraints': constraints.toJson(),
      'autoDeleteAfterShow': autoDeleteAfterShow,
    };
  }

  @override
  List<Object?> get props => [
    isSpamEnabled,
    intensity,
    constraints,
    autoDeleteAfterShow,
  ];
}

/// Metadata for tracking reminder information
class ReminderMetadata extends Equatable {
  final DateTime createdAt;
  final DateTime? lastFiredAt;
  final String deviceId;

  const ReminderMetadata({
    required this.createdAt,
    this.lastFiredAt,
    required this.deviceId,
  });

  factory ReminderMetadata.fromJson(Map<String, dynamic> json) {
    return ReminderMetadata(
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastFiredAt: json['lastFiredAt'] != null
          ? DateTime.parse(json['lastFiredAt'] as String)
          : null,
      deviceId: json['deviceId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'lastFiredAt': lastFiredAt?.toIso8601String(),
      'deviceId': deviceId,
    };
  }

  ReminderMetadata copyWith({
    DateTime? createdAt,
    DateTime? lastFiredAt,
    String? deviceId,
  }) {
    return ReminderMetadata(
      createdAt: createdAt ?? this.createdAt,
      lastFiredAt: lastFiredAt ?? this.lastFiredAt,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  List<Object?> get props => [createdAt, lastFiredAt, deviceId];
}

/// Main Reminder model
class ReminderModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final ReminderCategory category;
  final ReminderPriority priority;
  final ReminderStatus status;
  final ReminderScheduling scheduling;
  final SpamConfiguration spamConfiguration;
  final ReminderMetadata metadata;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.scheduling,
    required this.spamConfiguration,
    required this.metadata,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ReminderCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      priority: ReminderPriority.fromJson(
        json['priority'] as Map<String, dynamic>,
      ),
      status: ReminderStatus.fromJson(json['status'] as Map<String, dynamic>),
      scheduling: ReminderScheduling.fromJson(
        json['scheduling'] as Map<String, dynamic>,
      ),
      spamConfiguration: SpamConfiguration.fromJson(
        json['spamConfiguration'] as Map<String, dynamic>,
      ),
      metadata: ReminderMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toJson(),
      'priority': priority.toJson(),
      'status': status.toJson(),
      'scheduling': scheduling.toJson(),
      'spamConfiguration': spamConfiguration.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderCategory? category,
    ReminderPriority? priority,
    ReminderStatus? status,
    ReminderScheduling? scheduling,
    SpamConfiguration? spamConfiguration,
    ReminderMetadata? metadata,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      scheduling: scheduling ?? this.scheduling,
      spamConfiguration: spamConfiguration ?? this.spamConfiguration,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    priority,
    status,
    scheduling,
    spamConfiguration,
    metadata,
  ];
}
