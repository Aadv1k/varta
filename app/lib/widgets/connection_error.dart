import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ErrorSize { small, medium, large }

class GenericError extends StatelessWidget {
  final VoidCallback? onTryAgain;
  final ErrorSize size;
  final String? svgPath;
  final String errorMessage;

  const GenericError({
    super.key,
    this.onTryAgain,
    this.size = ErrorSize.medium,
    this.svgPath,
    this.errorMessage = "Something went wrong. Please try again later.",
  });

  @override
  Widget build(BuildContext context) {
    final double imageSize;
    final TextStyle messageStyle;

    switch (size) {
      case ErrorSize.small:
        imageSize = 100;
        messageStyle = Theme.of(context).textTheme.bodySmall!;
        break;
      case ErrorSize.large:
        imageSize = 280;
        messageStyle = Theme.of(context).textTheme.bodyLarge!;
        break;
      case ErrorSize.medium:
      default:
        imageSize = 180;
        messageStyle = Theme.of(context).textTheme.bodyMedium!;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgPath ?? "crashed-error.svg",
          width: imageSize,
          height: imageSize,
        ),
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: messageStyle,
          ),
        ),
        if (onTryAgain != null)
          TextButton(
            onPressed: onTryAgain,
            child: Text(
              "Try Again",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: TWColor.blue500),
            ),
          ),
      ],
    );
  }
}
