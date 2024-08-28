import 'dart:developer';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
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
  Map<String, String> organizations = {};
  bool isLoading = true;
  String? errorMessage;

  late final SchoolRepository _schoolRepository = SchoolRepository();

  void fetchSchoolList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final schools = await _schoolRepository.getSchools();

      setState(() {
        if (schools.isEmpty) {
          errorMessage = "API didn't send any schools. This should not happen.";
          isLoading = false;
          return;
        }

        for (var school in schools) {
          organizations[school.schoolId.toString()] = school.schoolName;
        }
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

    if (organizations.isNotEmpty && loginState.data.schoolIDAndName == null) {
      loginState.setLoginData(loginState.data.copyWith(schoolIDAndName: (
        organizations.keys.first,
        organizations.values.first
      )));
    }

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl, vertical: Spacing.xl),
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
                          disabled: organizations.isEmpty,
                          optionsKeyValue: organizations,
                          selectedOptionKey:
                              loginState.data.schoolIDAndName?.$1,
                          onSelect: (id) {
                            loginState.setLoginData(loginState.data.copyWith(
                                schoolIDAndName: (id, organizations[id]!)));
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
                    isDisabled: organizations.isEmpty || errorMessage != null,
                    onPressed: organizations.isNotEmpty && errorMessage == null
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
    this.selectedOptionKey,
    required this.optionsKeyValue,
    this.disabled = false,
  });

  final Function onSelect;
  final String? selectedOptionKey;
  final Map<String, String> optionsKeyValue;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !disabled
          ? () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Select School",
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              children: optionsKeyValue.entries.map((elem) {
                                bool isSelected = elem.key == selectedOptionKey;
                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabled: !disabled,
                                  onTap: !isSelected && !disabled
                                      ? () {
                                          onSelect(elem.key);
                                          Navigator.pop(context);
                                        }
                                      : null,
                                  tileColor: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  title: Text(
                                    elem.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: isSelected
                                          ? TWColor.white
                                          : (disabled
                                              ? TWColor.zinc300.withOpacity(0.5)
                                              : TWColor.black),
                                      fontSize: FontSizes.textBase,
                                      fontStyle: disabled
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
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
          height: AppStyles.buttonHeight + 2.5,
          constraints: const BoxConstraints(maxWidth: AppStyles.maxButtonWidth),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
            color: AppColors.darkDropdownButtonBg,
            borderRadius: BorderRadius.circular(999),
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
                  selectedOptionKey == null
                      ? "Select a School"
                      : optionsKeyValue[selectedOptionKey]!,
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
