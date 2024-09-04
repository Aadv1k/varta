import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class TabViewSelectorChip extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const TabViewSelectorChip({
    Key? key,
    required this.text,
    this.isActive = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(style: BorderStyle.none)),
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isActive ? AppColor.activeChipFg : AppColor.inactiveChipFg),
      ),
      backgroundColor:
          isActive ? AppColor.activeChipBg : AppColor.inactiveChipBg,
      onPressed: onPressed,
    );
  }
}
