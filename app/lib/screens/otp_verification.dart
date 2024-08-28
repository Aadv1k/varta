import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/login_data.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerification extends StatefulWidget {
  const OTPVerification({Key? key}) : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  final AuthService _authService = AuthService();

  bool validateOtp(String otp) {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }

  Future handleVerificationClick(BuildContext context) async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    final loginData = LoginProvider.of(context).loginState.data;

    try {
      await _authService.sendOtp(loginData);
    } on ApiException catch (e) {
      // some kind of bad resposne has been thrown
    } on ApiClientException catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.message;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginData = LoginProvider.of(context).loginState.data;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
            elevation: 0,
            toolbarHeight: 72,
            title: Text(loginData.schoolIDAndName!.$2,
                style: Theme.of(context).textTheme.headlineMedium),
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
          right: Spacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 420,
              child: Text(
                "Verification Code",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: 280,
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "We sent a 6-digit verification code sent to ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                            text: loginData.inputData,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColors.heading,
                                    fontWeight: FontWeight.bold))
                      ])),
            ),
            const SizedBox(height: Spacing.xxl),
            ListenableBuilder(
                listenable: LoginProvider.of(context).loginState,
                builder: (context, child) {
                  return OtpTextField(
                    numberOfFields: 6,
                    showFieldAsBox: false,
                    focusedBorderColor: AppColors.primaryColor,
                    borderColor: AppColors.body,
                    cursorColor: AppColors.body,
                    onCodeChanged: (String code) {
                      // Update OTP as each code field changes
                      LoginProvider.of(context)
                          .loginState
                          .setLoginData(loginData.copyWith(otp: code));
                    },
                    onSubmit: (String verificationCode) {
                      if (!validateOtp(verificationCode)) {
                        return;
                      }
                      LoginProvider.of(context).loginState.setLoginData(
                          loginData.copyWith(otp: verificationCode));
                      handleVerificationClick(context);
                    },
                  );
                }),
            const SizedBox(height: Spacing.md),
            if (hasError && errorMessage != null) ...[
              SizedBox(
                width: 320,
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: TWColor.red700),
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
            TimedTextButton(onPressed: () {
              handleVerificationClick(context);
            }),
            const Spacer(),
            PrimaryButton(
              text: "Verify",
              onPressed: () => handleVerificationClick(context),
              isDisabled: true,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

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
            ?.copyWith(color: AppColors.subtitle),
      ),
    );
  }
}
