import 'package:app/common/sizes.dart';
import 'package:app/common/colors.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/delete_confirmation_dialog.dart';
import 'package:app/widgets/save_confirmation_dialog.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:app/widgets/varta_chip.dart';
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

class AnnouncementCreationData {
  final String title;
  final String body;
  final List<ScopeSelectionData> scopes;

  AnnouncementCreationData copyWith({
    String? title,
    String? body,
    List<ScopeSelectionData>? scopes,
  }) {
    return AnnouncementCreationData(
      title: title ?? this.title,
      body: body ?? this.body,
      scopes: scopes ?? this.scopes,
    );
  }

  bool isValid() {
    return (title.trim().isNotEmpty && body.trim().isNotEmpty) &&
        scopes.isNotEmpty;
  }

  AnnouncementCreationData({
    required this.scopes,
    required this.title,
    required this.body,
  });

  factory AnnouncementCreationData.fromModel(AnnouncementModel model) {
    return AnnouncementCreationData(
      title: model.title,
      body: model.body,
      scopes: model.scopes
          .map((e) => ScopeSelectionData.fromAnnouncementScope(e))
          .toList(),
    );
  }
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
      _announcementData =
          AnnouncementCreationData(scopes: [], title: "", body: "");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryBg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.primaryBg,
        toolbarHeight: 54,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left,
              color: AppColor.body, size: IconSizes.iconLg),
        ),
        actions: [
          if (widget.isUpdate) ...[
            IconButton(
                onPressed: _handleDeleteAnnouncement,
                icon: const Icon(Icons.delete,
                    color: PaletteNeutral.shade600, size: IconSizes.iconMd)),
            const SizedBox(width: Spacing.sm),
          ],
          Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
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
      body: Container(
        padding: const EdgeInsets.only(
          left: Spacing.md,
          right: Spacing.md,
          top: Spacing.sm,
          bottom: Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              minLines: 1,
              maxLines: 6,
              controller: _titleController,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: AppColor.heading),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Announcement Title",
                hintStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: AppColor.subtitle, fontWeight: FontWeight.normal),
              ),
            ),
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
                maxLines: 999,
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
          ],
        ),
      ),
    );
  }
}
