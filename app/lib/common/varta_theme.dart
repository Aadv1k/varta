import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/common/varta_text_theme.dart';
import 'package:flutter/material.dart';

class VartaTheme {
  VartaTheme();

  final ThemeData data = ThemeData(
      textTheme: const VartaTextTheme(),
      primaryColor: AppColor.primaryColor,
      scaffoldBackgroundColor: AppColor.primaryBg,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          circularTrackColor: PaletteNeutral.shade050,
          color: PaletteNeutral.shade800),
      chipTheme: ChipThemeData(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: Spacing.sm),
          backgroundColor: AppColor.activeChipBg,
          deleteIconColor: AppColor.activeChipFg,
          labelStyle: const VartaTextTheme()
              .labelMedium
              ?.copyWith(color: AppColor.activeChipFg),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          side: BorderSide.none),
      filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
              foregroundColor: const WidgetStatePropertyAll(AppColor.primaryBg),
              minimumSize: const WidgetStatePropertyAll(
                  Size.fromHeight(AppSharedStyle.buttonHeight)),
              backgroundColor:
                  const WidgetStatePropertyAll(AppColor.primaryColor),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999))))),
      appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.primaryBg, toolbarHeight: 84));
}
