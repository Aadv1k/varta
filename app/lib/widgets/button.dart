import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool isLight;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.isLight = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isLight ? AppColor.darkPrimaryColor : AppColor.primaryColor;
    final Color foregroundColor =
        isLight ? AppColor.primaryColor : Colors.white;

    return Container(
      constraints:
          const BoxConstraints(maxWidth: AppSharedStyle.maxButtonWidth),
      height: AppSharedStyle.buttonHeight,
      width: double.infinity,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: ElevatedButton(
          onPressed: isDisabled ? null : (isLoading ? null : onPressed),
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(backgroundColor)),
          child: isLoading
              ? Center(
                  child: SizedBox(
                      width: AppSharedStyle.buttonLoaderSize,
                      height: AppSharedStyle.buttonLoaderSize,
                      child: CircularProgressIndicator(
                          color: foregroundColor, strokeWidth: 3)))
              : Text(text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                      )),
        ),
      ),
    );
  }
}
