import 'package:app/models/user_model.dart';
import 'package:collection/collection.dart';

class SearchData {
  final List<TeacherModel>? postedBy;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? query;

  SearchData({
    this.postedBy,
    this.dateFrom,
    this.dateTo,
    this.query,
  });

  SearchData copyWith({
    List<TeacherModel>? postedBy,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? query,
  }) {
    return SearchData(
      postedBy: postedBy ?? this.postedBy,
      dateFrom: dateFrom,
      dateTo: dateTo,
      query: query ?? this.query,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchData &&
        const ListEquality().equals(postedBy, other.postedBy) &&
        dateFrom == other.dateFrom &&
        dateTo == other.dateTo &&
        query == other.query;
  }

  @override
  int get hashCode {
    return Object.hash(
      const ListEquality().hash(postedBy),
      dateFrom,
      dateTo,
      query,
    );
  }
}
