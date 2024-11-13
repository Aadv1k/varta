import 'dart:async';
import 'dart:convert';
import 'package:app/common/exceptions.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement/announcement_screen.dart';
import 'package:app/screens/announcement_inbox/mobile/placeholder_announcement_list_view.dart';
import 'package:app/services/simple_cache_service.dart';
import 'package:app/widgets/generic_error_box.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:collection/collection.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _hasError = false;
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    _fetchInitial();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 6), (_) => _handlePoll());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _handlePage();
      }
    });
    super.initState();
  }

  List<AnnouncementModel> _getUpdatedAnnouncements(
      AnnouncementIncrementalChange changes) {
    if (!context.mounted) return [];
    var appState = AppProvider.of(context).state;

    List<AnnouncementModel> initialAnnouncements = [...appState.announcements];
    initialAnnouncements = initialAnnouncements
        .where((announcement) => !changes.deleted.contains(announcement))
        .toList();
    initialAnnouncements = initialAnnouncements.map((announcement) {
      var updated = changes.updated
          .firstWhereOrNull((updatedAnn) => updatedAnn == announcement);
      if (updated != null) return updated;
      return announcement;
    }).toList();

    final List<AnnouncementModel> finalAnnouncements = [
      ...changes.created,
      ...initialAnnouncements
    ];

    return finalAnnouncements;
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
        PaginatedAnnouncementModelList data =
            await _announcementRepo.getAnnouncements();
        state.addAnnouncements(data.data);
        state.saveAnnouncementState();
      } catch (exc) {
        if (exc is ApiTokenExpiredException) {
          clearAndNavigateBackToLogin(context);
          return;
        }
        setState(() => _hasError = true);
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  void _handlePoll() async {
    if (_isLoading) setState(() => _isLoading = false);
    if (!context.mounted) return;

    setState(() {
      _hasError = false;
    });

    var cacheService = SimpleCacheService();

    var cache = await cacheService.fetchOrNull("announcements");

    if (cache == null) {
      return;
    }

    var state = AppProvider.of(context).state;

    try {
      var changes = await _announcementRepo.fetchLatestChanges(cache.cachedAt);
      var newAnnouncements = _getUpdatedAnnouncements(changes);

      state.setAnnouncements(newAnnouncements);
      cacheService.store(
          "announcements",
          jsonEncode(
              state.announcements.map((elem) => elem.toJson()).toList()));
    } catch (exc) {
      if (exc is ApiTokenExpiredException) {
        clearAndNavigateBackToLogin(context);
        return;
      }

      if (exc is ApiClientException) {
        setState(() {
          _hasError = true;
        });
      } else {
        ErrorSnackbar(
                innerText: exc is ApiException
                    ? exc.toString()
                    : "Couldn't load more announcements. Please check your connection and try again")
            .show(context);
      }
    }
  }

  void _handlePage() async {
    if (!context.mounted) return;

    AppState appState = AppProvider.of(context).state;

    try {
      var data =
          await _announcementRepo.getAnnouncements(page: _currentPage + 1);

      if (data.pageNumber == data.maxPages) {
        // NOTE: yes, if the user keeps trying to fetch further, the app will
        // make unnecessary calls. However it is safe to assume few users will
        // reach here, and those who do will unlikely try to keep fetching
        return;
      }

      appState.addAnnouncements(data.data);
      setState(() => _currentPage = _currentPage + 1);
      appState.saveAnnouncementState(appendOnly: true);
    } catch (exc) {
      if (exc is ApiTokenExpiredException) {
        clearAndNavigateBackToLogin(context);
        return;
      }
      const ErrorSnackbar(
              innerText:
                  "Couldn't load more announcements. Please check your connection and try again")
          .show(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _showErrorGraphic() {
    if (_hasError) {
      return Center(
        heightFactor: 0.75,
        child: GenericErrorBox(
            onTryAgain: () {
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
              _fetchInitial();
            },
            size: ErrorSize.medium,
            errorMessage:
                "Whoops! it looks like something went wrong, please check your connection and try again."),
      );
    }

    return Center(
      heightFactor: 0.75,
      child: GenericErrorBox(
          size: ErrorSize.medium,
          svgPath: "relax.svg",
          onTryAgain: _handlePoll,
          onTryAgainLabel: "Refresh",
          errorMessage:
              "Nothing here yet. Announcements for you will show up here."),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = AppProvider.of(context).state;

    // TODO: this is a bit sus
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => _hasError || state.announcements.isEmpty
          ? _showErrorGraphic()
          : RefreshIndicator(
              color: AppColor.primaryColor,
              backgroundColor: PaletteNeutral.shade000,
              onRefresh: () async {
                return _handlePoll();
              },
              child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    Skeletonizer.sliver(
                      enabled: _isLoading,
                      effect: const ShimmerEffect(
                        baseColor: PaletteNeutral.shade040,
                        highlightColor: PaletteNeutral.shade020,
                      ),
                      child: _isLoading
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
                                                    AnnouncementScreen(
                                                        screenState:
                                                            AnnouncementScreenState
                                                                .viewOnly,
                                                        initialAnnouncement:
                                                            state.announcements[
                                                                index])));
                                      },
                                      announcement: state.announcements[index]),
                              separatorBuilder: (_, __) => const Divider(
                                  color: PaletteNeutral.shade040, height: 1)),
                    ),
                  ]),
            ),
    );
  }
}
