import 'package:app/models/search_data.dart';
import 'package:app/providers/search_provider.dart';
import 'package:app/state/search_state.dart';
import 'package:async/async.dart';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/announcement_search/search_screen.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final bool navigational;
  final bool autofocus;
  final Function(String)? onSubmit;
  final Function(String)? onChange;
  final Duration duration;

  const CustomSearchBar(
      {super.key,
      this.navigational = false,
      this.autofocus = false,
      this.onSubmit,
      this.duration = const Duration(seconds: 1),
      this.onChange});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool isTyping = false;
  late RestartableTimer searchTimer;
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    searchTimer = RestartableTimer(widget.duration, () {
      if (widget.onSubmit != null) {
        widget.onSubmit!(_editingController.text);
      }
    });
    _editingController.addListener(() {
      if (widget.onChange != null) {
        widget.onChange!(_editingController.text);
      }
      setState(() {
        isTyping = _editingController.text.isNotEmpty;
        searchTimer.reset();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: PaletteNeutral.shade030,
        border: Border.all(color: PaletteNeutral.shade040),
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_rounded,
            size: IconSizes.iconMd,
            color: PaletteNeutral.shade200,
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: GestureDetector(
              onTap: widget.navigational
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchProvider(
                              searchState: SearchState(data: SearchData()),
                              child: const SearchScreen())))
                  : null,
              child: TextField(
                enabled: !widget.navigational,
                autofocus: widget.autofocus,
                controller: _editingController,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColor.subheading),
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
          ),
          if (isTyping)
            IconButton(
                onPressed: () => _editingController.clear(),
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: IconSizes.iconMd,
                  color: PaletteNeutral.shade200,
                )),
        ],
      ),
    );
  }
}
