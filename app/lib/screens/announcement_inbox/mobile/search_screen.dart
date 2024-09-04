import 'package:app/models/teacher_model.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  String? postedBy;
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    _controller.addListener(() {
      _controller.text;
    });
    super.initState();
  }

  void _updatePostedBy(String? value) {
    setState(() {
      postedBy = value;
    });
  }

  void _updateDateFrom(DateTime? value) {
    setState(() {
      dateFrom = value;
    });
  }

  void _updateDateTo(DateTime? value) {
    setState(() {
      dateTo = value;
    });
  }

  void _submitSearch() {
    print('Search Query: ${_controller.text}');
    print('Posted By: $postedBy');
    print('Date From: $dateFrom');
    print('Date To: $dateTo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DropdownFilterChip(
                      label: "Posted By",
                      value: postedBy,
                      onChanged: _updatePostedBy,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left, size: IconSizes.iconLg),
              ),
              Expanded(
                child: CustomSearchBar(
                  autofocus: true,
                  navigational: false,
                  onSearch: (p0) => _submitSearch(),
                  editingController: _controller,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 84,
        titleSpacing: 0,
      ),
    );
  }
}

// class BasicActionChip extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final String label;
//   final bool isDropdown;

//   const BasicActionChip({
//     Key? key,
//     required this.onPressed,
//     required this.label,
//     this.isDropdown = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ActionChip(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(999),
//       ),
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label, style: const TextStyle(fontFamily: "Geist")),
//           if (isDropdown)
//             const Padding(
//               padding: EdgeInsets.only(left: Spacing.sm),
//               child: Icon(
//                 Icons.arrow_drop_down,
//                 size: IconSizes.iconMd,
//               ),
//             ),
//         ],
//       ),
//       onPressed: onPressed,
//     );
//   }
// }

class DropdownFilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  const DropdownFilterChip({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchFilterChip(
      label: 'Posted By',
      onPressed: () => _showBottomSheet(context),
      isFilled: false,
      isDropdown: true,
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Text("Posted By",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: Spacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.md,
                    children: [
                      InputChip(
                        label: Text("Amit Sharma"),
                        onDeleted: () {},
                      ),
                      InputChip(
                        label: Text("Jane Doe"),
                        onDeleted: () {},
                      ),
                      InputChip(
                        label: Text("Jane Doe"),
                        onDeleted: () {},
                      ),
                    ]),
              ),
              const SizedBox(height: Spacing.sm),
              const Divider(
                height: 1,
                color: AppColor.subtitleLighter,
              ),
              const SizedBox(height: Spacing.sm),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      subtitle: RichText(
                          text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColor.subtitle),
                              text: "Teaches ",
                              children: [
                            ...mockTeacherData[index]
                                .departments
                                .asMap()
                                .entries
                                .map((entry) => TextSpan(
                                      text:
                                          "${entry.value.deptName}${entry.key == mockTeacherData[index].departments.length - 1 ? '' : ', '}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColor.heading),
                                    )),
                            const TextSpan(text: " to "),
                            ...mockTeacherData[index]
                                .subjectTeacherOf
                                .asMap()
                                .entries
                                .map((entry) => TextSpan(
                                      text:
                                          "${entry.value.standard}${entry.value.division}${entry.key == mockTeacherData[index].departments.length - 1 ? '' : ', '}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColor.heading),
                                    )),
                          ])),
                      title: Text(
                          "${mockTeacherData[index].firstName} ${mockTeacherData[index].lastName}",
                          style: Theme.of(context).textTheme.titleSmall)),
                  itemCount: mockTeacherData.length,
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

class SearchFilterChip extends StatelessWidget {
  final bool isDropdown;
  final bool isFilled;
  final String label;
  final VoidCallback onPressed;

  const SearchFilterChip(
      {super.key,
      this.isDropdown = false,
      this.isFilled = false,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bg = this.isFilled ? AppColor.activeChipBg : AppColor.inactiveChipBg;
    final fg = this.isFilled ? AppColor.activeChipFg : AppColor.inactiveChipFg;

    return ActionChip(
      label: Row(children: [
        Text("Posted By",
            style: Theme.of(context).chipTheme.labelStyle?.copyWith(color: fg)),
        if (isDropdown)
          const SizedBox(width: Spacing.sm)
        else
          const SizedBox.shrink(),
        if (isDropdown)
          Icon(Icons.arrow_drop_down_rounded, color: fg, size: IconSizes.iconMd)
      ]),
      backgroundColor: bg,
      onPressed: onPressed,
    );
  }
}
