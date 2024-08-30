import 'package:app/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController? _scrollController;
  bool _showAppBarTitle = false;

  final double _toolBarHeight = 52;
  final double _expandedAppBarHeight = 72 * 1.8;

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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedAppBarHeight,
            toolbarHeight: _toolBarHeight,
            pinned: true,
            scrolledUnderElevation: 0,
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: _showAppBarTitle,
            title: _showAppBarTitle
                ? const Text("Announcements",
                    style: TextStyle(
                      fontSize: FontSizes.textLg,
                      fontWeight: FontWeight.w900,
                    ))
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
            flexibleSpace: const FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: Spacing.md),
                  child: Text(
                    "Announcements",
                    style: TextStyle(
                      fontSize: FontSizes.text3xl,
                      fontWeight: FontWeight.w900,
                    ),
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
          SliverList.builder(
            itemBuilder: (context, index) =>
                ListTile(title: Text("Item $index")),
            itemCount: 32,
          )
        ],
      ),
    );
  }
}

class SearchHeaderSliverDelegate extends SliverPersistentHeaderDelegate {
  // Constructor
  SearchHeaderSliverDelegate();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
          color: TWColor.white,
          border: overlapsContent
              ? const Border(bottom: BorderSide(color: TWColor.slate200))
              : null),
      padding: const EdgeInsets.only(
          right: Spacing.md,
          left: Spacing.md,
          top: Spacing.sm,
          bottom: Spacing.sm), // Example Spacing values
      child: Container(
        decoration: BoxDecoration(
          color:
              Colors.grey[300], // Example color, replace with TWColor.slate600
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}

class TabListSearchDelegate extends SliverPersistentHeaderDelegate {
  TabListSearchDelegate();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.sm),
        child: Row(children: [
          Container(color: TWColor.slate900, child: const Text("For you")),
          const SizedBox(width: Spacing.sm),
          Container(
              color: TWColor.slate400, child: const Text("Your Announcements")),
        ]));
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
