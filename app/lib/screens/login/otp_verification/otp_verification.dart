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
import 'package:app/widgets/error_snackbar.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/screens/login/otp_verification/timed_text_button.dart';
import 'package:app/services/auth_service.dart';
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
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  bool validateOtp(String otp) {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }

  Future handleVerificationClick(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    final loginData = LoginProvider.of(context).state.data;

    try {
      await _authService.verifyOtp(loginData);

      UserModel user = await _userRepository.getUser();

      SimpleCacheService cacheService = SimpleCacheService();

      cacheService.store("user", jsonEncode(user.toJson()));

      final appState = await AppState.initialize(user: user);

      try {
        final notificationService = NotificationService();

        final settings = await notificationService.firebaseMessaging
            .getNotificationSettings();

        if ({AuthorizationStatus.notDetermined, AuthorizationStatus.denied}
            .contains(settings.authorizationStatus)) {
          await notificationService.initNotifications(loginData.inputData!);
        }
      } catch (_) {
        const VartaSnackbar(
          innerText: "Couldn't initialize notifications.",
          snackBarVariant: VartaSnackBarVariant.warning,
        ).show(context);
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
        _hasError = true;
        _errorMessage = exc is ApiException
            ? exc.message
            : "Something unexpected went wrong: $exc";
      });
    } finally {
      setState(() => _isLoading = false);
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
        padding: const EdgeInsets.symmetric(
            vertical: Spacing.lg, horizontal: Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 420,
              child: Text(
                "Verification Code",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: Spacing.sm),
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
                    autoFocus: true,
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
            const SizedBox(height: Spacing.sm),
            if (_hasError && _errorMessage != null)
              SizedBox(
                width: 380,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Spacing.xs, horizontal: Spacing.md),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error,
                            color: TWColor.red600, size: IconSizes.iconSm),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: SizedBox(
                              child: Text(_errorMessage!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: TWColor.red600,
                                      ))),
                        ),
                      ]),
                ),
              ),
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
              isLoading: _isLoading,
            )
          ],
        ),
      ),
    );
  }
}
