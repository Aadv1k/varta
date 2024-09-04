import 'package:app/models/announcement_model.dart';
import 'package:app/screens/announcement_inbox/mobile/search_screen.dart';
import 'package:app/screens/announcement_inbox/mobile/tab_selector_chip.dart';
import 'package:app/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/screens/announcement_inbox/mobile/for_you_feed.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledUnder = false;
  bool _isForYouView = true;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 112) {
        setState(() => _isScrolledUnder = true);
      } else {
        setState(() => _isScrolledUnder = false);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: LayoutBuilder(
        builder: (context, contraints) => contraints.maxWidth <= 600
            ? FloatingActionButton.large(
                onPressed: () {},
                backgroundColor: AppColor.primaryColor,
                child: const Icon(Icons.add,
                    color: AppColor.primaryBg, size: IconSizes.iconXl),
              )
            : FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: AppColor.primaryColor,
                label: const Text("Create Announcement",
                    style: TextStyle(
                        fontSize: FontSize.textBase,
                        fontWeight: FontWeight.normal,
                        color: AppColor.activeChipFg)),
                icon: const Icon(Icons.add,
                    color: AppColor.primaryBg, size: IconSizes.iconLg),
              ),
      ),
      backgroundColor: AppColor.primaryBg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            toolbarHeight: 72,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColor.primaryBg,
            centerTitle: true,
            title: const Text(
              "Varta",
              style: TextStyle(
                  color: AppColor.heading,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  height: 28 / 22),
            ),
            leading: const SizedBox.shrink(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: Spacing.md),
                child: CircleAvatar(
                  backgroundColor: PaletteNeutral.shade040,
                  child: IconButton(
                    splashColor: PaletteNeutral.shade060,
                    padding: EdgeInsets.zero,
                    iconSize: IconSizes.iconMd,
                    onPressed: () {},
                    icon: const Center(child: Icon(Icons.person)),
                  ),
                ),
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: _isScrolledUnder
                            ? const BorderSide(
                                color: PaletteNeutral.shade070, width: 1)
                            : const BorderSide(style: BorderStyle.none))),
                padding: const EdgeInsets.only(
                    left: Spacing.md, right: Spacing.md, bottom: Spacing.sm),
                child: const CustomSearchBar(navigational: true),
              ),
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
              ),
              child: Row(
                children: [
                  TabViewSelectorChip(
                    text: "For You",
                    onPressed: () => setState(() => _isForYouView = true),
                    isActive: _isForYouView ? true : false,
                  ),
                  const SizedBox(width: Spacing.sm),
                  TabViewSelectorChip(
                    text: "Your Announcements",
                    onPressed: () => setState(() => _isForYouView = false),
                    isActive: _isForYouView ? false : true,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: Spacing.md),
            sliver: AnnouncementListView(
              key: ValueKey<bool>(_isForYouView),
              isForYouView: _isForYouView,
            ),
          )
        ],
      ),
    );
  }
}

class AnnouncementListView extends StatefulWidget {
  final bool isForYouView;

  const AnnouncementListView({super.key, this.isForYouView = false});

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  final List<AnnouncementModel> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant AnnouncementListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isForYouView != oldWidget.isForYouView) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _data.addAll(
          widget.isForYouView ? announcements : additionalAnnouncements);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.sliver(
      enabled: _isLoading,
      child: AnnouncementSliverList(
          data: _isLoading
              ? List.generate(
                  10,
                  (int index) => AnnouncementModel(
                      title: 'This is an example title, to act as a proxy for',
                      body:
                          'So I guess we are generating some random data! pretty cool if you ask me ngl, anyway. Cool package, cool Language',
                      id: '',
                      createdAt: DateTime(2024, 30, 6),
                      author: AnnouncementAuthorModel(
                          firstName: 'Foo', lastName: 'Bar', publicId: '1234'),
                      scopes: []))
              : _data),
    );
  }
}

class AnnouncementSliverList extends StatelessWidget {
  const AnnouncementSliverList({
    super.key,
    required List<AnnouncementModel> data,
  }) : _data = data;

  final List<AnnouncementModel> _data;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Column(
            children: [
              AnnouncementListItem(announcement: _data[index]),
              const Divider(
                height: 1.0,
                color: AppColor.subtitleLighter,
                endIndent: Spacing.md,
                indent: Spacing.md,
              ),
            ],
          );
        },
        childCount: _data.length,
      ),
    );
  }
}

final List<AnnouncementModel> announcements = [
  AnnouncementModel(
    title: 'Holiday Announcement for Diwali',
    body:
        'All students will have a holiday for Diwali from October 22nd to October 25th. Please make sure to complete your assignments before the break.',
    id: 'a001',
    createdAt: DateTime(2024, 10, 1, 9, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Anita',
      lastName: 'Mehta',
      publicId: 'a123',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Physics Project Submission Deadline',
    body:
        'The deadline for submitting your Physics project is November 15th. Late submissions will not be accepted. Refer to the guidelines shared in class.',
    id: 'a002',
    createdAt: DateTime(2024, 10, 5, 10, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Rajesh',
      lastName: 'Singh',
      publicId: 'r456',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '12B',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Parent-Teacher Meeting',
    body:
        'A parent-teacher meeting will be held on November 8th from 2 PM to 5 PM in the school auditorium. All parents are requested to attend.',
    id: 'a003',
    createdAt: DateTime(2024, 10, 10, 8, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Suman',
      lastName: 'Sharma',
      publicId: 's789',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'teacher',
        filterData: null,
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Math Olympiad Practice Session',
    body:
        'Students of classes 10 and 11 are invited to a practice session for the upcoming Math Olympiad on October 20th at 3 PM in Room 302.',
    id: 'a004',
    createdAt: DateTime(2024, 10, 12, 14, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Pooja',
      lastName: 'Verma',
      publicId: 'p101',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '10A, 11B',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Science Fair Registration Open',
    body:
        'Registration for the Science Fair is now open. Students interested in participating should register by November 1st. Forms are available in the school office.',
    id: 'a005',
    createdAt: DateTime(2024, 10, 15, 11, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Arun',
      lastName: 'Kumar',
      publicId: 'a102',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '9th, 10th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Sports Day Rescheduled',
    body:
        'Due to unforeseen circumstances, the Sports Day event has been rescheduled to November 22nd. All students should prepare accordingly.',
    id: 'a006',
    createdAt: DateTime(2024, 10, 18, 15, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Deepak',
      lastName: 'Singh',
      publicId: 'd103',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Hindi Essay Competition',
    body:
        'An essay competition in Hindi will be held on October 30th. The theme is "My Vision for India." Entries must be submitted by October 25th.',
    id: 'a007',
    createdAt: DateTime(2024, 10, 20, 12, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Neha',
      lastName: 'Reddy',
      publicId: 'n104',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '8th, 9th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Art Exhibition Participation',
    body:
        'Students are invited to participate in the Art Exhibition on November 5th. Submit your artworks to the Art teacher by October 30th.',
    id: 'a008',
    createdAt: DateTime(2024, 10, 22, 13, 45),
    author: AnnouncementAuthorModel(
      firstName: 'Amit',
      lastName: 'Kumar',
      publicId: 'a105',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '7th to 12th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Book Fair Week',
    body:
        'The annual Book Fair will be held from October 25th to October 30th. Visit the school library to explore a variety of books at discounted prices.',
    id: 'a009',
    createdAt: DateTime(2024, 10, 23, 16, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Ritika',
      lastName: 'Chopra',
      publicId: 'r106',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Annual Science Quiz',
    body:
        'The Annual Science Quiz will be conducted on October 27th at 2 PM in the school auditorium. Teams from various classes are encouraged to participate.',
    id: 'a010',
    createdAt: DateTime(2024, 10, 25, 10, 15),
    author: AnnouncementAuthorModel(
      firstName: 'Manoj',
      lastName: 'Gupta',
      publicId: 'm107',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '11th, 12th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Teacher Training Workshop',
    body:
        'A workshop for teacher training will be held on November 3rd. All teaching staff are required to attend to enhance their skills and methodologies.',
    id: 'a011',
    createdAt: DateTime(2024, 10, 28, 9, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Sita',
      lastName: 'Bhatia',
      publicId: 's108',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'teacher',
        filterData: null,
      ),
    ],
  ),
  AnnouncementModel(
    title: 'International Day Celebrations',
    body:
        'Join us on November 10th for International Day celebrations. Students are encouraged to showcase different cultures through performances and exhibits.',
    id: 'a012',
    createdAt: DateTime(2024, 10, 30, 11, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Sunil',
      lastName: 'Rao',
      publicId: 's109',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
];

final List<AnnouncementModel> additionalAnnouncements = [
  AnnouncementModel(
    title: 'Coding Workshop for Beginners',
    body:
        'Join us for a beginner-level coding workshop on November 10th from 10 AM to 1 PM in the computer lab. No prior experience required.',
    id: 'a013',
    createdAt: DateTime(2024, 10, 30, 14, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Amit',
      lastName: 'Patel',
      publicId: 'a106',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Holiday Camp Registration Open',
    body:
        'Registration for the holiday camp is now open. The camp will be held from December 20th to December 24th. Sign up at the school office.',
    id: 'a014',
    createdAt: DateTime(2024, 10, 31, 11, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Neha',
      lastName: 'Singh',
      publicId: 'n105',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
];
