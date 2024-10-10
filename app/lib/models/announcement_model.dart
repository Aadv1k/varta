class AnnouncementModel {
  final String title;
  final String body;
  final String id;
  final DateTime createdAt;
  final AnnouncementAuthorModel author;
  final List<AnnouncementScope> scopes;

  AnnouncementModel({
    required this.title,
    required this.body,
    required this.id,
    required this.createdAt,
    required this.author,
    required this.scopes,
  });

  @override
  String toString() {
    return 'Title: $title\nBody: $body\nID: $id\nCreated At: $createdAt\nAuthor: $author\nScopes: ${scopes.join(", ")}';
  }

  static AnnouncementModel fromJson(Map<String, dynamic> data) {
    return AnnouncementModel(
      title: data['title'] as String,
      body: data['body'] as String,
      id: data['id'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      author: AnnouncementAuthorModel.fromJson(
          data['author'] as Map<String, dynamic>),
      scopes: (data['scopes'] as List)
          .map((scope) =>
              AnnouncementScope.fromJson(scope as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'author': author.toJson(),
      'scopes': scopes.map((scope) => scope.toJson()).toList(),
    };
  }
}

class AnnouncementAuthorModel {
  final String firstName;
  final String lastName;
  final String publicId;

  AnnouncementAuthorModel({
    required this.firstName,
    required this.lastName,
    required this.publicId,
  });

  @override
  String toString() => '$firstName $lastName';

  static AnnouncementAuthorModel fromJson(Map<String, dynamic> data) {
    return AnnouncementAuthorModel(
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      publicId: data['public_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'public_id': publicId,
    };
  }
}

class AnnouncementScope {
  final String filter;
  final String? filterData;

  AnnouncementScope({
    required this.filter,
    this.filterData,
  });

  @override
  String toString() => 'Filter: $filter, Data: ${filterData ?? "None"}';

  static AnnouncementScope fromJson(Map<String, dynamic> data) {
    return AnnouncementScope(
      filter: data['filter'] as String,
      filterData: data['filter_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filter': filter,
      'filter_data': filterData,
    };
  }
}
