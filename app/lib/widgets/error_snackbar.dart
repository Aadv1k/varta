import 'package:app/common/colors.dart';
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
        backgroundColor: PaletteNeutral.shade600,
        elevation: 5,
        behavior: SnackBarBehavior.floating,
        content: Text(
          innerText,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: PaletteNeutral.shade020, fontWeight: FontWeight.w500),
        ));
  }

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(build(context));
  }
}
