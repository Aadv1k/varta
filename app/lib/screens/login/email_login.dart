import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/login/otp_verification/otp_verification.dart';
import 'package:app/screens/login/phone_login.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/email_input.dart';
import 'package:flutter/material.dart';

class EmailLogin extends StatefulWidget {
  final UserLoginData userLoginData;

  const EmailLogin({super.key, required this.userLoginData});

  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  bool isLoading = false;
  bool hasError = false;
  String? email;
  String? errorMessage;

  void handleVerificationClick() {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    // Update user login data with email information

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OTPVerification(
                    userLoginData: widget.userLoginData.copyWith(
                  inputData: email,
                  inputType: LoginType
                      .email, // Assuming you have an enum or similar for LoginType
                ))));

    // // Simulate a network request or verification process
    // Timer(const Duration(seconds: 2), () {
    //   setState(() {
    //     hasError = true;
    //     errorMessage = "Unable to send the OTP due to an unknown error";
    //     isLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          elevation: 0,
          toolbarHeight: 72,
          title: Text(widget.userLoginData.schoolIDAndName!.$2,
              style: Theme.of(context).textTheme.displaySmall),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.chevron_left,
              color: TWColor.black,
              size: 32,
            ),
          ),
        ),
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
            Text(
              "Your Email",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: Spacing.md),
            SizedBox(
              width: 320,
              child: Text(
                "If you are registered with the school, we’ll send you an OTP to verify.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: Spacing.xxl),
            EmailInput(
              onInput: (e) {
                setState(() {
                  email = e;
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
                    builder: (context) => PhoneLogin(
                      userLoginData: widget.userLoginData,
                    ),
                  ),
                );
              },
              child: Text(
                "Use Phone Number Instead",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: TWColor.blue700),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: "Verify",
              onPressed: handleVerificationClick,
              isDisabled: email == null ||
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!),
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
