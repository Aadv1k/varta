import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/delete_confirmation_dialog.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class UserAnnouncementListItem extends StatelessWidget {
  final AnnouncementModel announcement;
  VoidCallback? onPressed;
  VoidCallback? onDelete;

  UserAnnouncementListItem(
      {super.key, required this.announcement, this.onDelete, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var announcementBody = announcement.body.replaceAll(RegExp(r'\r\n'), " ");

    int scopeLength = announcement.scopes.length;
    String scopeSummary =
        "To ${announcement.scopes.sublist(0, scopeLength > 3 ? 3 : scopeLength).map((scope) => scope.toUserFriendlyLabel()).join(", ")}${scopeLength > 3 ? " and ${scopeLength - 3} more" : ""}";

    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      confirmDismiss: (direction) {
        return showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => DeleteConfirmationDialog(
                  onDelete: () {
                    Navigator.pop(context, true);
                  },
                  onCancel: () => Navigator.pop(context, false),
                ));
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
        color: Colors.red.shade400,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete_rounded,
              color: Colors.white, size: IconSizes.iconLg),
        ),
      ),
      key: UniqueKey(), //ValueKey<String>(announcement.id),
      child: InkWell(
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
                    scopeSummary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold, color: AppColor.subtitle),
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
      ),
    );
  }
}
