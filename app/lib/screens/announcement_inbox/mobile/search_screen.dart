import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Search", style: Theme.of(context).textTheme.titleLarge),
          toolbarHeight: 64,
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(52),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                child: SearchBar(),
              )),
          leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chevron_left, size: IconSizes.iconLg))),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: PaletteNeutral.shade030,
        border: Border.all(color: PaletteNeutral.shade030),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_rounded,
            size: IconSizes.iconMd,
            color: PaletteNeutral.shade200,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search for announcements",
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: PaletteNeutral.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
