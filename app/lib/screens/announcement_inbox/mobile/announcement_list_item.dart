import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';

import '../../announcement/attachment_preview_box.dart';

class AnnouncementListItem extends StatelessWidget {
  final AnnouncementModel announcement;
  final bool allowEditing;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;

  const AnnouncementListItem(
      {super.key,
      required this.announcement,
      this.allowEditing = false,
      this.onDelete,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    var announcementBody =
        announcement.body.replaceAll(RegExp(r'\r\n|\n|\t'), " ");

    return InkWell(
      onTap: onPressed,
      splashColor: Colors.transparent,
      hoverColor: PaletteNeutral.shade020,
      highlightColor: PaletteNeutral.shade020,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Spacing.md, horizontal: Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${announcement.author.firstName} ${announcement.author.lastName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.subtitle, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  formatDate(announcement.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColor.subtitle, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(announcement.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColor.heading, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(right: Spacing.lg),
              child: Text(
                announcementBody,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColor.body),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (announcement.attachments.isNotEmpty)
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                AttachmentPreviewBox(
                  attachment: AttachmentSelectionData(
                    id: announcement.attachments.first.id,
                    fileName: announcement.attachments.first.fileName,
                    fileType: announcement.attachments.first.fileType,
                  ),
                  isCompact: true,
                ),
                const SizedBox(width: Spacing.sm),
                if (announcement.attachments.length > 1)
                  Text("+${announcement.attachments.length - 1} more",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: AppColor.subtitle)),
              ]),
          ],
        ),
      ),
    );
  }
}
