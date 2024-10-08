import 'dart:async';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_inbox/mobile/placeholder_announcement_list_view.dart';
import 'package:app/screens/announcement_inbox/view_announcement_readonly_screen.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/announcement_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_list_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ForYouAnnouncementFeed extends StatefulWidget {
  const ForYouAnnouncementFeed({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ForYouAnnouncementFeedState();
  }
}

class _ForYouAnnouncementFeedState extends State<ForYouAnnouncementFeed> {
  final AnnouncementsRepository _announcementRepo = AnnouncementsRepository();
  late Timer _pollingTimer;

  @override
  void initState() {
    _fetchInitial();
    _pollingTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _handlePoll());
    super.initState();
  }

  void _fetchInitial() async {
    if (!context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var state = AnnouncementProvider.of(context).state;
      var data = await _announcementRepo.getAnnouncements();

      state.addAnnouncements(data);
      state.setAnnouncementsLoaded();
    });
  }

  void _handlePoll() async {
    if (!context.mounted) return;

    try {
      var newest = await _announcementRepo.getNewestAnnouncements();
      AnnouncementProvider.of(context).state.addAnnouncements(newest);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const ErrorSnackbar(
              innerText: "Something went wrong. Please try again later.")
          as SnackBar);
    }
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = AnnouncementProvider.of(context).state;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => RefreshIndicator(
        color: AppColor.primaryColor,
        backgroundColor: PaletteNeutral.shade000,
        onRefresh: () async {
          return _handlePoll();
        },
        child:
            CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          Skeletonizer.sliver(
            enabled: !state.announcementsLoaded,
            effect: const ShimmerEffect(
              baseColor: PaletteNeutral.shade040,
              highlightColor: PaletteNeutral.shade020,
            ),
            child: !state.announcementsLoaded
                ? const PlaceholderAnnouncementListView()
                : SliverList.separated(
                    itemCount: state.announcements.length,
                    itemBuilder: (context, index) => AnnouncementListItem(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewAnnouncementReadonlyScreen(
                                          announcement: state.announcements[
                                              state.announcements.length -
                                                  1 -
                                                  index])));
                        },
                        announcement: state.announcements[
                            state.announcements.length - 1 - index]),
                    separatorBuilder: (_, __) => const Divider(
                        color: PaletteNeutral.shade040, height: 1)),
          ),
        ]),
      ),
    );
  }
}
