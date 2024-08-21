import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/email_login.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/phone_number_input.dart';
import 'package:flutter/material.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({Key? key, required (String, String) schoolSelection})
      : super(key: key);

  final (String, String) schoolSelection = ("", "");

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  bool isLoading = false;
  bool hasError = false;
  String? phoneNumber;
  String? errorMessage;

  void handleVerificationClick() {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        hasError = true;
        errorMessage = "Unable to send the OTP due to an unknown error";
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: AppBar(
              elevation: 0,
              toolbarHeight: 72,
              title: Text("hello world",
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(color: Colors.black)),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: TWColor.black,
                    size: 32,
                  ))),
        ),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
                top: Spacing.xxl,
                bottom: Spacing.lg,
                left: Spacing.xl,
                right: Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Your Phone",
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: Spacing.md),
                SizedBox(
                  width: 320,
                  child: Text(
                      "If you are registered with the school we’ll send you an OTP to verify",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: Spacing.xxl),
                PhoneNumberInput(
                  onInput: (e) {
                    setState(() {
                      phoneNumber = e;
                    });
                  },
                  hasError: hasError,
                  errorMessage: errorMessage,
                ),
                const SizedBox(height: Spacing.lg),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmailLogin(
                                  schoolSelection: widget.schoolSelection,
                                )),
                      );
                    },
                    child: Text("Use Email Instead",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: TWColor.blue700))),
                Spacer(),
                PrimaryButton(
                  text: "Verify",
                  onPressed: handleVerificationClick,
                  isDisabled: phoneNumber == null || phoneNumber!.length != 10,
                  isLoading: isLoading,
                )
              ],

              // phone number input, that also has error possibility
              // use email instead
            )));
  }
}
