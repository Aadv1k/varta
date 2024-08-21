import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Map<String, String> organizations = {};
  String? selectedOrganizationID;

  void getListOfOrganizations() {}

  @override
  void initState() {
    // TODO: GET /api/v1/orgs

    setState(() {
      organizations = {
        "sri-chaitanya-techno-school-hyderabad":
            "Sri Chaitanya Techno School, Hyderabad",
        "dav-public-school-delhi": "DAV Public School, Delhi",
        "holy-cross-school-mumbai": "Holy Cross School, Mumbai",
        "st-josephs-convent-school-bangalore":
            "St. Joseph's Convent School, Bangalore",
        "kendriya-vidyalaya-chanakyapuri-delhi":
            "Kendriya Vidyalaya Chanakyapuri, Delhi",
      };

      selectedOrganizationID =
          organizations.isNotEmpty ? organizations.keys.first : null;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: Spacing.md),
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
              const SizedBox(),
              BottomSheetSelect(
                optionsKeyValue: organizations,
                selectedOptionKey: selectedOrganizationID,
                onSelect: (id) {
                  setState(() {
                    selectedOrganizationID = id;
                  });
                },
              ),
              const SizedBox(height: Spacing.sm),
              SizedBox(
                height: 80,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {},
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: const Text("Get Started",
                        style: TextStyle(
                            color: TWColor.black,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes.textBase))),
              )
            ],
          )),
    );
  }
}

class BottomSheetSelect extends StatelessWidget {
  const BottomSheetSelect({
    super.key,
    required this.onSelect,
    this.selectedOptionKey,
    required this.optionsKeyValue,
  });

  final Function onSelect;
  final String? selectedOptionKey;
  final Map<String, String> optionsKeyValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Spacing.lg, horizontal: Spacing.md),
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select School",
                        style: Theme.of(context).textTheme.headlineMedium),
                    Expanded(
                        child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                      children: optionsKeyValue.entries.map((elem) {
                        bool isSelected = elem.key == selectedOptionKey;
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: !isSelected
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
                              color: isSelected ? TWColor.white : TWColor.black,
                              fontSize: FontSizes.textBase,
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
              );
            });
      },
      child: Container(
          width: double.infinity,
          height: 80.0,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
              color: AppColors.darkDropdownButtonBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: AppColors.darkDropdownButtonAccent, width: 1.0)),
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
                        fontStyle: selectedOptionKey == null
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: selectedOptionKey == null
                            ? TWColor.zinc300
                            : TWColor.white,
                        fontSize: FontSizes.textBase,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none)),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 32,
                color: TWColor.zinc400,
              )
            ],
          )),
    );
  }
}
