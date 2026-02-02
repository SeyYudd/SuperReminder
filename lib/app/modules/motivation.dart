import 'package:flutter/material.dart';
import 'package:super_reminder/app/modules/motivation/motivation_view.dart';

// Lightweight wrapper kept for compatibility with existing imports.
class Motivation extends StatelessWidget {
  const Motivation({super.key});

  @override
  Widget build(BuildContext context) {
    return const MotivationView();
  }
}
