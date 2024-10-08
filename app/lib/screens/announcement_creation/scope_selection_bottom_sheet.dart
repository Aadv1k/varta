import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/data/dropdown_classroom_standard.dart';
import 'package:app/data/dropdown_classroom_standard_division.dart';
import 'package:app/data/dropdown_departments.dart';
import 'package:app/models/search_data.dart';
import 'package:app/widgets/varta_checkbox.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/common/utils.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/widgets/button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ScopeSelectionBottomSheet extends StatefulWidget {
  final Function(ScopeSelectionData scope) onCreated;

  const ScopeSelectionBottomSheet({super.key, required this.onCreated});

  @override
  _ScopeSelectionBottomSheetState createState() =>
      _ScopeSelectionBottomSheetState();
}

enum ScopeContext { student, teacher, everyone }

enum GenericFilterType {
  standard("Standard", "standard"),
  standardDivision("Standard Division", "standard_division"),
  department("Department", "department"),
  all("All", "all");

  const GenericFilterType(this.label, this.value);
  final String label;
  final String value;
}

class ScopeSelectionData {
  final ScopeContext scopeType;
  final GenericFilterType scopeFilterType;
  final String scopeFilterData;
  final bool? isClassTeacher;
  final bool? isSubjectTeacher;

  ScopeSelectionData({
    required this.scopeType,
    required this.scopeFilterType,
    required this.scopeFilterData,
    this.isClassTeacher,
    this.isSubjectTeacher,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScopeSelectionData &&
          runtimeType == other.runtimeType &&
          scopeType == other.scopeType &&
          scopeFilterType == other.scopeFilterType &&
          scopeFilterData == other.scopeFilterData &&
          isClassTeacher == other.isClassTeacher &&
          isSubjectTeacher == other.isSubjectTeacher;

  @override
  int get hashCode =>
      scopeType.hashCode ^
      scopeFilterType.hashCode ^
      scopeFilterData.hashCode ^
      isClassTeacher.hashCode ^
      isSubjectTeacher.hashCode;

  ScopeSelectionData copyWith({
    ScopeContext? scopeContext,
    GenericFilterType? scopeFilterType,
    String? scopeFilterData,
    bool? isClassTeacher,
    bool? isSubjectTeacher,
  }) {
    return ScopeSelectionData(
      scopeType: scopeContext ?? scopeType,
      scopeFilterType: scopeFilterType ?? this.scopeFilterType,
      scopeFilterData: scopeFilterData ?? this.scopeFilterData,
      isClassTeacher: isClassTeacher ?? this.isClassTeacher,
      isSubjectTeacher: isSubjectTeacher ?? this.isSubjectTeacher,
    );
  }

  String getUserFriendlyLabel() {
    switch (scopeType) {
      case ScopeContext.student:
        return switch (scopeFilterType) {
          GenericFilterType.standard => "${scopeFilterData}th Grade",
          GenericFilterType.standardDivision => "Class ${scopeFilterData}",
          GenericFilterType.all => "All Students",
          _ => throw AssertionError("Invalid filter type for students"),
        };
      case ScopeContext.teacher:
        return switch (scopeFilterType) {
          GenericFilterType.standard when isSubjectTeacher == true =>
            "${scopeFilterData}th Grade Teachers",
          GenericFilterType.standardDivision when isClassTeacher == true =>
            "Class ${scopeFilterData} Teacher",
          GenericFilterType.standardDivision =>
            "Class ${scopeFilterData} Teachers",
          GenericFilterType.department => "${scopeFilterData} Dept",
          GenericFilterType.all => "All Teachers",
          _ => throw AssertionError("Invalid filter type for teachers"),
        };
      case ScopeContext.everyone:
        return "Everyone";
    }
  }

  AnnouncementScope toAnnouncementScope() {
    var filterType = "";

    if (scopeType == ScopeContext.student) {
      filterType = switch (scopeFilterType) {
        GenericFilterType.standard => "stu_standard",
        GenericFilterType.standardDivision => "stu_standard_division",
        GenericFilterType.all => "stu_all",
        GenericFilterType.department => throw AssertionError(
            "A selection of GenericFilterType.department should not be possible when scopeType is ScopeContext.student, this is likely a bug in bottom-sheet selection logic")
      };
    } else if (scopeType == ScopeContext.teacher) {
      switch (scopeFilterType) {
        case GenericFilterType.standard:
          assert(isSubjectTeacher == true,
              "isSubjectTeacher must be true for standard");
          filterType = "t_subject_teacher_of_standard";
        case GenericFilterType.standardDivision:
          if (isClassTeacher == true) {
            filterType = "t_class_teacher_of";
            break;
          }
          filterType = "t_subject_teacher_of_standard_division";
        case GenericFilterType.department:
          filterType = "t_department";
        case GenericFilterType.all:
          filterType = "t_all";
      }
    } else {
      filterType = "everyone";
    }
    return AnnouncementScope(filter: filterType, filterData: scopeFilterData);
  }
}

class ScopeSelectionDropdownOption {
  final String label;
  final String value;

  ScopeSelectionDropdownOption(this.label, this.value);
}

class _ScopeSelectionBottomSheetState extends State<ScopeSelectionBottomSheet> {
  ScopeSelectionData _scopeSelectionData = ScopeSelectionData(
      scopeType: ScopeContext.student,
      scopeFilterType: GenericFilterType.standard,
      scopeFilterData: '');

  List<ScopeSelectionDropdownOption> _scopeFilterTypeOptions = [];
  List<ScopeSelectionDropdownOption> _scopeFilterDataOptions = [];

  @override
  void initState() {
    super.initState();
    handleScopeContextOptionSelect(ScopeContext.student);
  }

  void handleScopeContextOptionSelect(ScopeContext scopeContext) {
    setState(() {
      _scopeSelectionData = _scopeSelectionData.copyWith(
        scopeContext: scopeContext,
        scopeFilterType: GenericFilterType.standard,
        scopeFilterData: '',
      );
    });

    switch (scopeContext) {
      case ScopeContext.student:
        setState(() {
          _scopeFilterTypeOptions = GenericFilterType.values
              .where((entry) =>
                  entry != GenericFilterType.department &&
                  entry != GenericFilterType.all)
              .map((entry) =>
                  ScopeSelectionDropdownOption(entry.label, entry.value))
              .toList();
        });
        break;
      case ScopeContext.teacher:
        setState(() {
          if (_scopeSelectionData.isClassTeacher == true) {
            _scopeFilterTypeOptions = GenericFilterType.values
                .where((filter) => filter == GenericFilterType.standardDivision)
                .map((entry) =>
                    ScopeSelectionDropdownOption(entry.label, entry.value))
                .toList();
          } else {
            _scopeFilterTypeOptions = GenericFilterType.values
                .where((filter) => filter != GenericFilterType.all)
                .map((entry) =>
                    ScopeSelectionDropdownOption(entry.label, entry.value))
                .toList();
          }
        });
        break;
      case ScopeContext.everyone:
        assert(false,
            "ScopeContext.everyone typically would not be possible within the UI");
    }

    setState(() {
      handleScopeFilterTypeOptionSelect(_scopeFilterTypeOptions.lastOrNull);
    });
  }

  void handleScopeFilterTypeOptionSelect(ScopeSelectionDropdownOption? option) {
    if (option == null) {
      return;
    }

    switch (option.value) {
      case "standard":
        setState(() {
          _scopeFilterDataOptions = dropdownClassroomStandardOptions;
          _scopeSelectionData = _scopeSelectionData.copyWith(
              scopeFilterType: GenericFilterType.standard,
              scopeFilterData:
                  dropdownClassroomStandardOptions.firstOrNull?.value);
        });
        break;
      case "standard_division":
        setState(() {
          _scopeFilterDataOptions = dropdownClassroomStandardDivisionOptions;
          _scopeSelectionData = _scopeSelectionData.copyWith(
              scopeFilterType: GenericFilterType.standardDivision,
              scopeFilterData:
                  dropdownClassroomStandardDivisionOptions.firstOrNull?.value);
        });
        break;
      case "department":
        setState(() {
          _scopeFilterDataOptions = dropdownDepartmentOptions;
          _scopeSelectionData = _scopeSelectionData.copyWith(
              scopeFilterType: GenericFilterType.department,
              scopeFilterData: dropdownDepartmentOptions.firstOrNull?.value);
        });
        break;
    }
  }

  void handleScopeSubmit(ScopeSelectionData? data) {
    widget.onCreated(data ?? _scopeSelectionData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.75,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Select an Audience",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton.filled(
                  color: PaletteNeutral.shade900,
                  style: const ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(PaletteNeutral.shade040),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: IconSizes.iconMd))
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            "Quick Select",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColor.subtitle),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              VartaChip(
                variant: VartaChipVariant.secondary,
                text: "All Students",
                onPressed: () {
                  handleScopeSubmit(_scopeSelectionData.copyWith(
                    scopeFilterData: "",
                    scopeFilterType: GenericFilterType.all,
                    scopeContext: ScopeContext.student,
                    isClassTeacher: false,
                    isSubjectTeacher: false,
                  ));
                },
              ),
              VartaChip(
                variant: VartaChipVariant.secondary,
                text: "All Teachers",
                onPressed: () {
                  handleScopeSubmit(_scopeSelectionData.copyWith(
                    scopeFilterData: "",
                    scopeFilterType: GenericFilterType.all,
                    scopeContext: ScopeContext.teacher,
                    isClassTeacher: false,
                    isSubjectTeacher: false,
                  ));
                },
              ),
              VartaChip(
                variant: VartaChipVariant.secondary,
                text: "Everyone",
                onPressed: () {
                  handleScopeSubmit(_scopeSelectionData.copyWith(
                    scopeFilterData: "",
                    scopeFilterType: GenericFilterType.all,
                    scopeContext: ScopeContext.everyone,
                    isClassTeacher: false,
                    isSubjectTeacher: false,
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            "Custom",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppColor.subtitle),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton(
                onSelectionChanged: (selection) =>
                    handleScopeContextOptionSelect(selection.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  selectedBackgroundColor: AppColor.primaryColor,
                  selectedForegroundColor: Colors.white,
                  visualDensity:
                      const VisualDensity(horizontal: 1, vertical: 1),
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  side: const BorderSide(color: AppColor.primaryColor),
                ),
                emptySelectionAllowed: false,
                segments: const [
                  ButtonSegment(
                      value: ScopeContext.student, label: Text("Student")),
                  ButtonSegment(
                      value: ScopeContext.teacher, label: Text("Teacher")),
                ],
                selected: {
                  _scopeSelectionData.scopeType
                }),
          ),
          const SizedBox(height: Spacing.md),
          if (_scopeSelectionData.scopeType == ScopeContext.teacher)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "is class teacher",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    VartaCheckbox(
                        checked: _scopeSelectionData.isClassTeacher ?? false,
                        onChanged: (value) {
                          setState(() {
                            _scopeSelectionData = _scopeSelectionData.copyWith(
                                isClassTeacher: value, isSubjectTeacher: false);
                          });
                          handleScopeContextOptionSelect(ScopeContext.teacher);
                        }),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "is subject teacher",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    VartaCheckbox(
                        checked: _scopeSelectionData.isSubjectTeacher ?? false,
                        onChanged: (value) {
                          setState(() {
                            _scopeSelectionData = _scopeSelectionData.copyWith(
                                isClassTeacher: false, isSubjectTeacher: value);
                          });
                          handleScopeContextOptionSelect(ScopeContext.teacher);
                        }),
                  ],
                ),
                const SizedBox(height: Spacing.sm), // Space below the rows
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Text("of",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: AppColor.subtitle)),
              ),
              Expanded(
                flex: 3,
                child: ScopeSelectionBottomSheetDropdownButton(
                    options: _scopeFilterTypeOptions,
                    selectedOption: _scopeFilterTypeOptions.firstWhere(
                      (option) =>
                          option.value ==
                          _scopeSelectionData.scopeFilterType.value,
                    ),
                    onChanged: handleScopeFilterTypeOptionSelect),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ScopeSelectionBottomSheetDropdownButton(
            options: _scopeFilterDataOptions,
            selectedOption: _scopeFilterDataOptions.firstWhere(
              (option) => option.value == _scopeSelectionData.scopeFilterData,
            ),
            onChanged: (ScopeSelectionDropdownOption? option) => setState(() =>
                _scopeSelectionData = _scopeSelectionData.copyWith(
                    scopeFilterData: option?.value)),
          ),
          const Spacer(),
          Center(
            child: PrimaryButton(
                text: "Add Audience",
                isDisabled: false,
                onPressed: () => handleScopeSubmit(null)),
          )
        ]));
  }
}

class ScopeSelectionBottomSheetDropdownButton extends StatelessWidget {
  final List<ScopeSelectionDropdownOption> options;
  final ScopeSelectionDropdownOption? selectedOption;
  final ValueChanged<ScopeSelectionDropdownOption?> onChanged;

  const ScopeSelectionBottomSheetDropdownButton({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<ScopeSelectionDropdownOption>(
      isExpanded: true,
      value: selectedOption,
      style: Theme.of(context).textTheme.bodyMedium,
      underline: const SizedBox.shrink(),
      iconStyleData:
          const IconStyleData(iconEnabledColor: PaletteNeutral.shade200),
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        height: 48,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PaletteNeutral.shade060, width: 1)),
      ),
      dropdownStyleData: DropdownStyleData(
          maxHeight: 175,
          elevation: 0,
          offset: const Offset(0, -5),
          decoration: BoxDecoration(
              color: PaletteNeutral.shade020,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PaletteNeutral.shade060))),
      items: options
          .map<DropdownMenuItem<ScopeSelectionDropdownOption>>(
              (item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Text(item.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: AppColor.body)),
                    ],
                  )))
          .toList(),
      onChanged: (ScopeSelectionDropdownOption? option) => onChanged(option),
    );
  }
}