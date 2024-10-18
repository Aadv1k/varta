import 'package:app/common/colors.dart';
import 'package:app/common/exceptions.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/school_model.dart';
import 'package:app/screens/login/email_login.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/repository/school_repository.dart';
import 'package:app/screens/login/phone_login.dart';
import 'package:app/screens/welcome/school_bottom_sheet_select.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<SchoolModel> _schoolList = [];
  bool isLoading = true;
  String? errorMessage;

  final SchoolRepository _schoolRepository = SchoolRepository();

  void fetchSchoolList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await _schoolRepository.getSchools();
      setState(() {
        _schoolList = data;
        isLoading = false;
      });
    } catch (e) {
      if (e is ApiException) {
        setState(() {
          errorMessage = e.message;
          isLoading = false;
        });
        return;
      }
      setState(() {
        errorMessage = 'Failed to load schools. Please try again later.';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSchoolList();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = LoginProvider.of(context).state;

    /* This is a comfort feature. Since for an unknown amount of duration the app
     * will likely only have a single school, so we make it so the ID is
     * automatically picked up */
    if (_schoolList.isNotEmpty && loginState.data.schoolIDAndName == null) {
      loginState.setLoginData(loginState.data.copyWith(schoolIDAndName: (
        _schoolList.first.schoolId.toString(),
        _schoolList.first.schoolName
      )));
    }

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: AppColor.almostBlack,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSharedStyle.screenHorizontalPadding,
            vertical: Spacing.xl),
        child: Column(
          children: [
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Varta",
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: AppColor.darkHeading)),
                const SizedBox(height: Spacing.lg),
                SizedBox(
                    width: 380,
                    child: Text(
                        "Never miss another update from your school again.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColor.darkBody))),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                ListenableBuilder(
                    listenable: loginState,
                    builder: (context, child) {
                      return SchoolBottomSheetSelect(
                        disabled: isLoading || _schoolList.isEmpty,
                        schools: isLoading ? [] : _schoolList,
                        selectedSchool:
                            _schoolList.isNotEmpty ? _schoolList.first : null,
                        onSelect: (school) {
                          loginState.setLoginData(loginState.data.copyWith(
                              schoolIDAndName: (
                                school.schoolId.toString(),
                                school.schoolName
                              )));
                        },
                      );
                    }),
                if (errorMessage != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                      child: ErrorText(text: errorMessage!, center: true)),
                const SizedBox(height: Spacing.sm),
                PrimaryButton(
                  text: "Get Started",
                  isDisabled: errorMessage != null,
                  onPressed: _schoolList.isNotEmpty && errorMessage == null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginProvider(
                                  state: loginState, child: const EmailLogin()),
                            ),
                          );
                        }
                      : null,
                  isLight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
