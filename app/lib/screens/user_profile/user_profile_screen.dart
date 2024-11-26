import 'dart:convert';
import 'dart:io';

import 'package:app/common/colors.dart';
import 'package:app/common/download.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/user_model.dart';
import 'package:app/screens/user_profile/teacher_card.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/generic_confirmaton_dialog.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:app/widgets/varta_app_bar.dart';
import 'package:app/widgets/varta_button.dart';
import 'package:flutter/foundation.dart';
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
    Uint8List? rawImage = await _screenshotController.capture(
      delay: const Duration(milliseconds: 100),
    );

    if (rawImage == null) {
      return;
    }

    if (kIsWeb &&
        !(defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      download(
          "data:image/png;base64,${base64Encode(rawImage)}", "varta-card.png");
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final tempFilePath = "${tempDir.path}/temp_${const Uuid().v4()}.png";
    final tempFile = File(tempFilePath);

    await tempFile.writeAsBytes(rawImage);

    await Share.shareXFiles([XFile(tempFilePath)]);

    await tempFile.delete();
  }

  void _handleLogout(BuildContext parentContext) {
    showDialog(
        context: parentContext,
        builder: (context) => GenericConfirmationDialog(
            title: "Are you sure you want to Log Out?",
            body:
                'You’ll be signed out of your account. Any unsaved progress may be lost.  Would you like to continue?',
            primaryAction: GenericConfirmatonDialogAction.confirm,
            onCancel: () => Navigator.pop(context),
            onConfirm: () async {
              AppProvider.of(parentContext).logout();
              clearAndNavigateBackToLogin(context);
            },
            cancelLabel: "Cancel",
            confirmLabel: "Log Out",
            danger: true));
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = AppProvider.of(context).state;
    bool isTeacher = appState.user?.userType == UserType.teacher;

    bool isMobileWeb = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);

    return Scaffold(
      appBar: const VartaAppBar(
        actions: [],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.only(
              left: Spacing.md, right: Spacing.md, bottom: Spacing.md),
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
                  if (!isMobileWeb)
                    IconButton.filled(
                        highlightColor: PaletteNeutral.shade050,
                        style: IconButton.styleFrom(
                            backgroundColor: AppColor.inactiveChipBg,
                            fixedSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                        icon: const Icon(
                            kIsWeb ? Icons.download : Icons.ios_share,
                            size: IconSizes.iconMd,
                            color: AppColor.inactiveChipFg),
                        onPressed: () {
                          _handleShareButtonPressed();
                        }),
                  const SizedBox(width: Spacing.sm),
                ],
              ),
              const Spacer(),
              const SizedBox(height: Spacing.sm),
              VartaButton(
                variant: VartaButtonVariant.error,
                label: "Log Out",
                onPressed: () => _handleLogout(context),
                fullWidth: true,
              ),
              const SizedBox(height: Spacing.md),
              Text("Made with ❤️ by Aadvik Pandey\n<github.com/aadv1k>",
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
