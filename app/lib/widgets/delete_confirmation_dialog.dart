import 'package:app/common/sizes.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const DeleteConfirmationDialog({
    Key? key,
    required this.onDelete,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 320,
        constraints: const BoxConstraints(maxWidth: 460, minWidth: 280),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delete Announcement?",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              "This action cannot be undone. It may take some time for the announcement to be fully removed.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            VartaButton(
              size: VartaButtonSize.medium,
              variant: VartaButtonVariant.error,
              label: "Delete",
              fullWidth: true,
              onPressed: () {
                onDelete();
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
