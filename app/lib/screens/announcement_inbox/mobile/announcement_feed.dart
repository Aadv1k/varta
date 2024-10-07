import 'package:app/models/announcement_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/widgets/providers/announcement_provider.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:app/widgets/state/announcement_state.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_list_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AnnouncementFeed extends StatefulWidget {
  const AnnouncementFeed({super.key});

  @override
  _AnnouncementFeedState createState() => _AnnouncementFeedState();
}

class _AnnouncementFeedState extends State<AnnouncementFeed> {
  bool _isForYouView = true;

  void TESTPUSH(AnnouncementProvider provider) {
    provider.state.addAnnouncements([
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
      _isForYouView = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnouncementProvider(
      state: AnnouncementState(),
      child: Scaffold(
          floatingActionButton: LayoutBuilder(
            builder: (context, contraints) => contraints.maxWidth <= 600
                ? FloatingActionButton(
                    onPressed: () {
                      TESTPUSH(AnnouncementProvider.of(context));
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => CreateAnnouncementScreen(
                      //             onCreate: _handleCreateAnnouncement)));
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
            title:
                Text("Varta", style: Theme.of(context).textTheme.titleMedium),
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
                          variant: !_isForYouView
                              ? VartaChipVariant.secondary
                              : VartaChipVariant.primary,
                          text: "For You",
                          onPressed: () => setState(() => _isForYouView = true),
                          size: VartaChipSize.medium,
                        ),
                        const SizedBox(width: Spacing.sm),
                        VartaChip(
                          variant: _isForYouView
                              ? VartaChipVariant.secondary
                              : VartaChipVariant.primary,
                          text: "Your Announcements",
                          onPressed: () =>
                              setState(() => _isForYouView = false),
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
            return RefreshIndicator(
              color: AppColor.primaryColor,
              backgroundColor: PaletteNeutral.shade000,
              onRefresh: () {
                return Future.delayed(const Duration(seconds: 1), () {
                  TESTPUSH(AnnouncementProvider.of(context));
                });
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [AnnouncementFeedSliverList(_isForYouView)],
              ),
            );
          })),
    );
  }
}

class AnnouncementFeedSliverList extends StatefulWidget {
  final bool isForYouView;

  const AnnouncementFeedSliverList(this.isForYouView, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AnnouncementFeedSliverListState();
  }
}

class _AnnouncementFeedSliverListState
    extends State<AnnouncementFeedSliverList> {
  final AnnouncementsRepository _announcementRepo = AnnouncementsRepository();

  @override
  void initState() {
    super.initState();
    _fetchInitialAnnouncements();
  }

  void _fetchInitialAnnouncements() async {
    var data = await _announcementRepo.getAnnouncements();
    if (!context.mounted) {
      return;
    }
    AnnouncementProvider.of(context).state.addAnnouncements(data);
  }

  @override
  Widget build(BuildContext context) {
    var state = AnnouncementProvider.of(context).state;

    return ListenableBuilder(
        listenable: state,
        builder: (context, _) => SliverList.separated(
              itemBuilder: (context, index) => AnnouncementListItem(
                  announcement: state
                      .announcements[state.announcements.length - 1 - index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: PaletteNeutral.shade050,
                height: 1,
              ),
              itemCount: state.announcements.length,
            ));
  }
}

// class AnnouncementListView extends StatefulWidget {
//   final bool isForYouView;

//   const AnnouncementListView({super.key, this.isForYouView = false});

//   @override
//   State<AnnouncementListView> createState() => _AnnouncementListViewState();
// }

// class _AnnouncementListViewState extends State<AnnouncementListView> {
//   final List<AnnouncementModel> _data = [];
//   AnnouncementsRepository _announcementsRepository = AnnouncementsRepository();
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     await Future.delayed(const Duration(seconds: 2));
//     var announcements = await _announcementsRepository.getAnnouncements();
//     setState(() {
//       _data.addAll(announcements);
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Skeletonizer.sliver(
//       enabled: _isLoading,
//       child: AnnouncementSliverList(
//           data: _isLoading
//               ? List.generate(
//                   10,
//                   (int index) => AnnouncementModel(
//                       title: 'This is an example title, to act as a proxy for',
//                       body:
//                           'So I guess we are generating some random data! pretty cool if you ask me ngl, anyway. Cool package, cool Language',
//                       id: '',
//                       createdAt: DateTime(2024, 30, 6),
//                       author: AnnouncementAuthorModel(
//                           firstName: 'Foo', lastName: 'Bar', publicId: '1234'),
//                       scopes: []))
//               : _data),
//     );
//   }
// }

// class AnnouncementSliverList extends StatelessWidget {
//   const AnnouncementSliverList({
//     super.key,
//     required List<AnnouncementModel> data,
//   }) : _data = data;

//   final List<AnnouncementModel> _data;

//   @override
//   Widget build(BuildContext context) {
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (BuildContext context, int index) {
//           return Column(
//             children: [
// AnnouncementListItem(announcement: _data[index]),
//               const Divider(
//                 height: 1.0,
//                 color: AppColor.subtitleLighter,
//                 endIndent: Spacing.md,
//                 indent: Spacing.md,
//               ),
//             ],
//           );
//         },
//         childCount: _data.length,
//       ),
//     );
//   }
// }

    // Skeletonizer(
    //   enabled: _isLoading,
    //   child: !_isLoading
    //       ? ListView.separated(
    //           itemBuilder: (context, index) =>
    //               AnnouncementListItem(announcement: _announcementData[index]),
    //           separatorBuilder: (BuildContext context, int index) =>
    //               const Divider(
    //             color: PaletteNeutral.shade050,
    //             height: 1,
    //           ),
    //           itemCount: _announcementData.length,
    //         )
    //       : ListView.separated(
    //           itemBuilder: (context, index) => AnnouncementListItem(
    //             announcement: AnnouncementModel(
    //               title: 'This is an example title, to act as a proxy for',
    //               body:
    //                   'So I guess we are generating some random data! pretty cool if you ask me ngl, anyway. Cool package, cool Language',
    //               id: '',
    //               createdAt: DateTime(2024, 3, 6), // corrected date
    //               author: AnnouncementAuthorModel(
    //                 firstName: 'Foo',
    //                 lastName: 'Bar',
    //                 publicId: '1234',
    //               ),
    //               scopes: [],
    //             ),
    //           ),
    //           separatorBuilder: (BuildContext context, int index) =>
    //               const Divider(
    //             color: PaletteNeutral.shade050,
    //             height: 1,
    //           ),
    //           itemCount: 10,
    //         ),
    // );
