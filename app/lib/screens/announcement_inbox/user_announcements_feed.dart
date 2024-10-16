import 'dart:async';
import 'dart:convert';
import 'package:app/common/exceptions.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/screens/announcement_inbox/mobile/placeholder_announcement_list_view.dart';
import 'package:app/screens/announcement_inbox/mobile/user_announcement_list_item.dart';
import 'package:app/screens/announcement_inbox/view_announcement_readonly_screen.dart';
import 'package:app/services/simple_cache_service.dart';
import 'package:app/widgets/connection_error.dart';
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_list_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserAnnouncementFeed extends StatefulWidget {
  const UserAnnouncementFeed({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserAnnouncementFeedState();
  }
}

class _UserAnnouncementFeedState extends State<UserAnnouncementFeed> {
  final AnnouncementsRepository _announcementRepo = AnnouncementsRepository();
  final ScrollController _scrollController = ScrollController();
  bool _hasError = false;
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    _fetchInitial();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _handlePage();
      }
    });
    super.initState();
  }

  void _fetchInitial() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var state = AppProvider.of(context).state;

      SimpleCacheService cacheService = SimpleCacheService();

      final cachedAnnouncements =
          await cacheService.fetchOrNull("userAnnouncements");

      if (cachedAnnouncements != null) {
        setState(() => _isLoading = false);
        return;
      }

      try {
        PaginatedAnnouncementModelList data =
            await _announcementRepo.getAnnouncements(isUserAnnouncement: true);
        state.addAnnouncements(data.data, isUserAnnouncement: true);
        state.saveAnnouncementState(isUserAnnouncement: true);
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

  void _handlePage() async {
    if (!context.mounted) return;

    AppState appState = AppProvider.of(context).state;

    try {
      var data = await _announcementRepo.getAnnouncements(
          page: _currentPage + 1, isUserAnnouncement: true);

      if (data.pageNumber == data.maxPages) {
        // NOTE: yes, if the user keeps trying to fetch further, the app will
        // make unnecessary calls. However it is safe to assume few users will
        // reach here, and those who do will unlikely try to keep fetching
        return;
      }

      appState.addAnnouncements(data.data, isUserAnnouncement: true);
      setState(() => _currentPage = _currentPage + 1);
      appState.saveAnnouncementState(
          appendOnly: true, isUserAnnouncement: true);
    } catch (exc) {
      if (exc is ApiTokenExpiredException) {
        clearAndNavigateBackToLogin(context);
        return;
      }

      const ErrorSnackbar(
              innerText:
                  "Couldn't load more announcements. Please check your connection and try again")
          .show(context);
    }
  }

  void _handleDeleteAnnouncement(int index) {
    var state = AppProvider.of(context).state;
    AnnouncementModel announcementToDelete = state.userAnnouncements[index];

    List<AnnouncementModel> newAnnouncements =
        List.from(state.userAnnouncements);
    newAnnouncements.removeAt(index);

    state.setAnnouncements(newAnnouncements, isUserAnnouncement: true);

    try {
      _announcementRepo.deleteAnnouncement(announcementToDelete);
      state.saveAnnouncementState(isUserAnnouncement: true);
    } catch (exc) {
      const ErrorSnackbar(
              innerText:
                  "Couldn't delete announcement. Please try again later.")
          .show(context);

      List<AnnouncementModel> oldAnnouncements =
          List.from(state.userAnnouncements);
      oldAnnouncements.insert(index, announcementToDelete);
      state.setAnnouncements(oldAnnouncements, isUserAnnouncement: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _showErrorGraphic() {
    if (_hasError) {
      return Center(
        heightFactor: 0.75,
        child: GenericError(
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

    return const Center(
      heightFactor: 0.75,
      child: GenericError(
          size: ErrorSize.medium,
          svgPath: "relax.svg",
          errorMessage: "You haven't created any announcements yet."),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = AppProvider.of(context).state;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => ((_hasError || state.userAnnouncements.isEmpty))
          ? _showErrorGraphic()
          : RefreshIndicator(
              color: AppColor.primaryColor,
              backgroundColor: PaletteNeutral.shade000,
              onRefresh: () async {
                print("ayooo");
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
                              itemCount: state.userAnnouncements.length,
                              itemBuilder: (context, index) =>
                                  UserAnnouncementListItem(
                                      onDelete: () =>
                                          _handleDeleteAnnouncement(index),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateAnnouncementScreen(
                                                        isUpdate: true,
                                                        onSave: (data) {
                                                          Navigator.pop(
                                                              context);
                                                          print(
                                                              "UPDATE: ${state.userAnnouncements[index].id}");
                                                        },
                                                        onDelete: () {
                                                          Navigator.pop(
                                                              context);
                                                          print(
                                                              "DELETE: ${state.userAnnouncements[index].id}");
                                                        },
                                                        onCreate: (data) {
                                                          assert(false,
                                                              "It should not be possible that when isUpdate is set to true the CreateANnouncemnetScreen can invoke this");
                                                        },
                                                        initialAnnouncement:
                                                            state.userAnnouncements[
                                                                index])));
                                      },
                                      announcement:
                                          state.userAnnouncements[index]),
                              separatorBuilder: (_, __) => const Divider(
                                  color: PaletteNeutral.shade040, height: 1)),
                    ),
                  ]),
            ),
    );
  }
}
