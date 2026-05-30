import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const sageGreen = Color(0xFF6B8F6E);
  static const deepForest = Color(0xFF3A5F3E);
  static const lightSage = Color(0xFFA8C5AA);
  static const warmCream = Color(0xFFF5EDD6);
  static const softCream = Color(0xFFFAF4E8);
  static const earthBrown = Color(0xFF8B6F47);
  static const mutedBrown = Color(0xFFB8956A);

  // Pastel florals
  static const roseBlush = Color(0xFFE8A5A5);
  static const lavender = Color(0xFFB8A5D4);
  static const goldenPetal = Color(0xFFE8C97A);

  // UI colors
  static const darkGreenText = Color(0xFF2D4A2F);
  static const cardBackground = Color(0xFFF0EAD8);
  static const inputBackground = Color(0xFFF7F2E9);
  static const navBackground = Color(0xE8F0EAD8);
  static const divider = Color(0xFFDDD5C0);

  // Bubble colors
  static const aiBubble = Color(0xFFEDF5ED);
  static const userBubble = Color(0xFF4A7C4E);
  static const userBubbleText = Colors.white;
}

class AppTextStyles {
  static TextStyle display(BuildContext context) => GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.darkGreenText,
      );

  static TextStyle heading(BuildContext context) => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkGreenText,
      );

  static TextStyle subheading(BuildContext context) => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.sageGreen,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGreenText,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.earthBrown,
      );

  static TextStyle pill(BuildContext context) => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.darkGreenText,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.sageGreen,
      background: AppColors.softCream,
    ),
    scaffoldBackgroundColor: AppColors.softCream,
    useMaterial3: true,
    textTheme: GoogleFonts.nunitoTextTheme(),
  );
}
