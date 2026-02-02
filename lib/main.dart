import 'package:super_reminder/app/data/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:super_reminder/app/controllers/auth_controller.dart';
import 'package:super_reminder/app/controllers/db_controller.dart';

import 'package:super_reminder/app/modules/splash_screen.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize local notifications
  await NotifiHelper().initializeNotification();

  await DBHelper.initDB();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final authC = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 2)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Obx(
            () => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Super Reminder",
              initialRoute: authC.isSkipIntro.isTrue
                  ? Routes.HOME
                  : Routes.INTRODUCTION,
              getPages: AppPages.routes,
            ),
          );
        }
        return FutureBuilder(
          future: authC.firstInitialize(),
          builder: (context, snapshot) => const SplashPage(),
        );
      },
    );
  }
}

// Firebase messaging removed. Local notifications via AwesomeNotifications are used.
