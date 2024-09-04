import 'package:async/async.dart';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/announcement_inbox/mobile/search_screen.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final bool navigational;
  final bool autofocus;
  final TextEditingController? editingController;
  final Function(String)? onSearch;
  final Duration duration;

  const CustomSearchBar(
      {Key? key,
      this.navigational = false,
      this.autofocus = false,
      this.editingController,
      this.onSearch,
      this.duration = const Duration(seconds: 1)})
      : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool isTyping = false;
  late RestartableTimer searchTimer;

  @override
  void initState() {
    searchTimer = RestartableTimer(widget.duration, () {
      if (widget.onSearch != null) {
        widget.onSearch!(widget.editingController!.text);
      }
    });
    if (widget.editingController != null) {
      widget.editingController!.addListener(() {
        setState(() {
          isTyping = widget.editingController!.text.isNotEmpty;
          searchTimer.reset();
        });
      });
    }
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
                          builder: (context) => const SearchScreen()))
                  : null,
              child: TextField(
                enabled: !widget.navigational,
                autofocus: widget.autofocus,
                controller: widget.editingController,
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
                onPressed: () => widget.editingController!.clear(),
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
