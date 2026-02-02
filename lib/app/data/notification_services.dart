import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:super_reminder/main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotifiHelper {
  Future<void> initializeNotification() async {
    tzdata.initializeTimeZones();
    final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
    // Debug info to inspect the plugin return shape at runtime
    print(
      'FlutterTimezone result type: ${tzResult.runtimeType}, value: $tzResult',
    );

    String timeZoneName;
    if (tzResult is String) {
      timeZoneName = tzResult;
    } else {
      String? extracted;
      try {
        extracted = (tzResult as dynamic).name as String?;
      } catch (_) {}
      try {
        extracted ??= (tzResult as dynamic).timeZoneName as String?;
      } catch (_) {}
      if (extracted == null && tzResult is Map) {
        extracted =
            tzResult['name'] ??
            tzResult['timeZoneName'] ??
            tzResult['timezone'];
      }
      if (extracted == null) {
        final s = tzResult.toString();
        // Find a canonical timezone id like "Asia/Jakarta" from the string
        final re = RegExp(r'([A-Za-z]+\/[A-Za-z_]+(?:\/[A-Za-z_]+)?)');
        final m = re.firstMatch(s);
        extracted = m?.group(1);
      }
      // If we couldn't extract a canonical id, fall back to UTC
      timeZoneName = extracted ?? 'UTC';
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print(
        'tz.getLocation failed for "$timeZoneName": $e; falling back to UTC',
      );
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Defer navigation until app UI is mounted and navigator is available
        Future.delayed(const Duration(milliseconds: 300), () {
          try {
            MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/ReminderView',
              (route) => route.isFirst,
            );
          } catch (_) {
            // swallow any errors here to avoid crashing on startup
          }
        });
      },
    );
  }

  Future<void> displayNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'basic_channel',
          'Basic Notifications',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: createdUniqueId(),
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  // TODO: Refactor to use new TaskModel with BLoC
  // Future<void> scheduledNotification(
  //   int year,
  //   int month,
  //   int day,
  //   int hour,
  //   int minute,
  //   TaskModel task,
  // ) async {
  //   final scheduledDate = DateTime(year, month, day, hour, minute);
  //   final tz.TZDateTime scheduled = tz.TZDateTime.from(scheduledDate, tz.local);
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     id: task.id,
  //     title: task.title,
  //     body: task.description ?? '',
  //     scheduledDate: scheduled,
  //     notificationDetails: const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'basic_channel',
  //         'Basic Notifications',
  //         channelDescription: 'Reminder notifications',
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

  // TODO: Refactor to use new TaskModel with BLoC
  // Future<void> scheduledNotificationByHourMinute(
  //   int hour,
  //   int minute,
  //   TaskModel task,
  // ) async {
  //   return scheduledNotificationByTime(hour, minute, task);
  // }

  /// Request iOS/macOS permissions (no-op on Android)
  Future<void> requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedule a notification for a specific hour:minute on the current day.
  // TODO: Refactor to use new TaskModel with BLoC
  // Future<void> scheduledNotificationByTime(
  //   int hour,
  //   int minute,
  //   TaskModel task,
  // ) async {
  //   final now = DateTime.now();
  //   DateTime scheduledDate = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     hour,
  //     minute,
  //   );
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }
  //   final tz.TZDateTime scheduled = tz.TZDateTime.from(scheduledDate, tz.local);
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     id: task.id,
  //     title: task.title,
  //     body: task.description ?? '',
  //     scheduledDate: scheduled,
  //     notificationDetails: const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'basic_channel',
  //         'Basic Notifications',
  //         channelDescription: 'Reminder notifications',
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }
}

// TODO: Refactor to use new TaskModel with BLoC
// Future<void> sReminderNotifikasi(TaskModel task) async {
//   DateTime dateTime = DateFormat('d/M/yyyy').parse(task.dueDate.toString());
//   DateTime time = parseTimeString(task.startTime.toString());
//   final scheduled = DateTime(
//     dateTime.year,
//     dateTime.month,
//     dateTime.day,
//     time.hour,
//     time.minute,
//   );
//   // Ensure scheduled time is in the future (add days until it is).
//   tz.TZDateTime scheduledTz = tz.TZDateTime.from(scheduled, tz.local);
//   final nowTz = tz.TZDateTime.now(tz.local);
//   while (!scheduledTz.isAfter(nowTz)) {
//     scheduledTz = scheduledTz.add(const Duration(days: 1));
//   }
//
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     id: task.id,
//     title: task.title,
//     body: task.description ?? '',
//     scheduledDate: scheduledTz,
//     notificationDetails: const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'basic_channel',
//         'Basic Notifications',
//         channelDescription: 'Reminder notifications',
//       ),
//     ),
//     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//   );
// }

Future<void> testnotifdoang() async {
  await NotifiHelper().displayNotification(
    title: 'TEST NOTIFICATION',
    body: 'INI BAGIAN BODY NYA',
  );
}

int createdUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

class NotificationController {
  static Future<void> onActionReceivedMethod(String? payload) async {
    Fluttertoast.showToast(
      msg: "You tapped a notification",
      gravity: ToastGravity.BOTTOM,
    );
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/ReminderView',
      (route) => route.isFirst,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelSchedulesByChannelKey(String channelKey) async {
    // flutter_local_notifications does not support channel-level cancellation,
    // so cancel all scheduled notifications for simplicity.
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
