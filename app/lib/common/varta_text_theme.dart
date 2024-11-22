import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

// NOTE: Geist; Weight 400, 500 and 900
class _Typography {
  static const String _fontFamily = "Geist";
  static const List<String> _fallBackFont = [
    "Apple Color Emoji",
    "NotoColorEmoji"
  ];
  // DISPLAY: meant to be used for VERY large short headings. Not meant to be very legible
  static const TextStyle displayLarge = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w900,
      fontSize: FontSize.text4xl,
      height: 1.2);
  static const TextStyle displayMedium = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w900,
      fontSize: FontSize.text2xl,
      height: 1.2);
  static const TextStyle displaySmall = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w900,
      fontSize: FontSize.textXl,
      height: 1.2);

  // TITLE: used for semantic titles (appbars, card titles etc)
  static const TextStyle titleLarge = TextStyle(
      color: AppColor.subheading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textXl,
      height: 1.3);
  static const TextStyle titleMedium = TextStyle(
      color: AppColor.subheading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textLg,
      height: 1.3);
  static const TextStyle titleSmall = TextStyle(
      color: AppColor.subheading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textBase,
      height: 1.3);

  // HEADLINE: used for large fonts that aren't semantically titles
  static const TextStyle headlineLarge = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.bold,
      fontSize: FontSize.text2xl,
      height: 1.3);
  static const TextStyle headlineMedium = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.bold,
      fontSize: FontSize.textXl,
      height: 1.3);
  static const TextStyle headlineSmall = TextStyle(
      color: AppColor.heading,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.bold,
      fontSize: FontSize.textLg,
      height: 1.3);

  // BODY
  static const TextStyle bodyLarge = TextStyle(
      color: AppColor.body,
      fontFamily: _fontFamily,
      fontWeight: FontWeight.normal,
      fontFamilyFallback: _fallBackFont,
      fontSize: FontSize.textLg,
      height: 1.5);
  static const TextStyle bodyMedium = TextStyle(
      color: AppColor.body,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.normal,
      fontSize: FontSize.textBase,
      height: 1.5);
  static const TextStyle bodySmall = TextStyle(
      fontFamily: _fontFamily,
      color: AppColor.body,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.normal,
      fontSize: FontSize.textSm,
      height: 1.5);

  // Label
  static const TextStyle labelLarge = TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textBase,
      height: 1.4);
  static const TextStyle labelMedium = TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
      fontWeight: FontWeight.w500,
      fontSize: FontSize.textSm,
      height: 1.4);
  static const TextStyle labelSmall = TextStyle(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fallBackFont,
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
