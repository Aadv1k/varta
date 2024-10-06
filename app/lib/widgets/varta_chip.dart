import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

enum VartaChipVariant { primary, secondary, outlined }

enum VartaChipSize { small, medium }

class VartaChip extends StatelessWidget {
  final String text;
  final VartaChipVariant variant;
  final VartaChipSize size;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;

  const VartaChip({
    Key? key,
    required this.text,
    this.variant = VartaChipVariant.primary,
    this.size = VartaChipSize.medium,
    this.onPressed,
    this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg;
    final fg;
    final border;

    switch (variant) {
      case VartaChipVariant.primary:
        bg = AppColor.activeChipBg;
        fg = AppColor.activeChipFg;
        border = BorderSide.none;
        break;
      case VartaChipVariant.secondary:
        bg = AppColor.inactiveChipBg;
        fg = AppColor.inactiveChipFg;
        border = BorderSide.none;
        break;
      case VartaChipVariant.outlined:
        bg = Colors.transparent;
        fg = AppColor.primaryColor;
        border = const BorderSide(color: AppColor.primaryColor, width: 1);
        break;
    }

    EdgeInsetsGeometry padding;
    double height;

    switch (size) {
      case VartaChipSize.small:
        padding = const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.xs,
        );
        height = 28.0;
        break;
      case VartaChipSize.medium:
      default:
        padding = const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        );
        height = 32.0;
        break;
    }

    return Opacity(
      opacity: onPressed == null && onDeleted == null ? 0.6 : 1.0,
      child: RawChip(
        side: border,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
