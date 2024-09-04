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
    return ActionChip(
      backgroundColor:
          value != null ? AppColor.activeChipBg : AppColor.inactiveChipBg,
      onPressed: () => _showBottomSheet(context),
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(style: BorderStyle.none),
      ),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value ?? label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value != null
                      ? AppColor.activeChipFg
                      : AppColor.inactiveChipFg,
                ),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: IconSizes.iconMd,
            color:
                value != null ? AppColor.activeChipFg : AppColor.inactiveChipFg,
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Spacing.md, horizontal: Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Posted By",
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: Spacing.sm),
              Wrap(spacing: Spacing.sm, children: [
                Chip(
                  label: Text("Jane Doe"),
                  onDeleted: () {},
                ),
                Chip(
                  label: Text("Jane Doe"),
                  onDeleted: () {},
                ),
                Chip(
                  label: Text("Jane Doe"),
                  onDeleted: () {},
                ),
              ]),
              const SizedBox(height: Spacing.sm),
              const Divider(
                height: 1,
                color: AppColor.subtitle,
              ),
              const SizedBox(height: Spacing.sm),
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) => ListTile(
                    subtitle: RichText(
            text:
                    TextSpan(
                      text: "Teaches", 
                      children: [
                        ...mockTeacherData[index].departments.map(dept => Text(dept.name")),
                        in 
                        ...mockTeacherData[index].subjectTeacherOf.map(class => Text(dept.name")),
                      ]
                    ),

                    )
                    title: Text(
                        "${mockTeacherData[index].firstName} ${mockTeacherData[index].lastName}")),
                itemCount: mockTeacherData.length,
              )),
            ],
          ),
        ); },
    );
  }
}

class DateFilterChip extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const DateFilterChip({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor:
          value != null ? AppColor.activeChipBg : AppColor.inactiveChipBg,
      onPressed: () => _selectDate(context),
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(style: BorderStyle.none),
      ),
      label: Text(
        value != null ? _formatDate(value!) : label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: value != null
                  ? AppColor.activeChipFg
                  : AppColor.inactiveChipFg,
            ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate =
        DateTime(now.year - 1, 8, 1); // August 1st of last year
    final DateTime lastDate =
        DateTime(now.year + 1, 7, 31); // July 31st of next year

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && picked != value) {
      onChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('MMM, d yyyy');
    return formatter.format(date);
  }
}
