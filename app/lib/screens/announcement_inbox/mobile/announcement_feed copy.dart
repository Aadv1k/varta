import 'package:app/models/announcement_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/screens/announcement_creation/create_announcement_screen.dart';
import 'package:app/widgets/search_bar.dart';
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
  final ScrollController _scrollController = ScrollController();

  bool _isScrolledUnder = false;
  bool _isForYouView = true;

  bool _isLoading = true;

  final List<AnnouncementModel> _announcementData = [];
  final List<AnnouncementModel> _yourAnnouncementsData = [];

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 112) {
        setState(() => _isScrolledUnder = true);
      } else {
        setState(() => _isScrolledUnder = false);
      }
    });
    super.initState();
  }

  void TESTPUSH() {
    setState(() {
      _announcementData.add(AnnouncementModel(
          title: "This is a new test announcement",
          body: "foo bar baz",
          id: "2938",
          createdAt: DateTime.now(),
          author: AnnouncementAuthorModel(
              firstName: "Foo", lastName: "Bar", publicId: "28939283"),
          scopes: []));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return Scaffold(
      floatingActionButton: LayoutBuilder(
        builder: (context, contraints) => contraints.maxWidth <= 600
            ? FloatingActionButton(
                onPressed: () {
                  TESTPUSH();
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            toolbarHeight: 72,
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
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: _isScrolledUnder
                            ? const BorderSide(
                                color: PaletteNeutral.shade070, width: 1)
                            : const BorderSide(style: BorderStyle.none))),
                padding: const EdgeInsets.only(
                    left: Spacing.md, right: Spacing.md, bottom: Spacing.sm),
                child: const CustomSearchBar(navigational: true),
              ),
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
              ),
              child: Row(
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
                    onPressed: () => setState(() => _isForYouView = false),
                    size: VartaChipSize.medium,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.only(top: Spacing.md),
              sliver: SliverFillRemaining(
                  child: AnnouncementFeedList(_announcementData)))
        ],
      ),
    );
  }
}

class AnnouncementFeedList extends StatefulWidget {
  List<AnnouncementModel> initialAnnouncements;

  AnnouncementFeedList(this.initialAnnouncements, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AnnouncementFeedListState();
  }
}

class _AnnouncementFeedListState extends State<AnnouncementFeedList> {
  final AnnouncementsRepository _announcementRepo = AnnouncementsRepository();
  bool _isLoading = true;
  List<AnnouncementModel> _announcementData = [];

  @override
  void initState() {
    // _parentDataValueNotifier.value = widget.initialAnnouncements;
    // _parentDataValueNotifier.addListener(() {
    //   _announcementData = [
    //     ..._parentDataValueNotifier.value,
    //     ..._announcementData
    //   ];
    // });

    print(widget.initialAnnouncements);

    _announcementData = [...widget.initialAnnouncements];
    _fetchInitialData();
    super.initState();
  }

  @override
  void dispose() {
    // _parentDataValueNotifier.dispose();
    super.dispose();
  }

  void _fetchInitialData() async {
    var data = await _announcementRepo.getAnnouncements();
    setState(() {
      _announcementData.addAll(data);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: _isLoading,
      child: !_isLoading
          ? ListView.separated(
              itemBuilder: (context, index) =>
                  AnnouncementListItem(announcement: _announcementData[index]),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: PaletteNeutral.shade050,
                height: 1,
              ),
              itemCount: _announcementData.length,
            )
          : ListView.separated(
              itemBuilder: (context, index) => AnnouncementListItem(
                announcement: AnnouncementModel(
                  title: 'This is an example title, to act as a proxy for',
                  body:
                      'So I guess we are generating some random data! pretty cool if you ask me ngl, anyway. Cool package, cool Language',
                  id: '',
                  createdAt: DateTime(2024, 3, 6), // corrected date
                  author: AnnouncementAuthorModel(
                    firstName: 'Foo',
                    lastName: 'Bar',
                    publicId: '1234',
                  ),
                  scopes: [],
                ),
              ),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: PaletteNeutral.shade050,
                height: 1,
              ),
              itemCount: 10,
            ),
    );
  }
}
