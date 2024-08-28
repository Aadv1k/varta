import 'dart:developer';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/school_model.dart';
import 'package:app/providers/login_provider.dart';
import 'package:app/repository/school_repo.dart';
import 'package:app/screens/phone_login.dart';
import 'package:app/widgets/button.dart';
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
      setState(() {
        _schoolList = [
          SchoolModel(
            schoolId: 1,
            schoolName: "Delhi Public School",
            schoolAddress: "Sector 12, Dwarka, New Delhi, Delhi - 110078",
            schoolContactNo: "+91-11-23456789",
            schoolEmail: "info@dpsdwarka.edu.in",
          ),
          SchoolModel(
            schoolId: 2,
            schoolName: "St. Xavier's High School",
            schoolAddress: "5, Park Street, Kolkata, West Bengal - 700016",
            schoolContactNo: "+91-33-22345678",
            schoolEmail: "contact@stxavierskolkata.edu.in",
          ),
          SchoolModel(
            schoolId: 3,
            schoolName: "Rishi Valley School",
            schoolAddress:
                "Rishi Valley Post, Chittoor, Andhra Pradesh - 517352",
            schoolContactNo: "+91-8574-282003",
            schoolEmail: "info@rishivalley.org",
          ),
          SchoolModel(
            schoolId: 4,
            schoolName: "Bharatiya Vidya Bhavan",
            schoolAddress:
                "Bharatiya Vidya Bhavan, K. M. Munshi Marg, Mumbai, Maharashtra - 400007",
            schoolContactNo: "+91-22-23812345",
            schoolEmail: "admissions@bvbmumbai.edu.in",
          ),
        ];

        isLoading = false;
      });
    } catch (e) {
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
        color: AppColors.almostBlack,
        padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.screenHorizontalPadding,
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
                        ?.copyWith(color: AppColors.darkHeading)),
                const SizedBox(height: Spacing.lg),
                SizedBox(
                    width: 300,
                    child: Text(
                        "Stay on top of what's happening in your school",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.darkBody))),
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
                          disabled: false,
                          schools: _schoolList,
                          selectedSchool: _schoolList.firstWhere(
                              (school) =>
                                  school.schoolId.toString() ==
                                  loginState.data.schoolIDAndName?.$1,
                              orElse: () => throw AssertionError(
                                  "This should've been caught at the time of initialization")),
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
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                            color: TWColor.red500,
                            fontSize: FontSizes.textSm,
                            decoration: TextDecoration.none),
                      ),
                    ),
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

class BottomSheetSelect extends StatelessWidget {
  const BottomSheetSelect({
    super.key,
    required this.onSelect,
    this.selectedSchool,
    required this.schools,
    this.disabled = false,
  });

  final Function(SchoolModel) onSelect;
  final SchoolModel? selectedSchool;
  final List<SchoolModel> schools;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !disabled
          ? () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 2,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Select School",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                  vertical: Spacing.md),
                              children: schools.map((school) {
                                bool isSelected = school == selectedSchool;
                                return ListTile(
                                  minTileHeight: 72,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.lg),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  enabled: !disabled,
                                  onTap: !isSelected && !disabled
                                      ? () {
                                          onSelect(school);
                                          Navigator.pop(context);
                                        }
                                      : null,
                                  tileColor: isSelected
                                      ? AppColors.primaryColor.withOpacity(0.10)
                                      : Colors.transparent,
                                  title: Text(
                                    school.schoolName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.heading,
                                      fontSize: FontSizes.textBase,
                                      fontStyle: disabled
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    school.schoolAddress,
                                    style: TextStyle(
                                      fontSize: FontSizes.textSm,
                                      color: AppColors.body,
                                      fontStyle: disabled
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primaryColor,
                                        )
                                      : null,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          : null,
      child: Opacity(
        opacity: disabled ? 0.6 : 1.0,
        child: Container(
          width: double.infinity,
          height: AppStyles.buttonHeight,
          constraints: const BoxConstraints(maxWidth: AppStyles.maxButtonWidth),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
            color: AppColors.darkDropdownButtonBg,
            borderRadius: const BorderRadius.all(AppStyles.buttonRadius),
            border: Border.all(
              color: AppColors.darkDropdownButtonAccent,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedSchool == null
                      ? "Select a School"
                      : selectedSchool!.schoolName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: disabled ? FontStyle.italic : FontStyle.normal,
                    color: disabled
                        ? AppColors.darkDropdownDisabledTextColor
                        : AppColors.darkDropdownTextColor,
                    fontSize: FontSizes.textBase,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 32,
                color: disabled
                    ? AppColors.darkDropdownDisabledTextColor
                    : AppColors.darkDropdownTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
