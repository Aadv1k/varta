import 'package:app/models/search_data.dart';
import 'package:flutter/material.dart';

class SearchState extends ChangeNotifier {
  SearchData data;

  SearchState({required this.data});

  void setData(SearchData newData) {
    data = newData;
    notifyListeners();
  }
}
