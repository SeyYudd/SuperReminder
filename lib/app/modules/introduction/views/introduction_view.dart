import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:super_reminder/app/routes/app_pages.dart';

import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  const IntroductionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Important Never Forget",
            body:
                "One day You will look back and see that all along You were Blooming",
            image: SizedBox(
              width: Get.width * 0.7,
              height: Get.height * 0.7,
              child: Center(
                child: Lottie.asset('assets/lottie/astronaut-light-theme.json'),
              ),
            ),
          ),
          PageViewModel(
            title: "Great Things Never Came from Comfort Zones",
            body:
                "Don't be Afraid of being Different, be Afraid of being the same as Everyone else",
            image: SizedBox(
              width: Get.width * 0.7,
              height: Get.height * 0.7,
              child: Center(
                child: Lottie.asset('assets/lottie/login-pt-2.json'),
              ),
            ),
          ),
          PageViewModel(
            title: "Strive for progress, not perfection",
            body: "You're doing the best you can. Things will get better soon",
            image: SizedBox(
              width: Get.width * 0.7,
              height: Get.height * 0.7,
              child: Center(child: Lottie.asset("assets/lottie/login.json")),
            ),
          ),
        ],
        onDone: () => Get.offAllNamed(Routes.HOME),
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Text("Next"),
        done: Container(
          height: 30,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Colors.black,
          color: const Color(0XFFE7D2CC),
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
