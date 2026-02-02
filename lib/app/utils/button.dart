import 'package:flutter/material.dart';
import 'package:super_reminder/app/utils/theme.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;

  const MyButton({ super.key, required this.label, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 60,
        padding: const EdgeInsets.only(top: 20,left: 25, bottom: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: primaryClr,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}