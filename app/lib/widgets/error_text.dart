import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String text;
  final bool center;
  final double? width;

  const ErrorText(
      {super.key, required this.text, this.center = false, this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.error,
            color: AppColor.dangerBody, size: IconSizes.iconSm),
        const SizedBox(width: Spacing.xs),
        SizedBox(
          width: width,
          child: Text(
            text,
            textAlign: center ? TextAlign.center : null,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColor.dangerBody,
                ),
          ),
        ),
      ],
    );
  }
}
