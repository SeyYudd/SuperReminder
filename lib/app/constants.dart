import 'package:flutter/material.dart';

class AppConstants {
  // Spacing
  static const double padding = 16.0;
  static const double borderRadius = 12.0;

  // Colors
  static const Color background = Color(0xFFF7F7F8); // soft grey
  static const Color cardBackground = Colors.white;
  static const Color primary = Color(0xFF0A0A0A); // deep black
  static const Color success = Color(0xFF2ECC71); // vibrant green
  static const Color pending = Color(0xFF9AA0A6); // muted grey

  // Priority soft pastel colors (index 1..5 -> 0..4)
  static const List<Color> priorityColors = [
    Color(0xFFFFE5E5), // 1 - very light red
    Color(0xFFFFF3D6), // 2 - light amber
    Color(0xFFE8F6FF), // 3 - light blue
    Color(0xFFF3E8FF), // 4 - light purple
    Color(0xFFE8FFF1), // 5 - light mint
  ];

  // Typography
  static const TextStyle titleStyle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    color: primary,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF222222),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: Color(0xFF3A3A3A),
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 8.0, offset: Offset(0, 2)),
    ],
  );
}
