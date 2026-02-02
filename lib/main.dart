import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/repositories/task_repository.dart';
import 'core/repositories/reminder_repository.dart';
import 'core/utils/app_logger.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'features/reminders/bloc/reminder_bloc.dart';
import 'features/reminders/bloc/reminder_event.dart';
import 'features/tasks/screens/todo_screen.dart';
import 'features/reminders/screens/reminder_screen.dart';
import 'app/data/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize notification service
    await NotifiHelper().initializeNotification();
    AppLogger.info('Notification service initialized');
  } catch (e, stack) {
    AppLogger.error('Failed to initialize notifications', e, stack);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => TaskRepository()),
        RepositoryProvider(create: (context) => ReminderRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TaskBloc(repository: context.read<TaskRepository>())
                  ..add(LoadTasks()),
          ),
          BlocProvider(
            create: (context) =>
                ReminderBloc(context.read<ReminderRepository>())
                  ..add(LoadReminders()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Super Reminder',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF0A0A0A),
            scaffoldBackgroundColor: const Color(0xFFF7F7F8),
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Super Reminder',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your tasks efficiently',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(24),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _MenuCard(
                    title: 'Tasks',
                    icon: Icons.task_alt,
                    color: const Color(0xFF2ECC71),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TodoScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: 'Reminders',
                    icon: Icons.notifications_active,
                    color: const Color(0xFFF39C12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReminderScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuCard(
                    title: 'Calendar',
                    icon: Icons.calendar_today,
                    color: const Color(0xFF3498DB),
                    onTap: () {
                      // Navigate to calendar screen
                      AppLogger.info('Navigating to Calendar');
                    },
                  ),
                  _MenuCard(
                    title: 'Settings',
                    icon: Icons.settings,
                    color: const Color(0xFF9B59B6),
                    onTap: () {
                      // Navigate to settings screen
                      AppLogger.info('Navigating to Settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
