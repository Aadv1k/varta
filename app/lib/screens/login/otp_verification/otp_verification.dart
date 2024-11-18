import 'dart:async';
import 'dart:convert';

import 'package:app/common/colors.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/user_model.dart';
import 'package:app/repository/user_repo.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_inbox.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/services/simple_cache_service.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/screens/login/otp_verification/timed_text_button.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/error_text.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:app/widgets/varta_app_bar.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerification extends StatefulWidget {
  const OTPVerification({super.key});

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  bool validateOtp(String otp) {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }

  Future handleVerificationClick(BuildContext context) async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    final loginData = LoginProvider.of(context).state.data;

    try {
      await _authService.verifyOtp(loginData);

      UserModel user = await _userRepository.getUser();

      SimpleCacheService cacheService = SimpleCacheService();

      cacheService.store("user", jsonEncode(user.toJson()));

      final appState = await AppState.initialize(user: user);

      final notificationService = NotificationService();
      final settings = await notificationService.notificationSettings;

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        await notificationService.initNotifications(loginData.inputData!);
      }

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AppProvider(
                state: appState, child: const AnnouncementInboxScreen()),
          ),
          (_) => false);
    } catch (exc) {
      setState(() {
        hasError = true;
        errorMessage = exc is ApiException
            ? exc.message
            : "Something unexpected went wrong: $exc";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginData = LoginProvider.of(context).state.data;

    return Scaffold(
      backgroundColor: AppColor.primaryBg,
      appBar: VartaAppBar(
        title: loginData.schoolIDAndName!.$2,
        actions: const [],
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
                            text: loginData.inputData,
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
                listenable: LoginProvider.of(context).state,
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
                          .state
                          .setLoginData(loginData.copyWith(otp: code));
                    },
                    onSubmit: (String verificationCode) {
                      if (!validateOtp(verificationCode)) {
                        return;
                      }
                      LoginProvider.of(context).state.setLoginData(
                          loginData.copyWith(otp: verificationCode));
                      handleVerificationClick(context);
                    },
                  );
                }),
            const SizedBox(height: Spacing.md),
            if (hasError && errorMessage != null)
              SizedBox(
                  width: 320,
                  child: ErrorText(width: 320, text: errorMessage!)),
            const SizedBox(height: Spacing.sm),
            TimedTextButton(onPressed: () {
              handleVerificationClick(context);
            }),
            const Spacer(),
            VartaButton(
              variant: VartaButtonVariant.primary,
              size: VartaButtonSize.large,
              label: "Verify",
              fullWidth: true,
              onPressed: () => handleVerificationClick(context),
              isLoading: isLoading,
              // isDisabled: validateOtp(loginData.otp!) == false,
            )
          ],
        ),
      ),
    );
  }
}
