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
    Color borderAccent = widget.hasError ? TWColor.red400 : TWColor.zinc200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 360,
          height: 56,
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
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Email Address",
                suffixIcon: widget.hasError
                    ? const Icon(Icons.error_outline, color: TWColor.red400)
                    : null,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                    color: AppColor.subtitle, fontSize: FontSizes.textBase),
              ),
            ),
          ),
        ),
        SizedBox(height: Spacing.sm),
        widget.hasError
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                child: Text(
                  widget.errorMessage!,
                  style: const TextStyle(
                      color: TWColor.red600, fontSize: FontSizes.textSm),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
