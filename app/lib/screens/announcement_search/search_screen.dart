import 'package:app/models/announcement_model.dart';
import 'package:app/models/search_data.dart';
import 'package:app/models/user_model.dart';
import 'package:app/repository/announcements_repo.dart';
import 'package:app/repository/user_repo.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_list_item.dart';
import 'package:app/widgets/connection_error.dart';
import 'package:app/widgets/varta_chip.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date);
}

class _SearchScreenState extends State<SearchScreen> {
  final AnnouncementsRepository _announcementRepo = AnnouncementsRepository();
  SearchData _data = SearchData();
  Future<List<AnnouncementModel>>? _searchResults;

  void _handleSearchSubmit(_) {
    if (_data.query == null || _data.query!.isEmpty) return;
    _doSearchRequest();
  }

  void _setSelectedAuthors(List<UserModel> authors) {
    setState(() {
      _data = _data.copyWith(postedBy: authors);
    });
    // NOTE: is this the right way to do this?
    Navigator.pop(context);
    _doSearchRequest();
  }

  void _doSearchRequest() async {
    setState(() {
      _searchResults = _announcementRepo.searchAnnouncement(_data);
    });
  }

  void _handleDateSelectionByChipClick(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DateSelectionBottomSheet(
        initialFromDate: _data.dateFrom,
        initialToDate: _data.dateTo,
        onDateChange: (from, to) {
          // NOTE: is this the right way to do this?
          Navigator.pop(context);
          setState(() {
            _data = _data.copyWith(
              dateFrom: from,
              dateTo: to,
            );
          });
          _doSearchRequest();
        },
      ),
    );
  }

  void _handlePostedByChipClick(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => PostedByBottomSheet(
          onChange: _setSelectedAuthors,
          selectedTeachers: _data.postedBy ?? []),
    );
  }

  String _buildDateLabel() {
    if (_data.dateFrom != null && _data.dateTo != null) {
      return "${_formatDate(_data.dateFrom)} - ${_formatDate(_data.dateTo)}";
    } else if (_data.dateFrom != null) {
      return "Since ${_formatDate(_data.dateFrom)}";
    } else if (_data.dateTo != null) {
      return "Till ${_formatDate(_data.dateTo)}";
    } else {
      return "Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(Spacing.xl),
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
                      VartaChip(
                        variant: (_data.postedBy?.isNotEmpty ?? false)
                            ? VartaChipVariant.primary
                            : VartaChipVariant.secondary,
                        text: (_data.postedBy?.isNotEmpty ?? false)
                            ? "${_data.postedBy![0].firstName} ${_data.postedBy![0].lastName} ${_data.postedBy!.length > 1 ? '+${_data.postedBy!.length - 1}' : ''}"
                            : "Posted By",
                        onPressed: () => _handlePostedByChipClick(context),
                      ),
                      const SizedBox(width: Spacing.sm),
                      VartaChip(
                        variant:
                            (_data.dateFrom != null || _data.dateTo != null)
                                ? VartaChipVariant.primary
                                : VartaChipVariant.secondary,
                        text: _buildDateLabel(),
                        onPressed: () =>
                            _handleDateSelectionByChipClick(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
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
                    onSubmit: _handleSearchSubmit,
                    onChange: (String text) =>
                        setState(() => _data = _data.copyWith(query: text)),
                  ),
                ),
              ],
            ),
          ),
          titleSpacing: 0,
        ),
        body: _searchResults != null
            ? FutureBuilder(
                future: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: GenericError(size: ErrorSize.large));
                  }

                  if (snapshot.data!.isNotEmpty) {
                    return const Center(
                        heightFactor: 0.8,
                        child: GenericError(
                          size: ErrorSize.large,
                          svgPath: "falling.svg",
                          errorMessage:
                              "Welp! it looks like your search didn't yield any results.",
                        ));
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.lg),
                          child: Text("RESULTS",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: AppColor.subtitle,
                                  )),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) =>
                                  AnnouncementListItem(
                                      announcement: snapshot.data![index])),
                        ),
                      ],
                    ),
                  );
                })
            : Center(
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                    "Nothing here yet! Begin searching to view announcements",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge),
              )));
  }
}

class DateSelectionBottomSheet extends StatefulWidget {
  final void Function(DateTime? from, DateTime? to) onDateChange;

  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  const DateSelectionBottomSheet(
      {super.key,
      required this.onDateChange,
      this.initialFromDate,
      this.initialToDate});

  @override
  _DateSelectionBottomSheetState createState() =>
      _DateSelectionBottomSheetState();
}

class _DateSelectionBottomSheetState extends State<DateSelectionBottomSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate = isFromDate
        ? (_fromDate ?? DateTime(2024))
        : (_toDate ?? DateTime.now());
    final firstDate = DateTime(2024);
    final lastDate = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: !isFromDate ? (_fromDate ?? firstDate) : firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = selectedDate;
        } else {
          _toDate = selectedDate;
        }
        widget.onDateChange(_fromDate, _toDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: Padding(
        padding: const EdgeInsets.only(
            top: Spacing.md,
            bottom: Spacing.xs,
            left: Spacing.lg,
            right: Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("From",
                        style: Theme.of(context).textTheme.headlineMedium),
                    OutlinedButton(
                      onPressed: () => _selectDate(context, true),
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                            vertical: Spacing.sm, horizontal: Spacing.md)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(999)),
                            side: BorderSide(color: AppColor.primaryColor),
                          ),
                        ),
                      ),
                      child: Text(
                        _fromDate == null ? "Oldest" : _formatDate(_fromDate),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColor.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Till",
                        style: Theme.of(context).textTheme.headlineMedium),
                    OutlinedButton(
                      onPressed: () => _selectDate(context, false),
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                            vertical: Spacing.sm, horizontal: Spacing.md)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(999)),
                            side: BorderSide(color: AppColor.primaryColor),
                          ),
                        ),
                      ),
                      child: Text(
                        _toDate == null ? "Today" : _formatDate(_toDate),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColor.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: Spacing.md,
                            right: Spacing.xs,
                            bottom: Spacing.sm,
                            left: Spacing.xs)),
                    onPressed: () {
                      setState(() {
                        _toDate = null;
                        _fromDate = null;
                      });
                      widget.onDateChange(_toDate, _fromDate);
                    },
                    child: Text("Clear All",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColor.dangerBody)))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class PostedByBottomSheet extends StatefulWidget {
  final Function(List<UserModel>) onChange;
  final List<UserModel> selectedTeachers;

  const PostedByBottomSheet({
    super.key,
    required this.onChange,
    required this.selectedTeachers,
  });

  @override
  State<PostedByBottomSheet> createState() => _PostedByBottomSheetState();
}

class _PostedByBottomSheetState extends State<PostedByBottomSheet> {
  final _userRepo = UserRepo();

  late final Set<UserModel> _initiallySelectedTeachers;
  final List<UserModel> _selectedTeachers = [];
  late final Future<List<UserModel>> _fetchTeachersFuture;

  void _handleChipDelete(UserModel teacher) {
    setState(() {
      _selectedTeachers.remove(teacher);
    });
    widget.onChange(_selectedTeachers);
  }

  void _handleTileClick(UserModel teacher) {
    setState(() {
      if (_selectedTeachers.contains(teacher)) {
        _selectedTeachers.remove(teacher);
      } else {
        _selectedTeachers.add(teacher);
      }
    });
    widget.onChange(_selectedTeachers);
  }

  Future<List<UserModel>> _fetchTeachers() async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _userRepo.getTeachers();
  }

  @override
  void initState() {
    super.initState();
    _initiallySelectedTeachers = Set.from(widget.selectedTeachers);
    _selectedTeachers.addAll(_initiallySelectedTeachers);
    _fetchTeachersFuture = _fetchTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: Spacing.md,
              left: Spacing.md,
              right: Spacing.md,
            ),
            child: Text(
              "Posted By",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: _selectedTeachers
                      .map((elem) => VartaChip(
                            variant: VartaChipVariant.primary,
                            text: "${elem.firstName} ${elem.lastName}",
                            onDeleted: () => _handleChipDelete(elem),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          const Divider(color: AppColor.subtitleLighter, height: 1),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _fetchTeachersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                      heightFactor: 0.8,
                      child: GenericError(size: ErrorSize.medium));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No data available"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final teacher = snapshot.data![index];
                    return AnnouncementPostedBySelectionTile(
                      teacher: teacher,
                      isActive: _selectedTeachers.contains(teacher),
                      onTap: () => _handleTileClick(teacher),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AnnouncementPostedBySelectionTile extends StatelessWidget {
  final UserModel teacher;
  final bool isActive;
  final VoidCallback onTap;

  const AnnouncementPostedBySelectionTile({
    super.key,
    required this.teacher,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: Spacing.sm,
        horizontal: Spacing.md,
      ),
      selected: isActive,
      trailing: isActive
          ? const Icon(
              Icons.check_circle,
              size: IconSizes.iconMd,
              color: AppColor.primaryColor,
            )
          : null,
      onTap: onTap,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "Teaches ",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColor.body),
              children: [
                ...(teacher.details as TeacherDetails)
                    .departments
                    .asMap()
                    .entries
                    .map(
                      (entry) => TextSpan(
                        text:
                            "${entry.value.deptName}${entry.key == teacher.details.departments.length - 1 ? '' : ', '}",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColor.heading),
                      ),
                    ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text: "To ",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColor.subtitle),
              children: teacher.details.subjectTeacherOf
                  .asMap()
                  .entries
                  .map(
                    (entry) => TextSpan(
                      text:
                          "${entry.value.standard}${entry.value.division}${entry.key == teacher.details.length - 1 ? '' : ', '}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColor.heading),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      title: Text(
        "${teacher.firstName} ${teacher.lastName}",
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
