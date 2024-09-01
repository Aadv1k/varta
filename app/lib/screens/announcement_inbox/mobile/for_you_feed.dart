import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
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

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today, \${DateFormat.jm().format(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday, \${DateFormat.jm().format(date)}';
    } else if (date.isAfter(startOfWeek) && date.isBefore(endOfWeek)) {
      return '${DateFormat.EEEE().format(date)}, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Spacing.md, horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${announcement.author.firstName} ${announcement.author.lastName}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColor.subtitle),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.heading, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(right: Spacing.lg),
            child: Text(
              announcement.body,
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
    );
  }
}
