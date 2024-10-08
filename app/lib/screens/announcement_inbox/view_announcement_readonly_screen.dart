import 'package:app/common/sizes.dart';
import 'package:app/common/colors.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';

class ViewAnnouncementReadonlyScreen extends StatefulWidget {
  final AnnouncementModel announcement;

  const ViewAnnouncementReadonlyScreen({super.key, required this.announcement});

  @override
  State<ViewAnnouncementReadonlyScreen> createState() =>
      _ViewAnnouncementReadonlyScreenState();
}

class _ViewAnnouncementReadonlyScreenState
    extends State<ViewAnnouncementReadonlyScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.primaryBg,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColor.primaryBg,
          toolbarHeight: 48,
          titleSpacing: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: Spacing.sm),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close,
                    color: AppColor.body, size: IconSizes.iconMd)),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.only(
                left: Spacing.md,
                right: Spacing.md,
                top: Spacing.sm,
                bottom: Spacing.md),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(widget.announcement.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(color: AppColor.heading)),
                  const SizedBox(height: Spacing.md),
                  const Divider(height: 1, color: AppColor.subtitleLighter),
                  const SizedBox(height: Spacing.md),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Wrap(
                          runSpacing: Spacing.sm,
                          spacing: Spacing.sm,
                          children: widget.announcement.scopes
                              .asMap()
                              .entries
                              .map((entry) {
                            return const VartaChip(
                                variant: VartaChipVariant.secondary,
                                text:
                                    "Todo", //scopeData.getUserFriendlyLabel(),
                                size: VartaChipSize.small);
                          }).toList(),
                        ),
                        if (widget.announcement.scopes.isNotEmpty)
                          const SizedBox(height: Spacing.sm),
                      ]),
                  const SizedBox(height: Spacing.md),
                  const Divider(height: 1, color: AppColor.subtitleLighter),
                  const SizedBox(height: Spacing.sm),
                  Expanded(
                      child: Text(
                    widget.announcement.body,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColor.body),
                    maxLines: 999,
                  )),
                ])));
  }
}
