import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/widgets/error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneNumberInput extends StatefulWidget {
  final Function(String) onInput;
  final bool hasError;
  final String? errorMessage;

  const PhoneNumberInput({
    super.key,
    required this.onInput,
    required this.hasError,
    this.errorMessage,
  });

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  late FocusNode _focusNode;
  final phoneNumberInputController = TextEditingController();
  bool isFocused = false;
  String phoneNumber = "";

  var maskFormatter = MaskTextInputFormatter(
    mask: "##### #####",
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void _handleInputChange() {
    widget.onInput(maskFormatter.getUnmaskedText());
    setState(() {
      phoneNumber = phoneNumberInputController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    phoneNumberInputController.addListener(_handleInputChange);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    phoneNumberInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderAccent =
        widget.hasError ? AppColor.dangerBody : AppColor.subtitleLighter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 380,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: borderAccent,
              width: 1,
            )),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Center(
                  child: Text(
                    "+91",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColor.subtitle),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              VerticalDivider(width: 4, color: borderAccent),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: Spacing.md),
                  child: Center(
                    child: TextField(
                        autocorrect: true,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.phone,
                        controller: phoneNumberInputController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(11),
                          maskFormatter,
                        ],
                        style: const TextStyle(color: AppColor.heading),
                        decoration: InputDecoration(
                          hintText: "Phone Number",
                          suffixIcon: widget.hasError
                              ? const Icon(Icons.error_outline,
                                  color: AppColor.dangerBody)
                              : null,
                          border: InputBorder.none,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColor.subtitle),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        widget.hasError
            ? SizedBox(
                width: 380,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    child: ErrorText(text: widget.errorMessage!)),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
