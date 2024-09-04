import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String text;

  const ErrorText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColor.dangerBody,
            ));
  }
}
