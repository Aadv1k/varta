import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/screens/announcement_inbox/for_you_announcement_feed.dart';
import 'package:app/screens/user_profile/user_profile_screen.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/announcement_provider.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:app/widgets/state/announcement_state.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementInboxScreen extends StatefulWidget {
  const AnnouncementInboxScreen({super.key});

  @override
  _AnnouncementInboxScreenState createState() =>
      _AnnouncementInboxScreenState();
}

class _AnnouncementInboxScreenState extends State<AnnouncementInboxScreen> {
  final ValueNotifier<bool> _isForYouView = ValueNotifier<bool>(false);
  AnnouncementsRepository _announcementRepo = AnnouncementsRepository();

  @override
  void initState() {
    super.initState();
  }

  void _handleCreateAnnouncement(AnnouncementCreationData data) {
    if (!context.mounted) return;

    var appState = AppProvider.of(context).state;

    assert(false,
        "NOT IMPLEMENTED: logic for converting the AnnouncementCreationData to the AnnouncementModel");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Announcement created successfully"),
        action: SnackBarAction(label: "Undo", onPressed: () {}),
      ),
    );
    setState(() {
      _isForYouView.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = AppProvider.of(context).state;
    bool isTeacher = appState.user?.userType == UserType.student;

    return Scaffold(
      floatingActionButton: isTeacher
          ? LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth <= 600
                  ? FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: AppColor.primaryColor,
                      child: const Icon(Icons.add,
                          color: AppColor.primaryBg, size: IconSizes.iconLg),
                    )
                  : FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateAnnouncementScreen(
                                        onCreate: (data) async {
                                      try {
                                        await _announcementRepo
                                            .createAnnouncement(data);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(e.toString())));
                                      }
                                    })));
                      },
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
        toolbarHeight: 84,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.primaryBg,
        centerTitle: true,
        title: Text("Varta", style: Theme.of(context).textTheme.titleMedium),
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Spacing.lg),
            child: CircleAvatar(
              backgroundColor: AppColor.inactiveChipBg,
              child: IconButton(
                splashColor: PaletteNeutral.shade060,
                padding: EdgeInsets.zero,
                iconSize: IconSizes.iconMd,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AppProvider(
                              state: appState,
                              child: const UserProfileScreen())));
                },
                icon: const Center(child: Icon(Icons.person)),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isTeacher ? 84 : 48),
          child: Container(
            padding: const EdgeInsets.only(left: Spacing.md, right: Spacing.md),
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
        return const ForYouAnnouncementFeed();
      }),
    );
  }
}
