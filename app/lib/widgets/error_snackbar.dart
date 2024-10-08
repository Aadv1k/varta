import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class ErrorSnackbar extends StatelessWidget {
  final String innerText;
  final VoidCallback? action;
  final String? actionLabel;

  const ErrorSnackbar({
    Key? key,
    required this.innerText,
    this.action,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      backgroundColor: TWColor.red100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        side: BorderSide(color: TWColor.red500),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.lg,
      ),
      behavior: SnackBarBehavior.floating,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              innerText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColor.heading),
            ),
          ),
          if (action != null && actionLabel != null)
            TextButton(
              onPressed: action,
              child: Text(actionLabel!,
                  style: const TextStyle(color: TWColor.red500)),
            ),
        ],
      ),
    );
  }
}
