import 'package:app/state/search_state.dart';
import 'package:flutter/material.dart';

class SearchProvider extends InheritedWidget {
  final SearchState searchState;

  const SearchProvider(
      {super.key, required super.child, required this.searchState});

  static SearchProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant SearchProvider oldWidget) {
    return searchState != oldWidget.searchState;
  }
}
