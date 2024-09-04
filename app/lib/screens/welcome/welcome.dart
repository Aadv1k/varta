import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/school_model.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/repository/school_repo.dart';
import 'package:app/screens/phone_login.dart';
import 'package:app/screens/welcome/bottom_sheet_select.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/error_text.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<SchoolModel> _schoolList = [];
  bool isLoading = true;
  String? errorMessage;

  late final SchoolRepository _schoolRepository = SchoolRepository();

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
      setState(() {
        // errorMessage = 'Failed to load schools. Please try again later.';
        _schoolList = [
          SchoolModel(
              schoolId: 69420,
              schoolName: "Test Public School",
              schoolAddress: "Random baker street",
              schoolContactNo: "",
              schoolEmail: "")
        ];
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
    final loginState = LoginProvider.of(context).loginState;

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
                        "Stay on top of all that's happening in your school",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColor.darkBody))),
              ],
            ),
            const Spacer(),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ListenableBuilder(
                      listenable: loginState,
                      builder: (context, child) {
                        return BottomSheetSelect(
                          disabled: _schoolList.isEmpty,
                          schools: _schoolList,
                          selectedSchool: _schoolList.isNotEmpty
                              ? _schoolList.firstWhere(
                                  (school) =>
                                      school.schoolId.toString() ==
                                      loginState.data.schoolIDAndName?.$1,
                                  orElse: () => throw AssertionError(
                                      "This should've been caught at the time of initialization"))
                              : null,
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
                        padding:
                            const EdgeInsets.symmetric(vertical: Spacing.sm),
                        child: ErrorText(text: errorMessage!)),
                  const SizedBox(height: Spacing.sm),
                  PrimaryButton(
                    text: "Get Started",
                    isDisabled: _schoolList.isEmpty || errorMessage != null,
                    onPressed: _schoolList.isNotEmpty && errorMessage == null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginProvider(
                                    loginState: loginState,
                                    child: const PhoneLogin()),
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
