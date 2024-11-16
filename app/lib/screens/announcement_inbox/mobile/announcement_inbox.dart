import 'package:app/models/announcement_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement/announcement_screen.dart';
import 'package:app/screens/announcement_inbox/for_you_announcement_feed.dart';
import 'package:app/screens/announcement_inbox/user_announcements_feed.dart';
import 'package:app/screens/user_profile/user_profile_screen.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uuid/uuid.dart';

class AnnouncementInboxScreen extends StatefulWidget {
  const AnnouncementInboxScreen({super.key});

  @override
  _AnnouncementInboxScreenState createState() =>
      _AnnouncementInboxScreenState();
}

class _AnnouncementInboxScreenState extends State<AnnouncementInboxScreen> {
  final ValueNotifier<bool> _isForYouView = ValueNotifier<bool>(true);
  final AnnouncementsRepository _announcementRepo = AnnouncementsRepository();

  @override
  void initState() {
    super.initState();
  }

  void _handleCreateAnnouncement(AnnouncementCreationData data) async {
    if (!context.mounted) return;

    setState(() {
      _isForYouView.value = false;
    });

    var appState = AppProvider.of(context).state;

    List<AnnouncementAttachmentModel> optimisticAttachments = [];

    for (final rawAttachment in data.attachments) {
      optimisticAttachments.add(AnnouncementAttachmentModel(
        id: "OPTIMISTIC-${const Uuid().v4()}",
        createdAt: DateTime.now(),
        fileType: rawAttachment.fileType,
        fileName: rawAttachment.fileName,
        /** These values don't matter much since this is just for placeholder */
        fileSizeInBytes: 1024,
        /*********/
      ));
    }

    var optimisticAnnouncement = AnnouncementModel(
      author: AnnouncementAuthorModel(
          firstName: appState.user!.firstName,
          lastName: appState.user!.lastName,
          publicId: appState.user!.publicId),
      title: data.title,
      body: data.body,
      createdAt: DateTime.now(),
      attachments: optimisticAttachments,
      id: "OPTMISTIC-${const Uuid().v1()}",
      scopes: data.scopes
          .map((rawScope) => rawScope.toAnnouncementScope())
          .toList(),
    );

    var initialAnnouncements =
        List<AnnouncementModel>.from(appState.userAnnouncements);

    appState
        .addAnnouncements([optimisticAnnouncement], isUserAnnouncement: true);

    try {
      AnnouncementModel announcementModel =
          await _announcementRepo.createAnnouncement(data);

      appState.setAnnouncements([
        optimisticAnnouncement.copyWith(
            id: announcementModel.id,
            attachments: announcementModel.attachments),
        ...initialAnnouncements
      ], isUserAnnouncement: true);

      appState.saveAnnouncementState(isUserAnnouncement: true);
    } catch (exc) {
      const VartaSnackbar(
              innerText: "Couldn't create announcement.",
              snackBarVariant: VartaSnackBarVariant.error)
          // ignore: use_build_context_synchronously
          .show(context);
      appState.setAnnouncements(initialAnnouncements, isUserAnnouncement: true);
    }
  }

  void _handleFloatingButtonPress(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnnouncementScreen(
                  onCreate: _handleCreateAnnouncement,
                  screenState: AnnouncementScreenState.create,
                )));
  }

  @override
  Widget build(BuildContext context) {
    var appState = AppProvider.of(context).state;
    bool isTeacher = appState.user?.userType == UserType.teacher;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: isTeacher
          ? LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth <= 600
                  ? FloatingActionButton(
                      onPressed: () => _handleFloatingButtonPress(context),
                      backgroundColor: AppColor.primaryColor,
                      child: const Icon(Icons.add,
                          color: AppColor.primaryBg, size: IconSizes.iconLg),
                    )
                  : FloatingActionButton.extended(
                      onPressed: () => _handleFloatingButtonPress(context),
                      backgroundColor: AppColor.primaryColor,
                      label: const Text("Create Announcement",
                          style: TextStyle(
                              fontSize: FontSize.textBase,
                              fontWeight: FontWeight.normal,
                              color: AppColor.activeChipFg)),
                      icon: const Icon(Icons.add,
                          color: AppColor.primaryBg, size: IconSizes.iconLg),
                    ),
            )
          : null,
      backgroundColor: AppColor.primaryBg,
      appBar: AppBar(
        toolbarHeight: 86,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.primaryBg,
        centerTitle: true,
        title: Text("Varta", style: Theme.of(context).textTheme.titleMedium),
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: CircleAvatar(
              radius: 23,
              backgroundColor: PaletteNeutral.shade030,
              child: IconButton(
                splashColor: PaletteNeutral.shade050,
                highlightColor: PaletteNeutral.shade040,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(color: PaletteNeutral.shade040)),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppProvider(
                              state: appState, child: UserProfileScreen())));
                },
                icon: Center(
                    child: SvgPicture.asset(
                  "assets/icons/person.svg",
                  width: 22,
                  height: 22,
                )),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isTeacher ? 84 : 48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Column(
              children: [
                const CustomSearchBar(navigational: true),
                const SizedBox(height: Spacing.sm),
                if (isTeacher)
                  Row(
                    children: [
                      VartaChip(
                        variant: !_isForYouView.value
                            ? VartaChipVariant.secondary
                            : VartaChipVariant.primary,
                        text: "For You",
                        onPressed: () =>
                            setState(() => _isForYouView.value = true),
                        size: VartaChipSize.medium,
                      ),
                      const SizedBox(width: Spacing.sm),
                      VartaChip(
                        variant: _isForYouView.value
                            ? VartaChipVariant.secondary
                            : VartaChipVariant.primary,
                        text: "Your Announcements",
                        onPressed: () =>
                            setState(() => _isForYouView.value = false),
                        size: VartaChipSize.medium,
                      ),
                    ],
                  ),
                const SizedBox(height: Spacing.sm),
              ],
            ),
          ),
        ),
      ),
      body: Builder(builder: (context) {
        return _isForYouView.value
            ? const ForYouAnnouncementFeed()
            : const UserAnnouncementFeed();
      }),
    );
  }
}
