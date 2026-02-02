import 'package:flutter/material.dart';
import '../constants.dart';

class IntroductionView extends StatelessWidget {
  final VoidCallback? onPrimaryAction;
  final String title;
  final String subtitle;

  const IntroductionView({
    super.key,
    this.onPrimaryAction,
    this.title = 'Welcome to Super Reminder',
    this.subtitle = 'Minimal. Focused. Reliable reminders.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                title,
                style: AppConstants.titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: AppConstants.subtitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                ),
                onPressed: onPrimaryAction ?? () {},
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
