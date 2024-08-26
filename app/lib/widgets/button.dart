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
        isLight ? AppColors.darkPrimaryColor : AppColors.primaryColor;
    final Color foregroundColor =
        isLight ? AppColors.primaryColor : Colors.white;

    final buttonStyle = Theme.of(context).elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            isDisabled ? backgroundColor.withOpacity(0.5) : backgroundColor,
          ),
          foregroundColor: WidgetStatePropertyAll(
            isDisabled ? foregroundColor.withOpacity(0.5) : foregroundColor,
          ),
        );

    return Container(
      constraints: const BoxConstraints(maxWidth: AppStyles.maxButtonWidth),
      height: AppStyles.buttonHeight,
      width: double.infinity,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: ElevatedButton(
          onPressed: isDisabled ? null : (isLoading ? null : onPressed),
          style: buttonStyle,
          child: isLoading
              ? Center(
                  child: SizedBox(
                      width: AppStyles.buttonLoaderSize,
                      height: AppStyles.buttonLoaderSize,
                      child: CircularProgressIndicator(
                          color: foregroundColor, strokeWidth: 3)))
              : Text(
                  text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizes.textBase,
                  ),
                ),
        ),
      ),
    );
  }
}
