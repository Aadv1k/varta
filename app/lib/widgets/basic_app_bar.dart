import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const BasicAppBar({
    Key? key,
    this.title = '',
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
            color: AppColor.heading,
            fontWeight: FontWeight.bold,
            fontSize: FontSize.textBase),
      ),
      actions: actions,
      leading: leading,
      backgroundColor: AppColor.primaryBg,
      elevation: 0,
    );
  }
}
