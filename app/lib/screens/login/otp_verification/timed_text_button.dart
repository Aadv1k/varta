import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:flutter/material.dart';

class TimedTextButton extends StatefulWidget {
  final VoidCallback onPressed;

  const TimedTextButton({super.key, required this.onPressed});

  @override
  _TimedTextButtonState createState() => _TimedTextButtonState();
}

class _TimedTextButtonState extends State<TimedTextButton> {
  bool isDisabled = false;

  Timer? buttonEnabledTimer;
  int timeLeftInSeconds = 60;

  void handleButtonPress() {
    setState(() {
      isDisabled = true;
    });

    buttonEnabledTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timeLeftInSeconds > 0) {
        setState(() {
          timeLeftInSeconds--;
        });
        return;
      }
      timer.cancel();
      setState(() {
        timeLeftInSeconds = 60;
        isDisabled = false;
      });
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isDisabled ? null : handleButtonPress,
      child: Text(
        "Didn't receive? ${!isDisabled ? 'Resend' : 'Resend in $timeLeftInSeconds'}",
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColor.subtitle),
      ),
    );
  }
}
