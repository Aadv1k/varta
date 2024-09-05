import 'package:app/models/teacher_model.dart';
import 'package:app/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void _handleSearchSubmit(String finalQuery) {}

  @override
  Widget build(BuildContext context) {
    final searchProvider = SearchProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PostedBySelectionChip(),
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
                    onSubmit: _handleSearchSubmit,
                    onChange: (String text) => searchProvider.searchState
                        .setData(searchProvider.searchState.data
                            .copyWith(query: text))
                    // editingController: _controller,
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

class PostedBySelectionChip extends StatelessWidget {
  const PostedBySelectionChip({
    super.key,
  });

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
    final searchState = SearchProvider.of(context).searchState;
    showModalBottomSheet(
      enableDrag: true,
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
              ListenableBuilder(
                  listenable: searchState,
                  builder: (context, child) => Wrap(
                        children: (searchState.data.postedBy ?? [])
                            .map((t) => Text("Selected ${t.firstName}"))
                            .toList(),
                      )),
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
                  itemBuilder: (context, index) {
                    final bool isActive = (searchState.data.postedBy ?? [])
                        .contains(mockTeacherData[index]);
                    return ListTile(
                        contentPadding: EdgeInsets.zero,
                        selected: isActive,
                        selectedTileColor: PaletteNeutral.shade600,
                        onTap: () {
                          if (searchState.data.postedBy == null ||
                              searchState.data.postedBy!.isEmpty) {
                            searchState.setData(searchState.data
                                .copyWith(postedBy: [mockTeacherData[index]]));
                          }

                          final postedBy;

                          if (isActive) {
                            postedBy = List<TeacherModel>.from(
                                searchState.data.postedBy!)
                              ..removeWhere(
                                  (elem) => elem == mockTeacherData[index]);
                          } else {
                            postedBy = List<TeacherModel>.from(
                                searchState.data.postedBy ?? [])
                              ..add(mockTeacherData[index]);
                          }

                          searchState.setData(
                              searchState.data.copyWith(postedBy: postedBy));
                        },
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(
                                      text: "Teaches ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColor.subtitle),
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
                                                  ?.copyWith(
                                                      color: AppColor.heading),
                                            )),
                                  ])),
                              RichText(
                                text: TextSpan(
                                  text: "To ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColor.subtitle),
                                  children: mockTeacherData[index]
                                      .subjectTeacherOf
                                      .asMap()
                                      .entries
                                      .map((entry) => TextSpan(
                                            text:
                                                "${entry.value.standard}${entry.value.division}${entry.key == mockTeacherData[index].departments.length - 1 ? '' : ', '}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: AppColor.heading),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ]),
                        title: Text(
                            "${mockTeacherData[index].firstName} ${mockTeacherData[index].lastName}",
                            style: Theme.of(context).textTheme.titleSmall));
                  },
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
