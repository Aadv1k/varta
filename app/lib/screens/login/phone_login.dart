import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/login_data.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/screens/login/otp_verification/otp_verification.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/state/login_state.dart';
import 'package:app/screens/login/phone_number_input.dart';
import 'package:app/widgets/varta_app_bar.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:flutter/material.dart';

bool isPhoneNumberValid(String phoneNumber) {
  if (!phoneNumber.startsWith('+')) {
    return false;
  }

  String numericPart = phoneNumber.substring(1);

  if (!RegExp(r'^\d+$').hasMatch(numericPart)) {
    return false;
  }

  if (numericPart.length < 8 || numericPart.length > 15) {
    return false;
  }

  return true;
}

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  _PhoneLoginState createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  final AuthService _authService = AuthService();

  Future<void> handleVerificationClick(
      BuildContext context, LoginState loginState) async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      final loginData = LoginProvider.of(context).state.data;
      await _authService.sendOtp(loginData);
    } catch (exc) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = exc is ApiException
            ? exc.message
            : "Something went wrong. Please check your connection and try again later.";
      });
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginProvider(
                  state: loginState, child: const OTPVerification())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = LoginProvider.of(context).state;
    final shouldBeCompact = MediaQuery.of(context).size.height <= 380;

    final contentGap = shouldBeCompact ? Spacing.md : Spacing.xl;
    final headingStyle = shouldBeCompact
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.headlineLarge;

    return Scaffold(
        backgroundColor: AppColor.primaryBg,
        appBar: VartaAppBar(
            actions: const [],
            centerTitle: true,
            title: loginState.data.schoolIDAndName!.$2),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
                top: Spacing.md,
                bottom: Spacing.md,
                left: Spacing.xl,
                right: Spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Your Phone", style: headingStyle),
                SizedBox(height: contentGap),
                SizedBox(
                  width: 320,
                  child: Text(
                      "If you are registered with the school we’ll send you an OTP to verify",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                SizedBox(height: contentGap),
                ListenableBuilder(
                  listenable: loginState,
                  builder: (context, child) => PhoneNumberInput(
                    onInput: (e) {
                      loginState.setLoginData(loginState.data.copyWith(
                          inputType: LoginType.phoneNumber, inputData: e));
                    },
                    hasError: hasError,
                    errorMessage: errorMessage,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                TextButton(
                    onPressed: () {},
                    child: Text("Use Email Instead",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: TWColor.blue600))),
                const Spacer(),
                ListenableBuilder(
                  listenable: loginState,
                  builder: (context, child) => VartaButton(
                    variant: VartaButtonVariant.primary,
                    size: VartaButtonSize.large,
                    label: "Verify",
                    fullWidth: true,
                    onPressed: () =>
                        handleVerificationClick(context, loginState),
                    isLoading: isLoading,
                    isDisabled: loginState.data.inputData == null ||
                        isPhoneNumberValid(loginState.data.inputData!) == false,
                  ),
                )
              ],
            )));
  }
}
