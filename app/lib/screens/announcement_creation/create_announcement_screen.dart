import 'dart:io';

import 'package:app/common/sizes.dart';
import 'package:app/common/colors.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/delete_confirmation_dialog.dart';
import 'package:app/widgets/save_confirmation_dialog.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/announcement_creation/scope_selection_bottom_sheet.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final Function(AnnouncementCreationData) onCreate;
  final Function(AnnouncementCreationData)? onSave;
  final Function()? onDelete;
  final AnnouncementModel? initialAnnouncement;
  final bool isUpdate;

  const CreateAnnouncementScreen({
    super.key,
    required this.onCreate,
    this.onSave,
    this.onDelete,
    this.initialAnnouncement,
    this.isUpdate = false,
  });

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late AnnouncementCreationData _announcementData;
  bool shouldDisableAdd = false;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the state based on whether it's update mode or create mode
    if (widget.isUpdate && widget.initialAnnouncement != null) {
      _announcementData =
          AnnouncementCreationData.fromModel(widget.initialAnnouncement!);
      _titleController.text = _announcementData.title;
      _bodyController.text = _announcementData.body;
    } else {
      _announcementData = AnnouncementCreationData(
          scopes: [], title: "", body: "", attachments: []);
    }

    _titleController.addListener(() {
      setState(() {
        _announcementData =
            _announcementData.copyWith(title: _titleController.text);
      });
    });

    _bodyController.addListener(() {
      setState(() {
        _announcementData =
            _announcementData.copyWith(body: _bodyController.text);
      });
    });
  }

  void _handleCreateScope(ScopeSelectionData data) {
    setState(() {
      if (!_announcementData.scopes.contains(data)) {
        _announcementData = _announcementData.copyWith(
          scopes: [..._announcementData.scopes, data],
        );
      }
      if (data.scopeType == ScopeContext.everyone ||
          data.scopeFilterType == GenericFilterType.all) {
        shouldDisableAdd = true;
      }
    });
  }

  void _handleDeleteScope(int index) {
    setState(() {
      ScopeSelectionData deletedScope = _announcementData.scopes[index];
      _announcementData = _announcementData.copyWith(
        scopes: [..._announcementData.scopes]..removeAt(index),
      );
      if (deletedScope.scopeType == ScopeContext.everyone ||
          deletedScope.scopeFilterType == GenericFilterType.all) {
        shouldDisableAdd = false;
      }
    });
  }

  void _handleCreateAnnouncement() {
    widget.onCreate(_announcementData);
    Navigator.pop(context);
  }

  void _handleSaveAnnouncement() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SaveConfirmationDialog(
              onSave: () {
                Navigator.pop(context);
                if (widget.onSave != null) widget.onSave!(_announcementData);
              },
              onCancel: () => Navigator.pop(context),
            ));
  }

  void _handleDeleteAnnouncement() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DeleteConfirmationDialog(
              onDelete: () {
                Navigator.pop(context);
                if (widget.onDelete != null) widget.onDelete!();
              },
              onCancel: () => Navigator.pop(context),
            ));
  }

  void _handleAddAttachment(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryBg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.primaryBg,
        toolbarHeight: 54,
        titleSpacing: 0,
        leading: Padding(
          padding: EdgeInsets.zero,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left,
                color: AppColor.subtitle, size: IconSizes.iconMd),
          ),
        ),
        actions: [
          SizedBox(
            child: IconButton(
                style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: () => _handleAddAttachment(context),
                icon: const Icon(Icons.attachment,
                    color: AppColor.subtitle, size: IconSizes.iconMd)),
          ),
          if (widget.isUpdate == false) ...[
            IconButton(
                style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: _handleDeleteAnnouncement,
                icon: const Icon(Icons.delete,
                    color: AppColor.subtitle, size: IconSizes.iconMd)),
            const SizedBox(width: Spacing.xs),
          ],
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: VartaButton(
              onPressed: _announcementData.isValid()
                  ? (widget.isUpdate
                      ? _handleSaveAnnouncement
                      : _handleCreateAnnouncement)
                  : null,
              label: widget.isUpdate ? "Save" : "Create",
              variant: VartaButtonVariant.primary,
              size: VartaButtonSize.small,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              minLines: 1,
              maxLines: null,
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: AppColor.heading, overflow: TextOverflow.ellipsis),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Announcement Title",
                hintStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: AppColor.subtitle, fontWeight: FontWeight.normal),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            const Divider(height: 1, color: AppColor.subtitleLighter),
            const SizedBox(height: Spacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Wrap(
                  runSpacing: Spacing.sm,
                  spacing: Spacing.sm,
                  children:
                      _announcementData.scopes.asMap().entries.map((entry) {
                    int index = entry.key;
                    var scopeData = entry.value;
                    return VartaChip(
                      variant: VartaChipVariant.secondary,
                      text: scopeData.getUserFriendlyLabel(),
                      onDeleted: () => _handleDeleteScope(index),
                      size: VartaChipSize.small,
                    );
                  }).toList(),
                ),
                if (_announcementData.scopes.isNotEmpty)
                  const SizedBox(height: Spacing.sm),
                VartaChip(
                  variant: VartaChipVariant.outlined,
                  isDisabled: shouldDisableAdd,
                  onPressed: shouldDisableAdd
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            isDismissible: false,
                            backgroundColor: AppColor.primaryBg,
                            enableDrag: false,
                            builder: (context) => ScopeSelectionBottomSheet(
                              onCreated: (scope) => _handleCreateScope(scope),
                            ),
                          );
                        },
                  text: "Add Scope",
                  size: VartaChipSize.small,
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            const Divider(height: 1, color: AppColor.subtitleLighter),
            const SizedBox(height: Spacing.sm),
            Expanded(
              child: TextField(
                maxLines: null,
                controller: _bodyController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: 'eg "This is an announcement regarding..."',
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColor.subtitle,
                      ),
                ),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColor.heading,
                    ),
              ),
            ),
            const Spacer(),
            const Wrap(runSpacing: Spacing.sm, spacing: Spacing.sm, children: [
              AttachmentPreviewBoxWidget(),
              AttachmentPreviewBoxWidget(),
              AttachmentPreviewBoxWidget(),
              AttachmentPreviewBoxWidget(),
            ])
          ],
        ),
      ),
    );
  }
}

class AttachmentPreviewBoxWidget extends StatelessWidget {
  const AttachmentPreviewBoxWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        height: 90,
        width: 120,
        padding: const EdgeInsets.only(
            left: Spacing.xs, bottom: Spacing.xs, right: Spacing.xs),
        decoration: BoxDecoration(
            color: PaletteNeutral.shade030,
            border: Border.all(color: PaletteNeutral.shade040),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.image, size: IconSizes.iconLg),
            const SizedBox(height: Spacing.xs),
            Text("My example...file name.jpeg",
                maxLines: 2, style: Theme.of(context).textTheme.bodySmall)
          ],
        ),
      ),
      Positioned(
        right: -16,
        top: -16,
        child: IconButton.filled(
            style: const ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(PaletteNeutral.shade200)),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () {},
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close,
                color: AppColor.activeChipFg, size: IconSizes.iconSm)),
      ),
    ]);
  }
}

// showModalBottomSheet(
//     isDismissible: true,
//     backgroundColor: AppColor.primaryBg,
//     context: context,
//     builder: (context) {
//       return Container(
//           padding: const EdgeInsets.all(Spacing.lg),
//           height: MediaQuery.sizeOf(context).height * 0.25,
//           child: Row(
//             children: [
//               Expanded(
//                 child: AspectRatio(
//                     aspectRatio: 1,
//                     child: Container(
//                       padding: const EdgeInsets.all(Spacing.md),
//                       decoration: BoxDecoration(
//                           color: AppColor.inactiveChipBg,
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(16)),
//                           border: Border.all(
//                               color: PaletteNeutral.shade060, width: 1)),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.camera_alt,
//                               color: PaletteNeutral.shade200,
//                               size: IconSizes.iconXxl),
//                           const SizedBox(height: Spacing.sm),
//                           Text("Select a photo or video.",
//                               textAlign: TextAlign.center,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall!
//                                   .copyWith(color: AppColor.body))
//                         ],
//                       ),
//                     )),
//               ),
//               const SizedBox(width: Spacing.md),
//               GestureDetector(
//                 onTap: () async {
//                   await FilePicker.platform.pickFiles();
//                 },
//                 child: Expanded(
//                   child: AspectRatio(
//                       aspectRatio: 1,
//                       child: Container(
//                         padding: const EdgeInsets.all(Spacing.md),
//                         decoration: BoxDecoration(
//                             color: AppColor.inactiveChipBg,
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(16)),
//                             border: Border.all(
//                                 color: PaletteNeutral.shade060, width: 1)),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.description,
//                                 color: PaletteNeutral.shade200,
//                                 size: IconSizes.iconXxl),
//                             const SizedBox(height: Spacing.sm),
//                             Text("Choose a file to attach.",
//                                 textAlign: TextAlign.center,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall!
//                                     .copyWith(color: AppColor.body))
//                           ],
//                         ),
//                       )),
//                 ),
//               ),
//             ],
//           ));
//     });
