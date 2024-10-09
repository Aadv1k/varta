import 'dart:async';
import 'package:app/common/exceptions.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/login_data.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_inbox/mobile/placeholder_announcement_list_view.dart';
import 'package:app/screens/announcement_inbox/view_announcement_readonly_screen.dart';
import 'package:app/screens/login/phone_login.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/widgets/connection_error.dart';
import 'package:app/widgets/error_box.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/announcement_provider.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/login_state.dart';
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
  bool hasError = false;

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
      state.setAnnouncementLoadingStatus(true);
      List<AnnouncementModel> data;
      try {
        data = await _announcementRepo.getAnnouncements();
      } on (ApiException, ApiClientException) {
        setState(() => hasError = true);
        return;
      } on ApiTokenExpiredException {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => LoginProvider(
                    loginState: LoginState(data: LoginData()),
                    child: const WelcomeScreen())),
            (_) => false);
        return;
      }
      state.addAnnouncements(data);
      state.setAnnouncementLoadingStatus(false);
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

  Widget _showErrorGraphic() {
    if (hasError) {
      return Center(
        child: GenericError(
            onTryAgain: () => _fetchInitial(),
            size: ErrorSize.large,
            errorMessage:
                "Sorry, we couldn't retrieve the announcements at the moment. Please try again"),
      );
    }
    return const Center(
      child: GenericError(
          size: ErrorSize.large,
          svgPath: "relax.svg",
          errorMessage:
              "Nothing here yet. Announcements for you will show up here."),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = AnnouncementProvider.of(context).state;

    return (hasError || state.announcements.isEmpty)
        ? _showErrorGraphic()
        : ListenableBuilder(
            listenable: state,
            builder: (context, _) => RefreshIndicator(
              color: AppColor.primaryColor,
              backgroundColor: PaletteNeutral.shade000,
              onRefresh: () async {
                return _handlePoll();
              },
              child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    Skeletonizer.sliver(
                      enabled: state.announcementsLoading,
                      effect: const ShimmerEffect(
                        baseColor: PaletteNeutral.shade040,
                        highlightColor: PaletteNeutral.shade020,
                      ),
                      child: state.announcementsLoading
                          ? const PlaceholderAnnouncementListView()
                          : SliverList.separated(
                              itemCount: state.announcements.length,
                              itemBuilder: (context, index) =>
                                  AnnouncementListItem(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewAnnouncementReadonlyScreen(
                                                        announcement: state
                                                            .announcements[state
                                                                .announcements
                                                                .length -
                                                            1 -
                                                            index])));
                                      },
                                      announcement: state.announcements[
                                          state.announcements.length -
                                              1 -
                                              index]),
                              separatorBuilder: (_, __) => const Divider(
                                  color: PaletteNeutral.shade040, height: 1)),
                    ),
                  ]),
            ),
          );
  }
}
