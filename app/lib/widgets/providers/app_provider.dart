import 'package:app/widgets/state/app_state.dart';
import 'package:flutter/material.dart';

class AppProvider extends InheritedWidget {
  final AppState state;

  const AppProvider({super.key, required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant AppProvider oldWidget) {
    return (oldWidget.state.announcements.length !=
            state.announcements.length) ||
        (oldWidget.state.userAnnouncements.length !=
            state.userAnnouncements.length) ||
        (oldWidget.state.user != state.user);
  }

  static AppProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null,
        "Couldn't find AppProvider higher up in the tree. This is likely a bug");
    return provider!;
  }
}
