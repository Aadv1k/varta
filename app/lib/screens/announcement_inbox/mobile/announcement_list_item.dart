import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementListItem extends StatelessWidget {
  final AnnouncementModel announcement;
  bool? allowEditing = false;
  VoidCallback? onPressed;
  VoidCallback? onDelete;

  AnnouncementListItem(
      {super.key,
      required this.announcement,
      this.allowEditing,
      this.onDelete,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    var announcementBody = announcement.body.replaceAll(RegExp(r'\r\n'), " ");

    return InkWell(
      onTap: onPressed,
      splashColor: Colors.transparent,
      hoverColor: PaletteNeutral.shade020,
      highlightColor: PaletteNeutral.shade040,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Spacing.md, horizontal: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${announcement.author.firstName} ${announcement.author.lastName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColor.subtitle, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  formatDate(announcement.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold, color: AppColor.subtitle),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(announcement.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColor.subheading,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.textBase)),
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
          ],
        ),
      ),
    );
  }
}
