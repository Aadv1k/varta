import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/screens/mobile/home/for_you_feed.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController? _scrollController;
  bool _showAppBarTitle = false;

  final double _toolBarHeight = 52;
  final double _expandedAppBarHeight = 52 * 2;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showAppBarTitle = _scrollController!.offset >
              (_expandedAppBarHeight - _toolBarHeight);
        });
      });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletteNeutral.shade010,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedAppBarHeight,
            toolbarHeight: _toolBarHeight,
            pinned: true,
            scrolledUnderElevation: 0,
            backgroundColor: PaletteNeutral.shade010,
            centerTitle: _showAppBarTitle,
            title: _showAppBarTitle
                ? Text(
                    "Announcements",
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : null,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: Spacing.md),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade400,
                  ),
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: Spacing.md, bottom: Spacing.md),
                  child: Text(
                    "Announcements",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: SearchHeaderSliverDelegate(),
            pinned: true,
          ),
          SliverPersistentHeader(
            delegate: TabListSearchDelegate(),
            pinned: false,
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            sliver: AnnouncementSliverList(),
          )
        ],
      ),
    );
  }
}

class SearchHeaderSliverDelegate extends SliverPersistentHeaderDelegate {
  double minHeight = 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: minHeight,
      decoration: BoxDecoration(
          color: PaletteNeutral.shade010,
          border: overlapsContent
              ? const Border(bottom: BorderSide(color: PaletteNeutral.shade060))
              : const Border()),
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.sm),
      child: const MockSearchBar(),
    );
  }

  @override
  double get maxExtent => minHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class MockSearchBar extends StatelessWidget {
  const MockSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: PaletteNeutral.shade030,
        border: Border.all(color: PaletteNeutral.shade040),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 28, color: PaletteNeutral.shade600),
          const SizedBox(width: Spacing.sm),
          Text("Search for announcements",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: PaletteNeutral.shade600))
        ],
      ),
    );
  }
}

class TabListSearchDelegate extends SliverPersistentHeaderDelegate {
  TabListSearchDelegate();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      color: PaletteNeutral.shade010,
      child: Row(children: [
        TabViewSelectorChip(
          text: "For You",
          onPressed: () {},
          isActive: true,
        ),
        const SizedBox(width: Spacing.sm),
        TabViewSelectorChip(
          text: "Your Announcements",
          onPressed: () {},
        ),
      ]),
    );
  }

  @override
  double get maxExtent => 76.0;

  @override
  double get minExtent => 76.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class TabViewSelectorChip extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const TabViewSelectorChip({
    Key? key,
    required this.text,
    this.isActive = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(color: AppColors.primaryColor),
      ),
      label: Text(
        text,
        style: TextStyle(
          fontSize: FontSizes.textBase,
          color: isActive ? AppColors.darkHeading : AppColors.heading,
        ),
      ),
      backgroundColor: isActive ? AppColors.primaryColor : Colors.transparent,
      onPressed: onPressed,
    );
  }
}
