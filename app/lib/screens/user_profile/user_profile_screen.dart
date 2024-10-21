import 'dart:io';
import 'dart:typed_data';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/user_model.dart';
import 'package:app/screens/user_profile/teacher_card.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:flutter/material.dart';

import 'package:app/screens/user_profile/user_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class UserProfileScreen extends StatelessWidget {
  final ScreenshotController _screenshotController = ScreenshotController();

  UserProfileScreen({super.key});

  Future<void> _handleShareButtonPressed() async {
    // TODO: weird case where the rawImage is null
    Uint8List? rawImage = await _screenshotController.capture(
      delay: const Duration(milliseconds: 100),
      pixelRatio: 3,
    );

    if (rawImage == null) {
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final tempFilePath = "${tempDir.path}/temp_${const Uuid().v4()}.png";
    final tempFile = File(tempFilePath);

    await tempFile.writeAsBytes(rawImage);

    await Share.shareXFiles([XFile(tempFilePath)]);
  }

  void _handleLogout(BuildContext context) {
    AuthService().logout();
    AppProvider.of(context).logout();
    clearAndNavigateBackToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = AppProvider.of(context).state;
    bool isTeacher = appState.user?.userType == UserType.teacher;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.primaryBg,
        toolbarHeight: 48,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: Spacing.sm),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.chevron_left,
                  color: AppColor.body, size: IconSizes.iconMd)),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.only(
              left: Spacing.sm, right: Spacing.sm, bottom: Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (appState.user != null)
                Screenshot(
                  controller: _screenshotController,
                  child: isTeacher
                      ? TeacherCard(user: appState.user!)
                      : StudentCard(user: appState.user!),
                ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: Spacing.sm),
                  IconButton.filled(
                      // splashColor: PaletteNeutral.shade100,
                      highlightColor: PaletteNeutral.shade050,
                      style: IconButton.styleFrom(
                          backgroundColor: AppColor.inactiveChipBg,
                          fixedSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )),
                      icon: const Icon(Icons.ios_share,
                          size: IconSizes.iconMd,
                          color: AppColor.inactiveChipFg),
                      onPressed: () {
                        _handleShareButtonPressed();
                      }),
                  const SizedBox(width: Spacing.sm),
                ],
              ),
              const Spacer(),
              const VartaButton(
                variant: VartaButtonVariant.secondary,
                label: "Send Feedback",
                fullWidth: true,
                leadingIcon: Icon(Icons.feedback,
                    color: AppColor.inactiveChipFg, size: IconSizes.iconMd),
              ),
              const SizedBox(height: Spacing.sm),
              VartaButton(
                variant: VartaButtonVariant.error,
                label: "Log Out",
                onPressed: () => _handleLogout(context),
                fullWidth: true,
              ),
              const SizedBox(height: Spacing.md),
              Text("Made with ❤️ by Aadv1k\n<github.com/aadv1k>",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontFamily: "GeistMono")),
            ],
          ),
        ),
      ),
    );
  }
}
