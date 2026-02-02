import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:super_reminder/app/routes/app_pages.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  Future<void> firstInitialize() async {
    final box = GetStorage();
    isAuth.value = box.read('isAuth') == true;
    isSkipIntro.value = box.read('skipIntro') == true;
  }

  Future<bool> skipIntro() async {
    final box = GetStorage();
    return box.read('skipIntro') == true;
  }

  Future<bool> autoLogin() async {
    final box = GetStorage();
    return box.read('isAuth') == true;
  }
}
