import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../constants.dart';
import '../models/task_model.dart';

class DemoSpamScreen extends StatefulWidget {
  const DemoSpamScreen({super.key});

  @override
  _DemoSpamScreenState createState() => _DemoSpamScreenState();
}

class _DemoSpamScreenState extends State<DemoSpamScreen> {
  late FlutterLocalNotificationsPlugin _plugin;
  late SpamLogicService _spamService;
  late Task _demoTask;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();

    _demoTask = Task(
      id: 'demo-task-1',
      title: 'Demo: Complete your challenge',
      description:
          'This is a repeated spam-style reminder until challenge done.',
      priority: 2,
      schedule: Schedule(
        targetTime: DateTime.now().add(const Duration(seconds: 15)),
      ),
      spam: SpamSettings(isEnabled: true, intervalSeconds: 10, maxRetries: 5),
      challenge: Challenge(
        type: ChallengeType.math,
        difficulty: 1,
        isLocked: true,
      ),
      subTasks: [
        SubTask(title: 'Step 1'),
        SubTask(title: 'Step 2'),
      ],
    );
  }

  Future<void> _initNotifications() async {
    tzdata.initializeTimeZones();
    _plugin = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings: initSettings);
    _spamService = SpamLogicService(_plugin);
  }

  Future<void> _schedule() async {
    await _spamService.scheduleSpam(_demoTask);
    setState(() => _scheduled = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scheduled demo spam notifications')),
    );
  }

  Future<void> _cancel() async {
    await _spamService.cancelSpam(_demoTask);
    setState(() => _scheduled = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Canceled demo spam notifications')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spam Logic Demo'),
        backgroundColor: AppConstants.primary,
      ),
      backgroundColor: AppConstants.background,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demo Task', style: AppConstants.titleStyle),
            const SizedBox(height: 8),
            Text(_demoTask.title, style: AppConstants.subtitleStyle),
            const SizedBox(height: 12),
            Text(
              'Scheduled at: ${_demoTask.schedule.targetTime} ',
              style: AppConstants.bodyStyle,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _scheduled ? null : _schedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primary,
                  ),
                  child: const Text('Schedule Spam'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _scheduled ? _cancel : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.pending,
                  ),
                  child: const Text('Cancel Spam'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Task Subtasks (complete to stop reminders):',
              style: AppConstants.subtitleStyle,
            ),
            const SizedBox(height: 8),
            ...List.generate(_demoTask.subTasks.length, (i) {
              final sub = _demoTask.subTasks[i];
              return Row(
                children: [
                  Checkbox(
                    value: sub.isDone,
                    onChanged: (v) {
                      setState(() {
                        sub.isDone = v ?? false;
                        // If all done, cancel spam automatically
                        if (_demoTask.isDone) {
                          _spamService.cancelSpam(_demoTask);
                          _scheduled = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'All subtasks done — spam canceled',
                              ),
                            ),
                          );
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: Text(sub.title, style: AppConstants.bodyStyle),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
