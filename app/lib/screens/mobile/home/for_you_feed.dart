import 'package:app/common/colors.dart';
import 'package:app/common/sizes.dart';
import 'package:app/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class AnnouncementSliverList extends StatelessWidget {
  const AnnouncementSliverList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) => SizedBox(
          child: AnnouncementListItem(announcement: announcements[index])),
      itemCount: announcements.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(color: AppColors.subtitleLighter, height: 1.0),
    );
  }
}

class AnnouncementListItem extends StatelessWidget {
  final AnnouncementModel announcement;
  bool? allowEditing = false;
  VoidCallback? onPressed;
  VoidCallback? onDelete;

  AnnouncementListItem(
      {super.key,
      required this.announcement,
      this.allowEditing,
      this.onDelete,
      this.onPressed});

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today, \${DateFormat.jm().format(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday, \${DateFormat.jm().format(date)}';
    } else if (date.isAfter(startOfWeek) && date.isBefore(endOfWeek)) {
      return '${DateFormat.EEEE().format(date)}, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${announcement.author.firstName} ${announcement.author.lastName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(),
              ),
              const Spacer(),
              Text(
                formatDate(announcement.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            announcement.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.heading, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: Spacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: Spacing.lg),
            child: Text(
              announcement.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
