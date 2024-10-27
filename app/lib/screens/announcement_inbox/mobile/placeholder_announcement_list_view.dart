import 'package:app/common/colors.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/screens/announcement_inbox/mobile/announcement_list_item.dart';
import 'package:flutter/material.dart';

class PlaceholderAnnouncementListView extends StatelessWidget {
  const PlaceholderAnnouncementListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 10,
      itemBuilder: (context, index) => AnnouncementListItem(
        announcement: placeholderAnnouncementModel,
      ),
      separatorBuilder: (context, index) =>
          const Divider(color: PaletteNeutral.shade040, height: 1),
    );
  }
}

var placeholderAnnouncementModel = AnnouncementModel(
    title: 'This is an example title, to act as a proxy for',
    body:
        'So I guess we are generating some random data! pretty cool if you ask me ngl, anyway. Cool package, cool Language',
    id: '',
    createdAt: DateTime(2024, 3, 6),
    author: AnnouncementAuthorModel(
      firstName: 'Foo',
      lastName: 'Bar',
      publicId: '1234',
    ),
    scopes: [],
    attachments: []);
