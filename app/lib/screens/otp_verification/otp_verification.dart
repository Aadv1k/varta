import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/login_data.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/screens/announcement_inbox/mobile/home_screen.dart';
import 'package:app/screens/otp_verification/timed_text_button.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/basic_app_bar.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/error_text.dart';
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
      // await _authService.sendOtp(loginData);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    } on ApiException catch (exc) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = exc.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginData = LoginProvider.of(context).loginState.data;

    return Scaffold(
      backgroundColor: AppColor.primaryBg,
      appBar: BasicAppBar(
        title: loginData.schoolIDAndName!.$2,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          top: Spacing.xl,
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
                      text: "We sent a 6-digit verification code to ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                            text:
                                "${loginData.inputType == LoginType.email ? '' : '+91 '}${loginData.inputData}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: AppColor.heading,
                                    fontWeight: FontWeight.bold))
                      ])),
            ),
            const SizedBox(height: Spacing.lg),
            ListenableBuilder(
                listenable: LoginProvider.of(context).loginState,
                builder: (context, child) {
                  return OtpTextField(
                    numberOfFields: 6,
                    textStyle: const TextStyle(
                      fontSize: FontSize.textLg,
                      color: AppColor.heading,
                    ),
                    showFieldAsBox: false,
                    focusedBorderColor: AppColor.primaryColor,
                    borderColor: AppColor.body,
                    cursorColor: AppColor.body,
                    onCodeChanged: (String code) {
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
            if (hasError && errorMessage != null)
              SizedBox(width: 280, child: ErrorText(text: errorMessage!)),
            const SizedBox(height: Spacing.sm),
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
