import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const BasicAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      actions: actions,
      leading: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.chevron_left,
                color: TWColor.black,
                size: IconSizes.iconMd,
              )),
          if (leading != null) leading!,
        ],
      ),
      backgroundColor: AppColor.primaryBg,
      elevation: 0,
    );
  }
}
