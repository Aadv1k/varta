import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/announcement_inbox/mobile/tab_selector_chip.dart';
import 'package:flutter/material.dart';

class CreateAnnouncementScreen extends StatelessWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const IconButton(
              onPressed: null,
              icon: Icon(Icons.chevron_left,
                  color: AppColor.heading, size: IconSizes.iconMd)),
          actions: [
            TextButton(
                onPressed: () {},
                child: const Text("Create",
                    style: TextStyle(
                        fontSize: FontSize.textBase,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)))
          ],
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg, vertical: Spacing.md),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const TextField(
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(
                        fontFamily: "Geist",
                        color: AppColor.heading,
                        fontSize: FontSize.textLg,
                        height: 1.2,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Announcement Title",
                        hintStyle: TextStyle(
                            fontFamily: "Geist",
                            color: AppColor.subtitle,
                            fontSize: FontSize.textLg,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: Spacing.sm),
                  const Divider(height: 1, color: AppColor.subtitleLighter),
                  const SizedBox(height: Spacing.md),

                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ActionChip(
                          label: const Text("Add Scope"),
                          avatar: const Icon(Icons.add,
                              size: IconSizes.iconMd,
                              color: AppColor.primaryBg),
                          onPressed: () {},
                        ),
                      ]),

                  const SizedBox(height: Spacing.md),
                  const Divider(height: 1, color: AppColor.subtitleLighter),
                  const SizedBox(height: Spacing.sm),

                  // ScopeList
                  // CreateScopeButton

                  // divider

                  // text area
                ])));
  }
}
