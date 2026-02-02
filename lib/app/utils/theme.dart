import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color isabelleClr = Color(0XFFf4f0ec);
const Color vividPinkClr = Color(0XFFFF2E63);
const Color cyanClr = Color(0XFF08D9D6);
const Color white = Colors.white;
const primaryClr = bataClr;
const Color darkGreyClr = Color(0XFF252A34);
const darkHeaderClr = Color(0XFF595260);
const Color bataClr = Color(0XFF202d3d);

class Themes {
  static final light = ThemeData(
      primaryColor: primaryClr,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(surface: Colors.white));

  static final dark = ThemeData(
      primaryColor: darkGreyClr,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(surface: darkGreyClr));
}

TextStyle get subHeadingStyle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey));
}

TextStyle get HeadingStyle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle get titleStyle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle get subtitleStyle {
  return GoogleFonts.poppins(
      textStyle: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey[600]));
}

TextStyle get addDateBar1 {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey));
}

TextStyle get addDateBar2 {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey));
}

TextStyle get addDateBar3 {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey));
}

TextStyle get buttonLogin {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white));
}

TextStyle get motivationStyle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle get motivationcontextStyle {
  return GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black));
}
