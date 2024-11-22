import 'package:app/common/sizes.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:flutter/material.dart';

enum GenericConfirmatonDialogAction { confirm, cancel }

class GenericConfirmationDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final String? cancelLabel;
  final String? confirmLabel;

  final String title;
  final String body;

  final bool danger;

  final GenericConfirmatonDialogAction primaryAction;

  const GenericConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
    required this.title,
    required this.body,
    this.cancelLabel,
    this.confirmLabel,
    required this.primaryAction,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Container(
        height: 320,
        constraints: const BoxConstraints(maxWidth: 460, minWidth: 280),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            if (onCancel != null)
              VartaButton(
                  size: VartaButtonSize.medium,
                  variant:
                      primaryAction == GenericConfirmatonDialogAction.cancel
                          ? VartaButtonVariant.primary
                          : VartaButtonVariant.secondary,
                  label: cancelLabel!,
                  fullWidth: true,
                  onPressed: onCancel),
            const SizedBox(height: Spacing.sm),
            if (onConfirm != null)
              VartaButton(
                size: VartaButtonSize.medium,
                variant: primaryAction == GenericConfirmatonDialogAction.confirm
                    ? (danger
                        ? VartaButtonVariant.error
                        : VartaButtonVariant.primary)
                    : VartaButtonVariant.secondary,
                fullWidth: true,
                onPressed: onConfirm,
                label: confirmLabel!,
              ),
          ],
        ),
      ),
    );
  }
}
