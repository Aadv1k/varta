import 'dart:async';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/user.dart';
import 'package:app/screens/phone_login.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerification extends StatefulWidget {
  final UserLoginData userLoginData;

  const OTPVerification({Key? key, required this.userLoginData})
      : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  bool isLoading = false;
  bool hasError = false;
  String? OTP;
  String? errorMessage;
  bool canResend = true; // Button state
  Timer? resendTimer;
  int remainingTime = 0; // Time in seconds

  @override
  void dispose() {
    // Cancel the timer if it's active
    resendTimer?.cancel();
    super.dispose();
  }

  // Method to validate the OTP
  bool validateOtp(String otp) {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }

  // Method to handle OTP submission
  void handleVerificationClick() {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    if (validateOtp(OTP ?? "")) {
      print("OTP Verified");
      // Simulate a network request or verification process
      Timer(const Duration(seconds: 2), () {
        setState(() {
          hasError = true;
          errorMessage = "Unable to verify OTP due to an unknown error";
          isLoading = false;
        });
      });
    } else {
      setState(() {
        hasError = true;
        errorMessage = "Invalid OTP. Please enter a 6-digit number.";
        isLoading = false;
      });
    }
  }

  // Method to handle OTP resend
  void handleResendOtp() {
    if (!canResend) return;

    setState(() {
      canResend = false;
      remainingTime = 60; // Set initial countdown time (60 seconds)
    });

    // Simulate OTP resend process
    print("Resending OTP...");

    // Start a timer to count down every second
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          canResend = true;
        });
      }
    });
  }

  // Method to format time into MM:SS format
  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsLeft = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secondsLeft';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          elevation: 0,
          toolbarHeight: 72,
          title: Text(
            widget.userLoginData.schoolIDAndName!.$2,
            style: Theme.of(context).textTheme.displaySmall,
          ),
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
            SizedBox(
              width: 420,
              child: Text(
                "We sent an OTP to ${widget.userLoginData.inputData}, please verify that.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: Spacing.xxxl),
            OtpTextField(
              numberOfFields: 6,
              showFieldAsBox: false,
              focusedBorderColor: AppColors.primaryColor,
              borderColor: AppColors.body,
              cursorColor: AppColors.body,
              onCodeChanged: (String code) {
                // Update OTP as each code field changes
                setState(() {
                  OTP = code;
                });
              },
              onSubmit: (String verificationCode) {
                setState(() {
                  OTP = verificationCode;
                });
                handleVerificationClick();
              },
            ),
            const SizedBox(height: Spacing.lg),
            if (hasError && errorMessage != null) ...[
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: Spacing.md),
            ],
            TextButton(
              onPressed: !canResend ? null : handleResendOtp,
              child: Text(
                canResend
                    ? "Didn't receive? Resend"
                    : "Resend in ${formatTime(remainingTime)}",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.subtitle),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: "Verify",
              onPressed: handleVerificationClick,
              isDisabled: OTP == null || !validateOtp(OTP!),
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
