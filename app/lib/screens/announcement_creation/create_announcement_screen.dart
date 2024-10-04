import 'package:app/common/sizes.dart';
import 'package:app/common/colors.dart';
import 'package:app/models/search_data.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/announcement_creation/scope_selection_bottom_sheet.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  List<ScopeSelectionData> selectedScopes = [];

  void _handleCreateScope(ScopeSelectionData data) {
    setState(() {
      selectedScopes.add(data);
    });
  }

  void _handleDeleteScope(int index) {
    setState(() {
      selectedScopes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
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
            padding: const EdgeInsets.only(
                left: Spacing.lg,
                right: Spacing.lg,
                top: Spacing.md,
                bottom: Spacing.md),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                      minLines: 1,
                      maxLines: 4,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(color: AppColor.heading),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Announcement Title",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                                color: AppColor.subtitle,
                                fontWeight: FontWeight.normal),
                      )),
                  const SizedBox(height: Spacing.lg),
                  const Divider(height: 1, color: AppColor.subtitleLighter),
                  const SizedBox(height: Spacing.md),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Wrap(
                          children: selectedScopes.asMap().entries.map((entry) {
                            int index = entry.key;
                            var scopeData = entry.value;

                            return VartaChip(
                              variant: VartaChipVariant.secondary,
                              text: scopeData.getUserFriendlyLabel(),
                              onDeleted: () => _handleDeleteScope(index),
                            );
                          }).toList(),
                        ),
                        VartaChip(
                            variant: VartaChipVariant.primary,
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: false,
                                  backgroundColor: Colors.white,
                                  enableDrag: false,
                                  builder: (context) =>
                                      ScopeSelectionBottomSheet(
                                          onCreated: (scope) =>
                                              _handleCreateScope(scope)));
                            },
                            text: "Add Scope",
                            size: VartaChipSize.medium)
                      ]),
                  const SizedBox(height: Spacing.md),
                  const Divider(height: 1, color: AppColor.subtitleLighter),
                  const SizedBox(height: Spacing.md),
                  Expanded(
                    child: TextField(
                        maxLength: 3000,
                        maxLines: 999,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText:
                                "eg \"This is an announcement regarding...\"",
                            hintStyle:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: AppColor.subtitle,
                                    )),
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: AppColor.body,
                            )),
                  ),
                ])));
  }
}
