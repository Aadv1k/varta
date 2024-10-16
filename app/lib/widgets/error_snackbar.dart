import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class ErrorSnackbar {
  final String innerText;
  final VoidCallback? action;
  final String? actionLabel;

  const ErrorSnackbar({
    required this.innerText,
    this.action,
    this.actionLabel,
  });

  SnackBar build(BuildContext context) {
    return SnackBar(
      backgroundColor: TWColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: TWColor.red600),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      behavior: SnackBarBehavior.floating,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.error,
              color: TWColor.red600, size: IconSizes.iconMd),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              innerText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: TWColor.red600),
            ),
          ),
          if (action != null && actionLabel != null)
            TextButton(
              onPressed: action,
              child: Text(
                actionLabel!,
                style: const TextStyle(color: TWColor.red500),
              ),
            ),
        ],
      ),
    );
  }

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(build(context));
  }
}
