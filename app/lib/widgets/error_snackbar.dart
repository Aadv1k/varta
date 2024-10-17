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
      backgroundColor: const Color(0xFFfeeeec),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade400),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: IconSizes.iconMd),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              innerText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.black),
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
