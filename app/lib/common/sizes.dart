// ignore: constant_identifier_names
import 'package:app/common/colors.dart';
import 'package:flutter/material.dart';

const REM = 16.0;

class FontSize {
  static const double text5xl = 61;
  static const double text4xl = 49;
  static const double text3xl = 39;
  static const double text2xl = 31;
  static const double textXl = 25;
  static const double textLg = 20;
  static const double textBase = 16;
  static const double textSm = 13;
  static const double textXs = 10;
}

// NOTE: Geist; Weight 400, 500 and 900
class _Typography {
  static const String _fontFamily = "Geist";
  // DISPLAY: meant to be used for VERY large short headings. Not meant to be very legible
  static const TextStyle displayLarge = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      fontSize: FontSize.text4xl,
      height: 1.2);
  static const TextStyle displayMedium = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      fontSize: FontSize.text2xl,
      height: 1.2);
  static const TextStyle displaySmall = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      fontSize: FontSize.textXl,
      height: 1.2);

  // TITLE: used for semantic titles (appbars, card titles etc)
  static const TextStyle titleLarge = TextStyle(
      color: AppColor.subheading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textXl,
      height: 1.3);
  static const TextStyle titleMedium = TextStyle(
      color: AppColor.subheading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textLg,
      height: 1.3);
  static const TextStyle titleSmall = TextStyle(
      color: AppColor.subheading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textBase,
      height: 1.3);

  // HEADLINE: used for large fonts that aren't semantically titles
  static const TextStyle headlineLarge = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize.text2xl,
      height: 1.3);
  static const TextStyle headlineMedium = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize.textXl,
      height: 1.3);
  static const TextStyle headlineSmall = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: FontSize.textLg,
      height: 1.3);

  // BODY
  static const TextStyle bodyLarge = TextStyle(
      color: AppColor.body,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.normal,
      fontSize: FontSize.textLg,
      height: 1.5);
  static const TextStyle bodyMedium = TextStyle(
      color: AppColor.body,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.normal,
      fontSize: FontSize.textBase,
      height: 1.5);
  static const TextStyle bodySmall = TextStyle(
      fontFamily: _fontFamily,
      color: AppColor.body,
      fontWeight: FontWeight.normal,
      fontSize: FontSize.textSm,
      height: 1.5);

  // Label
  static const TextStyle labelLarge = TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textBase,
      height: 1.4);
  static const TextStyle labelMedium = TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textSm,
      height: 1.4);
  static const TextStyle labelSmall = TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textXs,
      height: 1.4);
}

class VartaTextTheme extends TextTheme {
  const VartaTextTheme()
      : super(
          displayLarge: _Typography.displayLarge,
          headlineLarge: _Typography.headlineLarge,
          headlineMedium: _Typography.headlineMedium,
          headlineSmall: _Typography.headlineSmall,
          titleLarge: _Typography.titleLarge,
          titleMedium: _Typography.titleMedium,
          titleSmall: _Typography.titleSmall,
          labelLarge: _Typography.labelLarge,
          labelMedium: _Typography.labelMedium,
          labelSmall: _Typography.labelSmall,
          bodyLarge: _Typography.bodyLarge,
          bodyMedium: _Typography.bodyMedium,
          bodySmall: _Typography.bodySmall,
        );
}

class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class IconSizes {
  static const double iconXs = 0.75 * REM;
  static const double iconSm = 1 * REM;
  static const double iconMd = 1.5 * REM;
  static const double iconLg = 2 * REM;
  static const double iconXl = 2.5 * REM;
  static const double iconXxl = 3 * REM;
  static const double iconXxxl = 4 * REM;
}
