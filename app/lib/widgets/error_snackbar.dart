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
        bg = TWColor.red100;
        fg = TWColor.red700;
        icon = Icon(Icons.error, color: fg, size: IconSizes.iconMd);
        break;
      case VartaSnackBarVariant.info:
        bg = TWColor.green100;
        fg = TWColor.green700;
        icon = Icon(Icons.info, color: fg, size: IconSizes.iconMd);
        break;
      case VartaSnackBarVariant.warning:
        bg = TWColor.yellow100;
        fg = TWColor.yellow700;
        icon = Icon(Icons.warning, color: fg, size: IconSizes.iconMd);
        break;
    }

    return SnackBar(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: fg)),
        elevation: 2.5,
        margin: const EdgeInsets.only(
            bottom: Spacing.lg, left: Spacing.md, right: Spacing.md),
        behavior: SnackBarBehavior.floating,
        content: SizedBox(
          height: 36,
          child: Row(
            children: [
              icon,
              const SizedBox(width: Spacing.sm),
              Text(
                innerText,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: fg, fontWeight: FontWeight.w500),
              ),
              // const Spacer(),
              // IconButton(
              //   enableFeedback: false,
              //   style: IconButton.styleFrom(
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   padding: EdgeInsets.zero,
              //   icon: const Icon(Icons.close,
              //       color: AppColor.body, size: IconSizes.iconMd),
              //   onPressed: () {
              //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //   },
              // ),
            ],
          ),
        ));
  }

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(build(context));
  }
}
