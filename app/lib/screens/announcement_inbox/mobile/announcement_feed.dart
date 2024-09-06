import 'package:app/models/announcement_model.dart';
import 'package:app/screens/announcement_search/search_screen.dart';
import 'package:app/screens/announcement_inbox/mobile/tab_selector_chip.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_list_item.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledUnder = false;
  bool _isForYouView = true;

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: LayoutBuilder(
        builder: (context, contraints) => contraints.maxWidth <= 600
            ? FloatingActionButton.large(
                onPressed: () {},
                backgroundColor: AppColor.primaryColor,
                child: const Icon(Icons.add,
                    color: AppColor.primaryBg, size: IconSizes.iconXl),
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
                  TabViewSelectorChip(
                    text: "For You",
                    onPressed: () => setState(() => _isForYouView = true),
                    isActive: _isForYouView ? true : false,
                  ),
                  const SizedBox(width: Spacing.sm),
                  TabViewSelectorChip(
                    text: "Your Announcements",
                    onPressed: () => setState(() => _isForYouView = false),
                    isActive: _isForYouView ? false : true,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: Spacing.md),
            sliver: AnnouncementListView(
              key: ValueKey<bool>(_isForYouView),
              isForYouView: _isForYouView,
            ),
          )
        ],
      ),
    );
  }
}

class AnnouncementListView extends StatefulWidget {
  final bool isForYouView;

  const AnnouncementListView({super.key, this.isForYouView = false});

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  final List<AnnouncementModel> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant AnnouncementListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isForYouView != oldWidget.isForYouView) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    // setState(() {
    //   _data.addAll(
    //       widget.isForYouView ? announcements : additionalAnnouncements);
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      enabled: _isLoading,
      child: AnnouncementSliverList(
          data: _isLoading
              ? List.generate(
                  10,
                  (int index) => AnnouncementModel(
                      title: 'This is an example title, to act as a proxy for',
                      body:
                          'So I guess we are generating some random data! pretty cool if you ask me ngl, anyway. Cool package, cool Language',
                      id: '',
                      createdAt: DateTime(2024, 30, 6),
                      author: AnnouncementAuthorModel(
                          firstName: 'Foo', lastName: 'Bar', publicId: '1234'),
                      scopes: []))
              : _data),
    );
  }
}

class AnnouncementSliverList extends StatelessWidget {
  const AnnouncementSliverList({
    super.key,
    required List<AnnouncementModel> data,
  }) : _data = data;

  final List<AnnouncementModel> _data;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: [
              AnnouncementListItem(announcement: _data[index]),
              const Divider(
                height: 1.0,
                color: AppColor.subtitleLighter,
                endIndent: Spacing.md,
                indent: Spacing.md,
              ),
            ],
          );
        },
        childCount: _data.length,
      ),
    );
  }
}
