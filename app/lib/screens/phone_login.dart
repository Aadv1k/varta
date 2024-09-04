import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/login_data.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/screens/otp_verification/otp_verification.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/basic_app_bar.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/phone_number_input.dart';
import 'package:flutter/material.dart';

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

  Future<void> handleVerificationClick(context) async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    // try {
    //   final loginData = LoginProvider.of(context).loginState.data;
    //   await _authService.sendOtp(loginData);
    // } on ApiClientException catch (_) {
    //   setState(() {
    //     isLoading = false;
    //     hasError = true;
    //     errorMessage = "Unable to connect at this moment. Try again later. ";
    //   });
    // } on ApiException catch (exc) {
    //   setState(() {
    //     isLoading = false;
    //     hasError = true;
    //     errorMessage = exc.message;
    //   });
    // }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginProvider(
                loginState: LoginProvider.of(context).loginState,
                child: const OTPVerification())));
  }

  @override
  Widget build(BuildContext context) {
    final loginState = LoginProvider.of(context).loginState;

    return Scaffold(
        backgroundColor: AppColor.primaryBg,
        appBar: BasicAppBar(title: loginState.data.schoolIDAndName!.$2),
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
                const SizedBox(height: Spacing.lg),
                TextButton(
                    onPressed: () {},
                    child: Text("Use Email Instead",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: TWColor.blue700))),
                const Spacer(),
                ListenableBuilder(
                    listenable: loginState,
                    builder: (context, child) => PrimaryButton(
                          text: "Verify",
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginProvider(
                                      loginState: loginState,
                                      child: const OTPVerification()))),
                          // handleVerificationClick(context),
                          isDisabled: loginState.data.inputData == null ||
                              loginState.data.inputData!.length != 10,
                          isLoading: isLoading,
                        ))
              ],
            )));
  }
}
