import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class AppStyles {
  static const double buttonHeight = 82.0;
  static const Radius buttonRadius = Radius.circular(16);
  static const double maxButtonWidth = 428.0;
  static const double buttonLoaderSize = 24;

  static const double screenHorizontalPadding = Spacing.xxl;

  static const TextStyle displayLarge = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: FontSizes.text4xl,
      color: AppColors.heading);

  static const TextStyle headlineLarge = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: FontSizes.text2xl,
      color: AppColors.heading);
  static final TextStyle headlineMedium =
      headlineLarge.copyWith(fontSize: FontSizes.textLg);
  static final TextStyle headlineSmall =
      headlineLarge.copyWith(fontSize: FontSizes.textBase);

  static const TextStyle bodyLarge =
      TextStyle(color: AppColors.body, fontSize: FontSizes.textLg);
  static const TextStyle bodyMedium =
      TextStyle(color: AppColors.body, fontSize: FontSizes.textBase);

  static const TextStyle labelMedium =
      TextStyle(color: AppColors.subtitle, fontSize: FontSizes.textSm);
}
