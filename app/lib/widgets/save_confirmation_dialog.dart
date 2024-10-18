import 'package:app/common/sizes.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:flutter/material.dart';

class SaveConfirmationDialog extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const SaveConfirmationDialog({
    Key? key,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Container(
        height: 280,
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Save Announcement?",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              "Saving this edited announcement will re-notify all affected users. Proceed?",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            VartaButton(
              size: VartaButtonSize.medium,
              variant: VartaButtonVariant.primary,
              label: "Save & Re-notify",
              fullWidth: true,
              onPressed: () {
                onSave();
              },
            ),
            const SizedBox(height: Spacing.sm),
            VartaButton(
              size: VartaButtonSize.medium,
              fullWidth: true,
              onPressed: () {
                onCancel();
              },
              variant: VartaButtonVariant.secondary,
              label: "Cancel",
            ),
          ],
        ),
      ),
    );
  }
}
