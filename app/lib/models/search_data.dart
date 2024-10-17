import 'package:app/models/user_model.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class SearchData {
  final List<UserModel>? postedBy;
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
    List<UserModel>? postedBy,
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

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};

    if (query != null && query!.isNotEmpty) {
      params['query'] = query;
    }

    if (postedBy != null && postedBy!.isNotEmpty) {
      params['posted_by'] = postedBy!.map((user) => user.publicId).toList();
    }

    if (dateFrom != null) {
      params['date_from'] = DateFormat('yyyy-MM-dd').format(dateFrom!);
    }

    if (dateTo != null) {
      params['date_to'] = DateFormat('yyyy-MM-dd').format(dateTo!);
    }

    return params;
  }
}
