import 'package:app/services/auth_service.dart';
import 'package:app/services/simple_cache_service.dart';
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

  void logout() async {
    SimpleCacheService cacheService = SimpleCacheService();

    AuthService().logout();

    state.setUser(null);
    state.setAnnouncements([]);
    state.setAnnouncements([], isUserAnnouncement: true);

    await cacheService.delete("announcements");
    await cacheService.delete("userAnnouncements");
    await cacheService.delete("teachers");
    await cacheService.delete("user");
  }
}
