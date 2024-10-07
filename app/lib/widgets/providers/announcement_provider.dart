import 'package:app/widgets/state/announcement_state.dart';
import 'package:flutter/material.dart';

class AnnouncementProvider extends InheritedWidget {
  final AnnouncementState state;

  const AnnouncementProvider(
      {required this.state, required super.child, super.key});

  @override
  bool updateShouldNotify(covariant AnnouncementProvider oldWidget) {
    // TODO: probably a bad way to do this, we shall learn just how bad soon.
    return oldWidget.state.announcements.length != state.announcements.length;
  }

  static AnnouncementProvider of(BuildContext context) {
    var elem =
        context.dependOnInheritedWidgetOfExactType<AnnouncementProvider>();
    assert(elem != null,
        "Wasn't able to find any AnnouncementProvider in the tree; this is a likely bug.");
    return elem!;
  }
}
