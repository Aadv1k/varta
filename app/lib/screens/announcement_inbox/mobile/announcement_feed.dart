import 'package:app/models/announcement_model.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/screens/announcement_inbox/for_you_announcement_feed.dart';
import 'package:app/widgets/providers/announcement_provider.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:app/widgets/state/announcement_state.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';

class AnnouncementInbox extends StatefulWidget {
  const AnnouncementInbox({super.key});

  @override
  _AnnouncementInboxState createState() => _AnnouncementInboxState();
}

class _AnnouncementInboxState extends State<AnnouncementInbox> {
  final ValueNotifier<bool> _isForYouView = ValueNotifier(true);
  final ScrollController _scrollController = ScrollController();
  late AnnouncementState _announcementState;

  @override
  void initState() {
    super.initState();
    _announcementState = AnnouncementState();
    TESTPUSH(_announcementState);
  }

  void TESTPUSH(AnnouncementState state) {
    state.addUserAnnouncements([
      AnnouncementModel(
        title: 'Summer Break Schedule',
        body:
            'Please note that the office will be closed from June 15th to June 30th for summer break. We will resume our regular hours on July 1st.',
        id: 'ANN-001',
        createdAt: DateTime(2024, 3, 10),
        author: AnnouncementAuthorModel(
          firstName: 'Emily',
          lastName: 'Chen',
          publicId: 'EC-001',
        ),
        scopes: [],
      )
    ]);
  }

  void _handleCreateAnnouncement(AnnouncementCreationData data) {
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
    return AnnouncementProvider(
      state: _announcementState,
      child: Scaffold(
        floatingActionButton: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth <= 600
              ? FloatingActionButton(
                  onPressed: () {
                    TESTPUSH(AnnouncementProvider.of(context).state);
                  },
                  backgroundColor: AppColor.primaryColor,
                  child: const Icon(Icons.add,
                      color: AppColor.primaryBg, size: IconSizes.iconLg),
                )
              : FloatingActionButton.extended(
                  onPressed: () {},
                  backgroundColor: AppColor.primaryColor,
                  label: const Text("Create Announcement",
                      style: TextStyle(
                          fontSize: FontSize.textBase,
                          fontWeight: FontWeight.normal,
                          color: AppColor.activeChipFg)),
                  icon: const Icon(Icons.add,
                      color: AppColor.primaryBg, size: IconSizes.iconLg),
                ),
        ),
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
                backgroundColor: PaletteNeutral.shade040,
                child: IconButton(
                  splashColor: PaletteNeutral.shade060,
                  padding: EdgeInsets.zero,
                  iconSize: IconSizes.iconMd,
                  onPressed: () {},
                  icon: const Center(child: Icon(Icons.person)),
                ),
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(84),
            child: Container(
              padding:
                  const EdgeInsets.only(left: Spacing.md, right: Spacing.md),
              child: Column(
                children: [
                  const CustomSearchBar(navigational: true),
                  const SizedBox(height: Spacing.sm),
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
      ),
    );
  }
}
