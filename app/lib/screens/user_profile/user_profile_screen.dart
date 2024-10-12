import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/user_model.dart';
import 'package:app/screens/user_profile/teacher_card.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/providers/app_provider.dart';
import 'package:app/widgets/state/app_state.dart';
import 'package:flutter/material.dart';

import 'package:app/screens/user_profile/user_card.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) {
    AuthService().logout();
    AppProvider.of(context).logout();
    clearAndNavigateBackToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = AppProvider.of(context).state;

    bool isTeacher = false;
    //appState.user?.userType == UserType.teacher;

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
      body: Container(
        padding: const EdgeInsets.only(
            left: Spacing.md, right: Spacing.md, bottom: Spacing.md),
        child: Column(
          children: [
            if (appState.user != null)
              isTeacher
                  ? const TeacherCard()
                  : StudentCard(user: appState.user!),
            const SizedBox(height: Spacing.sm),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              // IconButton.filled(
              //     style: IconButton.styleFrom(
              //         backgroundColor: AppColor.inactiveChipBg,
              //         fixedSize: const Size(48, 48),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         )),
              //     icon: const Icon(Icons.edit,
              //         size: IconSizes.iconMd, color: AppColor.inactiveChipFg),
              //     onPressed: () {
              //       debugPrint("Hello there little one");
              //     }),
              const SizedBox(width: Spacing.sm),
              IconButton.filled(
                  style: IconButton.styleFrom(
                      backgroundColor: AppColor.inactiveChipBg,
                      fixedSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                  icon: const Icon(Icons.ios_share,
                      size: IconSizes.iconMd, color: AppColor.inactiveChipFg),
                  onPressed: () {
                    debugPrint("Hello there little one");
                  }),
              const SizedBox(width: Spacing.sm),
            ]),
            // DataTable(columns: const [
            //   DataColumn(label: Text("Contact")),
            //   DataColumn(label: Text("Type")),
            // ], rows: const [
            //   DataRow(cells: [
            //     DataCell(Text("+91 0000000000")),
            //     DataCell(Text("Secondary Phone")),
            //   ]),
            //   DataRow(cells: [
            //     DataCell(Text("example@example.com")),
            //     DataCell(Text("Secondary Email")),
            //   ]),
            // ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.feedback,
                    color: AppColor.inactiveChipFg, size: IconSizes.iconMd),
                onPressed: () {},
                style: TextButton.styleFrom(
                    foregroundColor: AppColor.inactiveChipFg,
                    backgroundColor: AppColor.inactiveChipBg,
                    fixedSize: const Size.fromHeight(54)),
                label: Text("Send Feedback",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColor.inactiveChipFg,
                        )),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _handleLogout(context),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade600),
                    fixedSize: const Size.fromHeight(54)),
                child: Text("Log Out",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.red.shade600,
                        )),
              ),
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
    );
  }
}
