import 'dart:convert';

import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/services/common.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/user_login_provider.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Map<String, String> organizations = {};
  bool isLoading = true;
  String? errorMessage;

  void fetchSchoolList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http
          .get(Uri.http(BASE_API_URL, apiEndpoints[ApiEndpoint.schools]!));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          organizations.clear();
          for (final dynamic schoolData in data['data'] as List) {
            organizations[schoolData['id'].toString()] =
                schoolData['name'] as String;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load schools');
      }
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
    final userLoginService = UserLoginProvider.of(context).userLoginService;

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
                      listenable: userLoginService,
                      builder: (context, child) {
                        return BottomSheetSelect(
                          optionsKeyValue: organizations,
                          selectedOptionKey:
                              userLoginService.loginData.schoolIDAndName?.$1,
                          onSelect: (id) {
                            userLoginService.setLoginData(
                                userLoginService.loginData.copyWith(
                                    schoolIDAndName: (id, organizations[id]!)));
                          },
                          disabled: organizations.isEmpty ||
                              organizations.length == 1,
                        );
                      }),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: TWColor.red600,
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PhoneLogin(
                            //       userLoginData: UserLoginData(
                            //         schoolIDAndName: (
                            //           selectedOrganizationID!,
                            //           organizations[selectedOrganizationID]!
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // );
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
          : null, // Disable tap if disabled
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
