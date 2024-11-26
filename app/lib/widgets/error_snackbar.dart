import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

enum VartaSnackBarVariant { error, info, warning }

class VartaSnackbar {
  final String innerText;
  final VartaSnackBarVariant snackBarVariant;
  final bool dismissable;

  const VartaSnackbar(
      {required this.innerText,
      required this.snackBarVariant,
      this.dismissable = false});

  SnackBar build(BuildContext context) {
    Color bg;
    Color fg;
    Widget icon;

    switch (snackBarVariant) {
      case VartaSnackBarVariant.error:
        bg = TWColor.red50;
        fg = TWColor.red700;
        icon = Icon(Icons.error, color: fg, size: IconSizes.iconMd);
        break;
      case VartaSnackBarVariant.info:
        bg = TWColor.green50;
        fg = TWColor.green700;
        icon = Icon(Icons.info, color: fg, size: IconSizes.iconMd);
        break;
      case VartaSnackBarVariant.warning:
        bg = TWColor.yellow50;
        fg = TWColor.yellow700;
        icon = Icon(Icons.warning, color: fg, size: IconSizes.iconMd);
        break;
    }

    return SnackBar(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: fg)),
        elevation: 1.5,
        margin: const EdgeInsets.only(
            bottom: Spacing.lg, left: Spacing.md, right: Spacing.md),
        behavior: SnackBarBehavior.floating,
        content: SizedBox(
          child: Row(
            children: [
              icon,
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  innerText,
                  softWrap: true,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: fg),
                ),
              ),
            ],
          ),
        ));
  }

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(build(context));
  }
}
