import 'dart:async';
import 'package:app/common/exceptions.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/login_data.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_inbox/mobile/placeholder_announcement_list_view.dart';
import 'package:app/screens/announcement_inbox/view_announcement_readonly_screen.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/services/simple_cache_service.dart';
import 'package:app/widgets/connection_error.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/announcement_provider.dart';
import 'package:app/widgets/providers/app_provider.dart';
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
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    _fetchInitial();
    _pollingTimer =
        Timer.periodic(const Duration(minutes: 10), (_) => _handlePoll());
    super.initState();
  }

  void _fetchInitial() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var state = AppProvider.of(context).state;
      SimpleCacheService cacheService = SimpleCacheService();

      final cachedAnnouncements =
          await cacheService.fetchOrNull("announcements");

      if (cachedAnnouncements != null) {
        _handlePoll();
        return;
      }

      try {
        List<AnnouncementModel> data =
            await _announcementRepo.getAnnouncements();
        state.addAnnouncements(data);
        SimpleCacheService cacheService = SimpleCacheService();
        cacheService.store("announcements", data);
      } on (ApiException, ApiClientException) {
        setState(() => _hasError = true);
      } on ApiTokenExpiredException {
        clearAndNavigateBackToLogin(context);
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  void _handlePoll() async {
    print("POLL NOW for newest announcements");

    var cache = await SimpleCacheService().fetchOrNull("announcements");
    var state = AppProvider.of(context).state;

    try {
      var data =
          await _announcementRepo.getNewestAnnouncements(cache!.cachedAt);
      state.addAnnouncements(data);
    } on (ApiException, ApiClientException) catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(ErrorSnackbar(innerText: e.toString()) as SnackBar);
    } on ApiTokenExpiredException {
      clearAndNavigateBackToLogin(context);
    }
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  Widget _showErrorGraphic() {
    if (_hasError) {
      return Center(
        child: GenericError(
            onTryAgain: () => _fetchInitial(),
            size: ErrorSize.large,
            errorMessage:
                "Sorry, we couldn't retrieve the announcements at the moment. Please try again"),
      );
    }
    return const Center(
      heightFactor: 0.75,
      child: GenericError(
          size: ErrorSize.large,
          svgPath: "relax.svg",
          errorMessage:
              "Nothing here yet. Announcements for you will show up here."),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = AppProvider.of(context).state;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => (_hasError || state.announcements.isEmpty)
          ? _showErrorGraphic()
          : RefreshIndicator(
              color: AppColor.primaryColor,
              backgroundColor: PaletteNeutral.shade000,
              onRefresh: () async {
                return _handlePoll();
              },
              child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    Skeletonizer.sliver(
                      enabled: state.announcements.isEmpty && _isLoading,
                      effect: const ShimmerEffect(
                        baseColor: PaletteNeutral.shade040,
                        highlightColor: PaletteNeutral.shade020,
                      ),
                      child: state.announcements.isEmpty && _isLoading
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
