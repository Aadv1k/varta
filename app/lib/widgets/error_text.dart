import 'package:app/common/colors.dart';
import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String text;
  final bool center;

  const ErrorText({super.key, required this.text, this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: center ? TextAlign.center : null,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColor.dangerBody,
            ));
  }
}
