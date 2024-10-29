import 'package:app/common/utils.dart';

enum AnnouncementAttachmentFileType {
  DOCX,
  DOC,
  PPT,
  PPTX,
  XLS,
  XLSX,
  PDF,
  JPEG,
  PNG,
  MP4,
  MOV,
  AVI
}

class AnnouncementAttachmentModel {
  final String id;
  final DateTime createdAt;
  final String key;
  final String path;
  final AnnouncementAttachmentFileType fileType;
  final String fileName;

  AnnouncementAttachmentModel({
    required this.id,
    required this.createdAt,
    required this.key,
    required this.path,
    required this.fileType,
    required this.fileName,
  });

  static final mimeTypeToEnum = {
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        AnnouncementAttachmentFileType.DOCX,
    'application/msword': AnnouncementAttachmentFileType.DOC,
    'application/vnd.ms-powerpoint': AnnouncementAttachmentFileType.PPT,
    'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        AnnouncementAttachmentFileType.PPTX,
    'application/vnd.ms-excel': AnnouncementAttachmentFileType.XLS,
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        AnnouncementAttachmentFileType.XLSX,
    'application/pdf': AnnouncementAttachmentFileType.PDF,
    'image/jpeg': AnnouncementAttachmentFileType.JPEG,
    'image/png': AnnouncementAttachmentFileType.PNG,
    'video/mp4': AnnouncementAttachmentFileType.MP4,
    'video/quicktime': AnnouncementAttachmentFileType.MOV,
    'video/x-msvideo': AnnouncementAttachmentFileType.AVI,
  };

  factory AnnouncementAttachmentModel.fromJson(Map<String, dynamic> data) {
    final fileType =
        mimeTypeToEnum[data['mimeType']] ?? AnnouncementAttachmentFileType.PDF;

    return AnnouncementAttachmentModel(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      key: data['key'],
      path: data['url'],
      fileType: fileType,
      fileName: data['fileName'],
    );
  }

  static final enumToMimeType = {
    AnnouncementAttachmentFileType.DOCX:
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    AnnouncementAttachmentFileType.DOC: 'application/msword',
    AnnouncementAttachmentFileType.PPT: 'application/vnd.ms-powerpoint',
    AnnouncementAttachmentFileType.PPTX:
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    AnnouncementAttachmentFileType.XLS: 'application/vnd.ms-excel',
    AnnouncementAttachmentFileType.XLSX:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    AnnouncementAttachmentFileType.PDF: 'application/pdf',
    AnnouncementAttachmentFileType.JPEG: 'image/jpeg',
    AnnouncementAttachmentFileType.PNG: 'image/png',
    AnnouncementAttachmentFileType.MP4: 'video/mp4',
    AnnouncementAttachmentFileType.MOV: 'video/quicktime',
    AnnouncementAttachmentFileType.AVI: 'video/x-msvideo',
  };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'url': path,
      'mimeType': enumToMimeType[fileType],
      'fileName': fileName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnnouncementAttachmentModel) return false;
    return id == other.id && key == other.key;
  }

  @override
  int get hashCode => id.hashCode ^ key.hashCode;
}

class AnnouncementModel {
  final String title;
  final String body;
  final String id;
  final DateTime createdAt;
  final AnnouncementAuthorModel author;
  final List<AnnouncementScope> scopes;
  final List<AnnouncementAttachmentModel> attachments;

  AnnouncementModel({
    required this.title,
    required this.body,
    required this.id,
    required this.createdAt,
    required this.author,
    required this.scopes,
    required this.attachments,
  });

  @override
  String toString() {
    return '''
    Title: $title
    Body: $body
    ID: $id
    Created At: $createdAt
    Author: $author
    Scopes: ${scopes.join(", ")}
Attachments: ${attachments.join(", ")}
    ''';
  }

  bool isOptimistic() => id.startsWith("OPTMISTIC-");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnnouncementModel) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  AnnouncementModel copyWith({
    String? title,
    String? body,
    String? id,
    DateTime? createdAt,
    AnnouncementAuthorModel? author,
    List<AnnouncementScope>? scopes,
    List<AnnouncementAttachmentModel>? attachments,
  }) {
    return AnnouncementModel(
      title: title ?? this.title,
      body: body ?? this.body,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      scopes: scopes ?? this.scopes,
      attachments: attachments ?? this.attachments,
    );
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
      attachments: (data['attachments'] as List<dynamic>?)
              ?.map((attachment) => AnnouncementAttachmentModel.fromJson(
                  attachment as Map<String, dynamic>))
              .toList() ??
          [],
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
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
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

  AnnouncementAuthorModel copyWith({
    String? firstName,
    String? lastName,
    String? publicId,
  }) {
    return AnnouncementAuthorModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      publicId: publicId ?? this.publicId,
    );
  }

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

  AnnouncementScope copyWith({
    String? filter,
    String? filterData,
  }) {
    return AnnouncementScope(
      filter: filter ?? this.filter,
      filterData: filterData ?? this.filterData,
    );
  }

  static AnnouncementScope fromJson(Map<String, dynamic> data) {
    return AnnouncementScope(
      filter: data['filter'] as String,
      filterData: data['filter_data'] as String?,
    );
  }

  String toUserFriendlyLabel() {
    switch (filter) {
      case "t_class_teacher_of":
        return "${filterData} Teacher";
      case "t_subject_teacher_of_standard":
        return "${filterData}${ordinal(int.parse(filterData!))} Subject Teachers";
      case "t_subject_teacher_of_standard_division":
        return "${filterData} Subject Teacher";
      case "t_department":
        return "${filterData?[0].toUpperCase()}${filterData?.substring(1, filterData?.length).toLowerCase()} Department";
      case "stu_standard":
        return "${filterData}${ordinal(int.parse(filterData!))} Students";
      case "stu_standard_division":
        return "${filterData} Students";
      case "stu_all":
        return "All Students";
      case "t_all":
        return "All Teachers";
      case "everyone":
        return "Everyone";
    }

    return "Unknown";
  }

  Map<String, dynamic> toJson() {
    return {
      'filter': filter,
      'filter_data': filterData,
    };
  }
}

class AttachmentSelectionData {
  final String filePath;
  final String fileName;
  final bool isUrl;
  final AnnouncementAttachmentFileType fileType;

  const AttachmentSelectionData(
      {required this.filePath,
      required this.fileName,
      this.isUrl = false,
      required this.fileType});
}

class AnnouncementCreationData {
  final String title;
  final String body;
  final List<ScopeSelectionData> scopes;
  final List<AttachmentSelectionData> attachments;

  AnnouncementCreationData copyWith({
    String? title,
    String? body,
    List<ScopeSelectionData>? scopes,
    List<AttachmentSelectionData>? attachments,
  }) {
    return AnnouncementCreationData(
        title: title ?? this.title,
        body: body ?? this.body,
        scopes: scopes ?? this.scopes,
        attachments: attachments ?? this.attachments);
  }

  bool isValid() {
    return (title.trim().isNotEmpty && body.trim().isNotEmpty) &&
        scopes.isNotEmpty;
  }

  AnnouncementCreationData(
      {required this.scopes,
      required this.title,
      required this.body,
      required this.attachments});

  factory AnnouncementCreationData.fromModel(AnnouncementModel model) {
    return AnnouncementCreationData(
      title: model.title,
      body: model.body,
      scopes: model.scopes
          .map((e) => ScopeSelectionData.fromAnnouncementScope(e))
          .toList(),
      attachments: [],
    );
  }
}

enum ScopeContext { student, teacher, everyone }

enum GenericFilterType {
  standard("Standard", "standard"),
  standardDivision("Standard Division", "standard_division"),
  department("Department", "department"),
  all("All", "all");

  const GenericFilterType(this.label, this.value);
  final String label;
  final String value;
}

class ScopeSelectionData {
  final ScopeContext scopeType;
  final GenericFilterType scopeFilterType;
  final String scopeFilterData;
  final bool? isClassTeacher;
  final bool? isSubjectTeacher;

  ScopeSelectionData({
    required this.scopeType,
    required this.scopeFilterType,
    required this.scopeFilterData,
    this.isClassTeacher,
    this.isSubjectTeacher,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScopeSelectionData &&
          runtimeType == other.runtimeType &&
          scopeType == other.scopeType &&
          scopeFilterType == other.scopeFilterType &&
          scopeFilterData == other.scopeFilterData &&
          isClassTeacher == other.isClassTeacher &&
          isSubjectTeacher == other.isSubjectTeacher;

  @override
  int get hashCode =>
      scopeType.hashCode ^
      scopeFilterType.hashCode ^
      scopeFilterData.hashCode ^
      isClassTeacher.hashCode ^
      isSubjectTeacher.hashCode;

  ScopeSelectionData copyWith({
    ScopeContext? scopeContext,
    GenericFilterType? scopeFilterType,
    String? scopeFilterData,
    bool? isClassTeacher,
    bool? isSubjectTeacher,
  }) {
    return ScopeSelectionData(
      scopeType: scopeContext ?? scopeType,
      scopeFilterType: scopeFilterType ?? this.scopeFilterType,
      scopeFilterData: scopeFilterData ?? this.scopeFilterData,
      isClassTeacher: isClassTeacher ?? this.isClassTeacher,
      isSubjectTeacher: isSubjectTeacher ?? this.isSubjectTeacher,
    );
  }

  String getUserFriendlyLabel() {
    switch (scopeType) {
      case ScopeContext.student:
        return switch (scopeFilterType) {
          GenericFilterType.standard => "${scopeFilterData}th Students",
          GenericFilterType.standardDivision => "$scopeFilterData Students",
          GenericFilterType.all => "All Students",
          _ => throw AssertionError("Invalid filter type for students"),
        };
      case ScopeContext.teacher:
        return switch (scopeFilterType) {
          GenericFilterType.standard when isSubjectTeacher == true =>
            "${scopeFilterData}${ordinal(int.parse(scopeFilterData))} Teachers",
          GenericFilterType.standardDivision when isClassTeacher == true =>
            "${scopeFilterData} Class Teacher",
          GenericFilterType.standardDivision =>
            "${scopeFilterData} Subject Teachers",
          GenericFilterType.department => "$scopeFilterData Dept",
          GenericFilterType.all => "All Teachers",
          _ => throw AssertionError("Invalid filter type for teachers"),
        };
      case ScopeContext.everyone:
        return "Everyone";
    }
  }

  AnnouncementScope toAnnouncementScope() {
    var filterType = "";

    if (scopeType == ScopeContext.student) {
      filterType = switch (scopeFilterType) {
        GenericFilterType.standard => "stu_standard",
        GenericFilterType.standardDivision => "stu_standard_division",
        GenericFilterType.all => "stu_all",
        GenericFilterType.department => throw AssertionError(
            "A selection of GenericFilterType.department should not be possible when scopeType is ScopeContext.student, this is likely a bug in bottom-sheet selection logic")
      };
    } else if (scopeType == ScopeContext.teacher) {
      switch (scopeFilterType) {
        case GenericFilterType.standard:
          assert(isSubjectTeacher == true,
              "isSubjectTeacher must be true for standard");
          filterType = "t_subject_teacher_of_standard";
        case GenericFilterType.standardDivision:
          if (isClassTeacher == true) {
            filterType = "t_class_teacher_of";
            break;
          }
          filterType = "t_subject_teacher_of_standard_division";
        case GenericFilterType.department:
          filterType = "t_department";
        case GenericFilterType.all:
          filterType = "t_all";
      }
    } else {
      filterType = "everyone";
    }
    return AnnouncementScope(filter: filterType, filterData: scopeFilterData);
  }

  static ScopeSelectionData fromAnnouncementScope(AnnouncementScope scope) {
    return ScopeSelectionData(
        isClassTeacher: scope.filter == "t_class_teacher_of",
        isSubjectTeacher: scope.filter == "t_subject_teacher_of_standard",
        scopeType: switch (scope.filter) {
          "everyone" => ScopeContext.everyone,
          "stu_all" => ScopeContext.student,
          "stu_standard" => ScopeContext.student,
          "stu_standard_division" => ScopeContext.student,
          "t_all" => ScopeContext.teacher,
          "t_department" => ScopeContext.teacher,
          "t_class_teacher_of" => ScopeContext.teacher,
          "t_subject_teacher_of_standard_division" => ScopeContext.teacher,
          "t_subject_teacher_of_standard" => ScopeContext.teacher,
          _ => throw AssertionError("Invalid filter type"),
        },
        scopeFilterType: switch (scope.filter) {
          "everyone" => GenericFilterType.all,
          "stu_all" => GenericFilterType.all,
          "stu_standard" => GenericFilterType.standard,
          "stu_standard_division" => GenericFilterType.standard,
          "t_all" => GenericFilterType.all,
          "t_department" => GenericFilterType.department,
          "t_class_teacher_of" => GenericFilterType.standardDivision,
          "t_class_teacher_of" => GenericFilterType.standardDivision,
          "t_subject_teacher_of_standard_division" =>
            GenericFilterType.standardDivision,
          "t_subject_teacher_of_standard" => GenericFilterType.standard,
          _ => throw AssertionError("Invalid filter type"),
        },
        scopeFilterData: scope.filterData ?? "");
  }
}
