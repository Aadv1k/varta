import 'dart:async';
import 'dart:convert';
import 'package:app/common/const.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
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
  bool _hasSecondaryError = false;
  bool _hasPrimaryError = false;
  bool _isLoading = true;
  int _currentPage = 1;
  bool cannotPageFurther = false;

  @override
  void initState() {
    _fetchInitial();
    _pollingTimer = Timer.periodic(
        const Duration(seconds: pollingDurationInSeconds),
        (_) => _handlePoll());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          (_scrollController.position.maxScrollExtent)) {
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
      final updatedAnnouncement = changes.updated
          .firstWhereOrNull((updatedAnn) => updatedAnn.id == announcement.id);
      return updatedAnnouncement ?? announcement;
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

      setState(() {
        _isLoading = true;
        _hasPrimaryError = false;
      });

      final cachedAnnouncements =
          await cacheService.fetchOrNull("announcements");

      if (cachedAnnouncements != null && cachedAnnouncements.data.isNotEmpty) {
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
        setState(() => _hasPrimaryError = true);
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  void _handlePoll() async {
    if (_isLoading) setState(() => _isLoading = false);
    if (!context.mounted || _hasSecondaryError) return;

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

      if (!_pollingTimer.isActive) {
        _pollingTimer = Timer.periodic(
            const Duration(seconds: pollingDurationInSeconds),
            (_) => _handlePoll());
      }
    } catch (exc) {
      if (exc is ApiTokenExpiredException) {
        clearAndNavigateBackToLogin(context);
        return;
      }
      setState(() => _hasSecondaryError = true);
    }
  }

  void _handlePage() async {
    if (!context.mounted || cannotPageFurther) return;

    AppState appState = AppProvider.of(context).state;

    try {
      var data =
          await _announcementRepo.getAnnouncements(page: _currentPage + 1);

      appState.addAnnouncements(data.data);
      setState(() => _currentPage = _currentPage + 1);
      appState.saveAnnouncementState(appendOnly: true);
    } catch (exc) {
      if (exc is ApiTokenExpiredException) {
        clearAndNavigateBackToLogin(context);
        return;
      }
      setState(() {
        cannotPageFurther = true;
      });
      const VartaSnackbar(
        snackBarVariant: VartaSnackBarVariant.warning,
        innerText:
            "Couldn't fetch more announcements, you've reached the end of the list.",
      ).show(context);
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

  Widget _showInitialGraphic(AppState state) {
    if (_hasPrimaryError) {
      return Center(
          heightFactor: 0.85,
          child: GenericErrorBox(
            size: ErrorSize.medium,
            svgPath: "crashed-error.svg",
            onTryAgain: _fetchInitial,
            onTryAgainLabel: "Retry",
            errorMessage:
                "We couldn’t load the announcements. Please check your connection and try again.",
          ));
    }

    return const Center(
      heightFactor: 0.85,
      child: GenericErrorBox(
          size: ErrorSize.medium,
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
      builder: (context, _) => (state.announcements.isEmpty ||
                  _hasPrimaryError) &&
              !_isLoading
          ? _showInitialGraphic(state)
          : RefreshIndicator(
              color: AppColor.primaryColor,
              backgroundColor: PaletteNeutral.shade000,
              onRefresh: () async {
                setState(() {
                  _hasSecondaryError = false;
                });
                _pollingTimer.cancel();
                return _handlePoll();
              },
              child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    if (_hasSecondaryError)
                      SliverToBoxAdapter(
                        child: Container(
                          color: TWColor.red50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md, vertical: Spacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Couldn't fetch new announcements. Check your connection and try again later.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: TWColor.red700),
                                ),
                              ),
                              const SizedBox(width: Spacing.sm),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hasSecondaryError = false;
                                    });
                                    _pollingTimer.cancel();
                                    return _handlePoll();
                                  },
                                  icon: const Icon(Icons.refresh,
                                      color: TWColor.red600,
                                      size: IconSizes.iconMd))
                            ],
                          ),
                        ),
                      ),
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
