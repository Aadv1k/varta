import 'package:app/common/colors.dart';
import 'package:flutter/material.dart';

enum VartaCheckboxSize { sm, md, lg }

class VartaCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged onChanged;
  final VartaCheckboxSize size;

  const VartaCheckbox(
      {super.key,
      required this.checked,
      required this.onChanged,
      this.size = VartaCheckboxSize.md});

  @override
  Widget build(BuildContext context) {
    double boxSize = 24.0;

    switch (size) {
      case VartaCheckboxSize.lg:
        boxSize = 32.0;
      case VartaCheckboxSize.sm:
        boxSize = 16.0;
      case VartaCheckboxSize.md:
        break;
    }

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Checkbox(
        value: checked,
        onChanged: onChanged,
        activeColor: AppColor.primaryColor,
        side: const BorderSide(color: AppColor.primaryColor),
        checkColor: Colors.white,
      ),
    );
  }
}
