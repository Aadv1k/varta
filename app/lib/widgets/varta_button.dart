import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

enum VartaButtonSize { small, medium, large }

enum VartaButtonVariant { primary, secondary, error }

class VartaButton extends StatelessWidget {
  final VartaButtonSize size;
  final VartaButtonVariant variant;

  final bool isLoading;
  final bool isDisabled;
  final Icon? leadingIcon;
  final String label;
  final bool fullWidth;

  final VoidCallback? onPressed;

  const VartaButton({
    Key? key,
    this.size = VartaButtonSize.medium,
    required this.variant,
    this.fullWidth = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.leadingIcon,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool shouldDisable = isLoading || isDisabled || onPressed == null;

    Color fg, bg;
    BorderSide border;

    switch (variant) {
      case VartaButtonVariant.primary:
        bg = AppColor.primaryColor;
        fg = PaletteNeutral.shade000;
        border = BorderSide.none;
        break;
      case VartaButtonVariant.secondary:
        bg = AppColor.inactiveChipBg;
        fg = AppColor.inactiveChipFg;
        border = const BorderSide(color: PaletteNeutral.shade050, width: 1);
        break;
      case VartaButtonVariant.error:
        bg = Colors.red.shade400;
        fg = PaletteNeutral.shade000;
        border = BorderSide.none;
        break;
    }

    EdgeInsets padding;
    TextStyle textStyle;
    switch (size) {
      case VartaButtonSize.small:
        padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
        textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(color: fg);
        break;
      case VartaButtonSize.medium:
        padding = const EdgeInsets.symmetric(
            vertical: Spacing.md, horizontal: Spacing.lg);
        textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(color: fg);
        break;
      case VartaButtonSize.large:
        padding = const EdgeInsets.symmetric(
            vertical: Spacing.lg, horizontal: Spacing.lg);
        textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(color: fg);
        break;
    }

    return Opacity(
      opacity: shouldDisable ? 0.5 : 1.0,
      child: Container(
        width: fullWidth ? double.infinity : null,
        constraints: fullWidth ? const BoxConstraints(maxWidth: 420) : null,
        child: RawMaterialButton(
          onPressed: shouldDisable ? null : onPressed,
          fillColor: bg,
          textStyle: textStyle,
          padding: padding,
          splashColor: Colors.transparent,
          elevation: 0.0,
          disabledElevation: 0.0,
          focusElevation: 0.0,
          highlightElevation: 0.0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.0),
            side: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: IconSizes.iconMd,
                  height: IconSizes.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: fg,
                  ),
                )
              else ...[
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: Spacing.sm),
                ],
                Text(label),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
