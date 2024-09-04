import 'dart:typed_data';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class AppSharedStyle {
  static const double buttonHeight = 82.0;
  static const Radius buttonRadius = Radius.circular(100);
  static const double maxButtonWidth = 428.0;
  static const double buttonLoaderSize = 24;

  static const double screenHorizontalPadding = Spacing.xl;

  static const double appBarGutterSpacing = Spacing.md;

  static const double mainSliverHeight = 72;
}

class AppTextStyle {
  static const String _fontFamily = "Geist";
  static const List<String> _fallBackFont = ["Roboto", "NotoSans"];

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fallBackFont,
    fontWeight: FontWeight.w900,
    fontSize: 48,
    letterSpacing: -0.25,
    height: 0.9,
    color: AppColor.heading,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    letterSpacing: 0,
    height: 1.25,
    color: AppColor.heading,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 24,
    letterSpacing: 0,
    height: 1.29,
    color: AppColor.heading,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    letterSpacing: 0,
    height: 1.33,
    color: AppColor.heading,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 22,
    letterSpacing: 0,
    height: 1.27,
    color: AppColor.heading,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColor.heading,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColor.heading,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColor.heading,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColor.heading,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColor.heading,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColor.heading,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: FontSize.textBase,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColor.heading,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColor.heading,
  );
}

class AppTextTheme extends TextTheme {
  const AppTextTheme()
      : super(
          displayLarge: AppTextStyle.displayLarge,
          headlineLarge: AppTextStyle.headlineLarge,
          headlineMedium: AppTextStyle.headlineMedium,
          headlineSmall: AppTextStyle.headlineSmall,
          titleLarge: AppTextStyle.titleLarge,
          titleMedium: AppTextStyle.titleMedium,
          titleSmall: AppTextStyle.titleSmall,
          labelLarge: AppTextStyle.labelLarge,
          labelMedium: AppTextStyle.labelMedium,
          labelSmall: AppTextStyle.labelSmall,
          bodyLarge: AppTextStyle.bodyLarge,
          bodyMedium: AppTextStyle.bodyMedium,
          bodySmall: AppTextStyle.bodySmall,
        );
}
