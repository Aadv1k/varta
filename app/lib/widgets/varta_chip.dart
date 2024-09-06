import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

enum VartaChipVariant { primary, secondary }

enum VartaChipSize { small, medium }

class VartaChip extends StatelessWidget {
  final String text;
  final VartaChipVariant variant;
  final VartaChipSize size;
  VoidCallback? onDeleted;
  VoidCallback? onPressed;
  final bool showCaret;

  VartaChip({
    super.key,
    required this.variant,
    this.onDeleted,
    this.onPressed,
    required this.text,
    this.showCaret = false,
    this.size = VartaChipSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final bg = variant == VartaChipVariant.primary
        ? AppColor.activeChipBg
        : AppColor.inactiveChipBg;
    final fg = variant == VartaChipVariant.primary
        ? AppColor.activeChipFg
        : AppColor.inactiveChipFg;

    EdgeInsetsGeometry padding;
    double spacing;
    double height;

    switch (size) {
      case VartaChipSize.small:
        padding = const EdgeInsets.symmetric(
            horizontal: Spacing.xs, vertical: Spacing.xs);
        spacing = Spacing.xs;
        height = 36.0;
        break;
      case VartaChipSize.medium:
      default:
        padding = const EdgeInsets.symmetric(
            horizontal: Spacing.sm, vertical: Spacing.xs);
        spacing = Spacing.sm;
        height = 36.0;
        break;
    }

    return RawChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      padding: padding,
      onPressed: onPressed,
      backgroundColor: bg,
      onDeleted: onDeleted,
      deleteIcon: Icon(Icons.close, color: fg, size: IconSizes.iconMd),
      label: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style:
                  Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
            ),
            if (showCaret) ...[
              SizedBox(width: spacing),
              Icon(Icons.arrow_drop_down_rounded,
                  color: fg, size: IconSizes.iconMd),
            ],
          ],
        ),
      ),
    );
  }
}
