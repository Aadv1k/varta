import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/screens/announcement_inbox/mobile/tab_selector_chip.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';

class CreateAnnouncementScreen extends StatelessWidget {
  const CreateAnnouncementScreen({super.key});

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
                        VartaChip(
                            variant: VartaChipVariant.primary,
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  isDismissible: false,
                                  enableDrag: false,
                                  builder: (context) =>
                                      const ScopeSelectionBottomSheet());
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

class ScopeSelectionBottomSheet extends StatefulWidget {
  const ScopeSelectionBottomSheet({Key? key}) : super(key: key);

  @override
  _ScopeSelectionBottomSheetState createState() =>
      _ScopeSelectionBottomSheetState();
}

enum ScopeType { student, teacher }

class _ScopeSelectionBottomSheetState extends State<ScopeSelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.80,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Select an Audience",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton.filled(
                  color: PaletteNeutral.shade900,
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(PaletteNeutral.shade040),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: IconSizes.iconMd))
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            "Quick Select",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColor.subtitle),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              VartaChip(
                  variant: VartaChipVariant.secondary, text: "All Students"),
              VartaChip(
                  variant: VartaChipVariant.secondary, text: "All Teachers"),
              VartaChip(
                  variant: VartaChipVariant.secondary,
                  text: "All Subject Teachers"),
              VartaChip(variant: VartaChipVariant.secondary, text: "Everyone"),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            "Custom",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColor.subtitle),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton(
                onSelectionChanged: (p0) => print(p0),
                style: const ButtonStyle(),
                segments: const [
                  ButtonSegment(
                      value: ScopeType.student, label: Text("Student")),
                  ButtonSegment(
                      value: ScopeType.teacher, label: Text("Teacher")),
                ],
                selected: const {
                  ScopeType.teacher
                }),
          ),
          const SizedBox(height: Spacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("is Class Teacher",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColor.heading)),
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                  value: true,
                  onChanged: (i) {
                    print("ayo");
                  }),
            )
          ]),
          const SizedBox(height: Spacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("is Subject Teacher",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColor.heading)),
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                  value: true,
                  onChanged: (i) {
                    print("ayo");
                  }),
            )
          ]),
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text("of",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: AppColor.subtitle)),
              ),
              Expanded(
                flex: 2,
                child: DropdownButton(
                    items: const <DropdownMenuItem<Text>>[
                      DropdownMenuItem(child: Text("Standard Division")),
                    ],
                    onChanged: (ayo) {
                      print("ayo");
                    }),
              ),
            ],
          ),
          const Spacer(),
          const Center(
            child: PrimaryButton(
              text: "Add Audience",
              isDisabled: true,
            ),
          )
        ]));
  }
}
