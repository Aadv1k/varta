import 'dart:io';
import 'dart:typed_data';

import 'package:app/common/const.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/search_data.dart';
import 'package:app/screens/announcement/attachment_preview_box.dart';
import 'package:app/widgets/generic_confirmaton_dialog.dart';
import 'package:app/widgets/varta_app_bar.dart';
import 'package:collection/collection.dart';
import 'package:mime/mime.dart';

import 'package:app/common/colors.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/delete_confirmation_dialog.dart';
import 'package:app/widgets/save_confirmation_dialog.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/announcement/scope_selection_bottom_sheet.dart';

enum AnnouncementScreenState { viewOnly, create, modify }

class AnnouncementScreen extends StatefulWidget {
  final AnnouncementScreenState screenState;

  final Function(AnnouncementCreationData)? onCreate;
  final Function(AnnouncementCreationData)? onModify;
  final Function()? onDelete;

  final AnnouncementModel? initialAnnouncement;

  const AnnouncementScreen(
      {super.key,
      this.onCreate,
      this.onModify,
      this.onDelete,
      this.initialAnnouncement,
      required this.screenState});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late AnnouncementCreationData _announcementData;
  bool shouldDisableAdd = false;
  int currentAttachmentSize = 0;

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _announcementData = switch (widget.screenState) {
      AnnouncementScreenState.create => AnnouncementCreationData(
          scopes: [], title: "", body: "", attachments: []),
      AnnouncementScreenState.modify =>
        AnnouncementCreationData.fromModel(widget.initialAnnouncement!),
      AnnouncementScreenState.viewOnly =>
        AnnouncementCreationData.fromModel(widget.initialAnnouncement!)
    };

    _titleController.text = _announcementData.title;
    _bodyController.text = _announcementData.body;

    _titleController.addListener(() => setState(() => _announcementData =
        _announcementData.copyWith(title: _titleController.text)));

    _bodyController.addListener(() => setState(() => _announcementData =
        _announcementData.copyWith(body: _bodyController.text)));
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

  void _handleDeleteAttachment(int index) {
    // We won't add any other logic in here. The deletion logic will only apply when a user modifies the announcement, in which case the onModify will handle the "update" for the upload
    setState(() {
      _announcementData = _announcementData.copyWith(
        attachments: [..._announcementData.attachments]..removeAt(index),
      );
    });
  }

  void _handleCreateAnnouncement() {
    widget.onCreate!(_announcementData);
    Navigator.pop(context);
  }

  void _handleSaveAnnouncement() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SaveConfirmationDialog(
              onSave: () {
                Navigator.pop(context);
                widget.onModify!(_announcementData);
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
                widget.onDelete!();
              },
              onCancel: () => Navigator.pop(context),
            ));
  }

  void _handleAddAttachment(BuildContext context) async {
    bool shouldShowUploadErrorDialog = false;
    String? errorDialogMessage;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ["png", "jpeg", "doc", "docx", "pdf", "xls", "xlsx"],
        type: FileType.custom);

    if (result == null) {
      return;
    }

    File file = File(result.files.single.path!);
    Uint8List data = await file.readAsBytes();
    int fileLength = data.length;

    if (fileLength < 1024) {
      shouldShowUploadErrorDialog = true;
      errorDialogMessage =
          "The selected file is too small. Minimum size is 1 KB.";
    } else if (fileLength > maxUploadSizeInBytes) {
      shouldShowUploadErrorDialog = true;
      errorDialogMessage =
          "The selected file is too large. Maximum size is ${maxUploadSizeInBytes / 2048} MB.";
    } else {
      String? possibleMimeType =
          lookupMimeType("null", headerBytes: data.sublist(0, 1024));

      if (possibleMimeType == null) {
        shouldShowUploadErrorDialog = true;
        errorDialogMessage =
            "Unable to determine the file type. Please select a supported file format.";
      } else if (currentAttachmentSize + data.length >
          maxQuotaForAttachmentsInBytes) {
        shouldShowUploadErrorDialog = true;
        errorDialogMessage =
            "Adding this file will exceed the total attachment size limit. Consider removing other attachments.";
      } else {
        setState(() {
          currentAttachmentSize += data.length;
          _announcementData = _announcementData.copyWith(attachments: [
            ..._announcementData.attachments,
            AttachmentSelectionData(
                filePath: file.path,
                fileName: file.path.split("/").last,
                fileType: AnnouncementAttachmentFileType.values
                        .firstWhereOrNull(
                            (ft) => ft.mime == possibleMimeType) ??
                    AnnouncementAttachmentFileType.pdf)
          ]);
        });
      }
    }

    if (shouldShowUploadErrorDialog) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => GenericConfirmationDialog(
          onConfirm: () {
            Navigator.pop(context);
          },
          title: "Couldn't upload attachment",
          body: errorDialogMessage ??
              'An unknown error occurred while adding the attachment.',
          confirmLabel: "OK",
          primaryAction: GenericConfirmatonDialogAction.cancel,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCreateOrModify =
        widget.screenState == AnnouncementScreenState.create ||
            widget.screenState == AnnouncementScreenState.modify;

    bool isModify = widget.screenState == AnnouncementScreenState.modify;

    return Scaffold(
      backgroundColor: AppColor.primaryBg,
      appBar: VartaAppBar(actions: [
        if (isCreateOrModify) ...[
          if (isModify) ...[
            IconButton(
                style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: _handleDeleteAnnouncement,
                icon: const Icon(Icons.delete,
                    color: AppColor.subtitle, size: IconSizes.iconMd)),
            const SizedBox(width: Spacing.sm),
          ],
          SizedBox(
            child: IconButton(
                style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: () => _handleAddAttachment(context),
                icon: const Icon(Icons.attachment,
                    color: AppColor.subtitle, size: IconSizes.iconMd)),
          ),
          const SizedBox(width: Spacing.sm),
          VartaButton(
            onPressed: _announcementData.isValid()
                ? (isModify
                    ? _handleSaveAnnouncement
                    : _handleCreateAnnouncement)
                : null,
            label: isModify ? "Save" : "Create",
            variant: VartaButtonVariant.primary,
            size: VartaButtonSize.small,
          ),
        ]
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isCreateOrModify)
                TextField(
                  minLines: 1,
                  maxLines: null,
                  controller: _titleController,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: AppColor.heading, overflow: TextOverflow.ellipsis),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Announcement Title",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(
                            color: AppColor.subtitle,
                            fontWeight: FontWeight.normal),
                  ),
                )
              else
                Text(_announcementData.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: AppColor.heading)),
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
                      return VartaChip(
                        variant: VartaChipVariant.secondary,
                        text: entry.value.getUserFriendlyLabel(),
                        onDeleted: isCreateOrModify
                            ? () => _handleDeleteScope(entry.key)
                            : null,
                        size: VartaChipSize.small,
                      );
                    }).toList(),
                  ),
                  if (_announcementData.scopes.isNotEmpty && isCreateOrModify)
                    const SizedBox(height: Spacing.sm),
                  if (isCreateOrModify)
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
                                  onCreated: (scope) =>
                                      _handleCreateScope(scope),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCreateOrModify)
                    TextField(
                      maxLines: null,
                      controller: _bodyController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'eg "This is an announcement regarding..."',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppColor.subtitle,
                                ),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColor.heading,
                          ),
                    )
                  else
                    Text(
                      _announcementData.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColor.body),
                      maxLines: null,
                    ),
                  const SizedBox(height: Spacing.lg),
                  Wrap(
                      clipBehavior: Clip.none,
                      runSpacing: Spacing.sm,
                      spacing: Spacing.sm,
                      children: _announcementData.attachments
                          .asMap()
                          .entries
                          .map((entry) => AttachmentPreviewBox(
                              onDelete: isCreateOrModify
                                  ? () => _handleDeleteAttachment(entry.key)
                                  : null,
                              attachment: entry.value))
                          .toList()),
                  const SizedBox(height: Spacing.sm),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
