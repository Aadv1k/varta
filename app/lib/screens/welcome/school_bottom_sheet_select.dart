import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/common/styles.dart';
import 'package:app/models/school_model.dart';
import 'package:flutter/material.dart';

class SchoolBottomSheetSelect extends StatelessWidget {
  const SchoolBottomSheetSelect({
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height / 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md),
                          child: Text(
                            "Select School",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                                vertical: Spacing.md),
                            children: schools.map((school) {
                              bool isSelected = school == selectedSchool;
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                ),
                                enabled: !disabled,
                                onTap: !isSelected && !disabled
                                    ? () {
                                        onSelect(school);
                                        Navigator.pop(context);
                                      }
                                    : null,
                                tileColor: isSelected
                                    ? PaletteNeutral.shade400
                                    : Colors.transparent,
                                title: Text(
                                  school.schoolName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: PaletteNeutral.shade000),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: PaletteNeutral.shade000,
                                        size: IconSizes.iconMd,
                                      )
                                    : null,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          : null,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          height: AppSharedStyle.buttonHeight,
          constraints:
              const BoxConstraints(maxWidth: AppSharedStyle.maxButtonWidth),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
            color: AppColor.darkDropdownButtonBg,
            borderRadius: const BorderRadius.all(AppSharedStyle.buttonRadius),
            border: Border.all(
              color: AppColor.darkDropdownButtonAccent,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle:
                              disabled ? FontStyle.italic : FontStyle.normal,
                          color: disabled
                              ? AppColor.darkDropdownDisabledTextColor
                              : AppColor.darkDropdownTextColor,
                        )),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: IconSizes.iconLg,
                color: disabled
                    ? AppColor.darkDropdownDisabledTextColor
                    : AppColor.darkDropdownTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
