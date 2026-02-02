import 'package:get/get.dart';

import '../modules/home_view.dart';
import '../modules/introduction/bindings/introduction_binding.dart';
import '../modules/introduction/views/introduction_view.dart';
// profile removed (not used)
import '../modules/motivation/motivation_view.dart';
import '../modules/reminder_view.dart';
import '../modules/todo/todo_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => const HomeView()),
    GetPage(
      name: _Paths.INTRODUCTION,
      page: () => const IntroductionView(),
      binding: IntroductionBinding(),
    ),
    // Login removed — app is local-only now
    GetPage(name: _Paths.MOTIVATION, page: () => const MotivationView()),
    GetPage(name: _Paths.REMINDER, page: () => const ReminderView()),
    GetPage(name: _Paths.TODO, page: () => const TodoView()),
  ];
}
