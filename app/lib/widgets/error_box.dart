import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ErrorBox extends StatelessWidget {
  final String errorMessage;

  const ErrorBox({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("crashed-error.svg", width: 320, height: 320),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text("Oops! Something went wrong.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall),
          ),
        ]);
  }
}
