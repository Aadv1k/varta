import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class VartaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNavigateBack;
  final List<Widget> actions;
  final bool centerTitle;

  final String? title;

  static const double defaultHeight = 54.0;

  const VartaAppBar({
    super.key,
    this.onNavigateBack,
    required this.actions,
    this.centerTitle = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primaryBg,
      scrolledUnderElevation: 0,
      toolbarHeight: defaultHeight,
      titleSpacing: 0,
      centerTitle: centerTitle,
      title: title != null
          ? Text(title!, style: Theme.of(context).textTheme.titleSmall)
          : null,
      leading: Padding(
        padding: const EdgeInsets.only(left: Spacing.sm),
        child: IconButton(
            iconSize: IconSizes.iconMd,
            color: AppColor.body,
            style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () {
              onNavigateBack?.call();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left)),
      ),
      actions: [Row(children: actions), const SizedBox(width: Spacing.md)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(defaultHeight);
}
