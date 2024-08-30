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
}

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
}
