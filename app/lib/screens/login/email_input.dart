import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class EmailInput extends StatefulWidget {
  final Function(String) onInput;
  final bool hasError;
  final String? errorMessage;

  const EmailInput({
    super.key,
    required this.onInput,
    required this.hasError,
    this.errorMessage,
  });

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  final emailInputController = TextEditingController();

  void _handleInputChange() {
    widget.onInput(emailInputController.text);
  }

  @override
  void initState() {
    super.initState();
    emailInputController.addListener(_handleInputChange);
  }

  @override
  void dispose() {
    emailInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderAccent =
        widget.hasError ? AppColor.dangerBody : AppColor.appBarBottomBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: borderAccent,
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: emailInputController,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: AppColor.heading),
              decoration: InputDecoration(
                hintText: "Email Address",
                suffixIcon: widget.hasError
                    ? const Icon(Icons.error_outline,
                        color: AppColor.dangerBody, size: IconSizes.iconMd)
                    : null,
                border: InputBorder.none,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColor.subtitle),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        widget.hasError
            ? Text(
                widget.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColor.dangerBody),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
