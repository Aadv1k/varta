import 'dart:convert';

import 'package:app/common/exceptions.dart';
import 'package:app/models/announcement_model.dart';
import 'package:app/models/search_data.dart';
import 'package:app/services/api_service.dart';

import 'package:http/http.dart' as http;

class AnnouncementsRepository {
  final ApiService _apiService = ApiService();

  Future<List<AnnouncementModel>> getAnnouncements({int page = 1}) async {
    http.Response response;
    response = await _apiService.makeRequest(HTTPMethod.GET, "/announcements",
        isAuthenticated: true);

    print(response.body);
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    var data = jsonDecode(response.body);

    List<AnnouncementModel> parsedData = (data["data"] as List)
        .map((element) => AnnouncementModel.fromJson(element)!)
        .toList();

    return parsedData;
  }

  Future<List<AnnouncementModel>> getNewestAnnouncements() {
    // Here access the last cached data and based on that make a api call
    return Future.delayed(const Duration(seconds: 2), () => mockAnnouncements3);
  }

  Future<List<AnnouncementModel>> getUserAnnouncements({int page = 1}) {
    return Future.delayed(const Duration(seconds: 1), () => mockAnnouncements2);
  }

  Future<AnnouncementModel> createAnnouncement() {
    throw UnimplementedError();
  }

  Future<void> deleteAnnouncement() {
    throw UnimplementedError();
  }

  Future<void> updateAnnouncement() {
    throw UnimplementedError();
  }

  Future<List<AnnouncementModel>> searchAnnouncement(SearchData data) {
    return Future.delayed(const Duration(seconds: 1), () => mockAnnouncements2);
  }
}

final List<AnnouncementModel> mockAnnouncements = [
  AnnouncementModel(
    title: 'Holiday Announcement for Diwali',
    body:
        'All students will have a holiday for Diwali from October 22nd to October 25th. Please make sure to complete your assignments before the break.',
    id: 'a001',
    createdAt: DateTime(2024, 10, 1, 9, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Anita',
      lastName: 'Mehta',
      publicId: 'a123',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Physics Project Submission Deadline',
    body:
        'The deadline for submitting your Physics project is November 15th. Late submissions will not be accepted. Refer to the guidelines shared in class.',
    id: 'a002',
    createdAt: DateTime(2024, 10, 5, 10, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Rajesh',
      lastName: 'Singh',
      publicId: 'r456',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '12B',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Parent-Teacher Meeting',
    body:
        'A parent-teacher meeting will be held on November 8th from 2 PM to 5 PM in the school auditorium. All parents are requested to attend.',
    id: 'a003',
    createdAt: DateTime(2024, 10, 10, 8, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Suman',
      lastName: 'Sharma',
      publicId: 's789',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'teacher',
        filterData: null,
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Math Olympiad Practice Session',
    body:
        'Students of classes 10 and 11 are invited to a practice session for the upcoming Math Olympiad on October 20th at 3 PM in Room 302.',
    id: 'a004',
    createdAt: DateTime(2024, 10, 12, 14, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Pooja',
      lastName: 'Verma',
      publicId: 'p101',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '10A, 11B',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Science Fair Registration Open',
    body:
        'Registration for the Science Fair is now open. Students interested in participating should register by November 1st. Forms are available in the school office.',
    id: 'a005',
    createdAt: DateTime(2024, 10, 15, 11, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Arun',
      lastName: 'Kumar',
      publicId: 'a102',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '9th, 10th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Sports Day Rescheduled',
    body:
        'Due to unforeseen circumstances, the Sports Day event has been rescheduled to November 22nd. All students should prepare accordingly.',
    id: 'a006',
    createdAt: DateTime(2024, 10, 18, 15, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Deepak',
      lastName: 'Singh',
      publicId: 'd103',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Hindi Essay Competition',
    body:
        'An essay competition in Hindi will be held on October 30th. The theme is "My Vision for India." Entries must be submitted by October 25th.',
    id: 'a007',
    createdAt: DateTime(2024, 10, 20, 12, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Neha',
      lastName: 'Reddy',
      publicId: 'n104',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '8th, 9th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Art Exhibition Participation',
    body:
        'Students are invited to participate in the Art Exhibition on November 5th. Submit your artworks to the Art teacher by October 30th.',
    id: 'a008',
    createdAt: DateTime(2024, 10, 22, 13, 45),
    author: AnnouncementAuthorModel(
      firstName: 'Amit',
      lastName: 'Kumar',
      publicId: 'a105',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '7th to 12th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Book Fair Week',
    body:
        'The annual Book Fair will be held from October 25th to October 30th. Visit the school library to explore a variety of books at discounted prices.',
    id: 'a009',
    createdAt: DateTime(2024, 10, 23, 16, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Ritika',
      lastName: 'Chopra',
      publicId: 'r106',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Annual Science Quiz',
    body:
        'The Annual Science Quiz will be conducted on October 27th at 2 PM in the school auditorium. Teams from various classes are encouraged to participate.',
    id: 'a010',
    createdAt: DateTime(2024, 10, 25, 10, 15),
    author: AnnouncementAuthorModel(
      firstName: 'Manoj',
      lastName: 'Gupta',
      publicId: 'm107',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '11th, 12th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Teacher Training Workshop',
    body:
        'A workshop for teacher training will be held on November 3rd. All teaching staff are required to attend to enhance their skills and methodologies.',
    id: 'a011',
    createdAt: DateTime(2024, 10, 28, 9, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Sita',
      lastName: 'Bhatia',
      publicId: 's108',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'teacher',
        filterData: null,
      ),
    ],
  ),
  AnnouncementModel(
    title: 'International Day Celebrations',
    body:
        'Join us on November 10th for International Day celebrations. Students are encouraged to showcase different cultures through performances and exhibits.',
    id: 'a012',
    createdAt: DateTime(2024, 10, 30, 11, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Sunil',
      lastName: 'Rao',
      publicId: 's109',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
];

final List<AnnouncementModel> mockAnnouncements2 = [
  AnnouncementModel(
    title: 'Coding Workshop for Beginners',
    body:
        'Join us for a beginner-level coding workshop on November 10th from 10 AM to 1 PM in the computer lab. No prior experience required.',
    id: 'a013',
    createdAt: DateTime(2024, 10, 30, 14, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Amit',
      lastName: 'Patel',
      publicId: 'a106',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Holiday Camp Registration Open',
    body:
        'Registration for the holiday camp is now open. The camp will be held from December 20th to December 24th. Sign up at the school office.',
    id: 'a014',
    createdAt: DateTime(2024, 10, 31, 11, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Neha',
      lastName: 'Singh',
      publicId: 'n105',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
];

final List<AnnouncementModel> mockAnnouncements3 = [
  AnnouncementModel(
    title: 'School Health Check-up',
    body:
        'A health check-up for all students will be conducted on November 12th. Parents are requested to ensure their children are present.',
    id: 'a015',
    createdAt: DateTime(2024, 11, 1, 9, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Dr. Priya',
      lastName: 'Sharma',
      publicId: 'd110',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Music Concert Invitation',
    body:
        'You are invited to a music concert on November 15th at 6 PM in the auditorium. Come and enjoy performances by our talented students.',
    id: 'a016',
    createdAt: DateTime(2024, 11, 3, 16, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Rahul',
      lastName: 'Khan',
      publicId: 'r111',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Basketball Tournament',
    body:
        'A basketball tournament will take place on November 20th. Interested teams should register by November 15th with the PE teacher.',
    id: 'a017',
    createdAt: DateTime(2024, 11, 5, 14, 30),
    author: AnnouncementAuthorModel(
      firstName: 'Vikram',
      lastName: 'Joshi',
      publicId: 'v112',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '9th to 12th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Diwali Decoration Competition',
    body:
        'Students are invited to participate in the Diwali decoration competition on November 10th. Winners will receive prizes!',
    id: 'a018',
    createdAt: DateTime(2024, 11, 7, 11, 15),
    author: AnnouncementAuthorModel(
      firstName: 'Poonam',
      lastName: 'Rani',
      publicId: 'p113',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'School Play Auditions',
    body:
        'Auditions for the annual school play will be held on November 25th. Interested students should sign up with the drama teacher.',
    id: 'a019',
    createdAt: DateTime(2024, 11, 10, 10, 0),
    author: AnnouncementAuthorModel(
      firstName: 'Nitin',
      lastName: 'Chopra',
      publicId: 'n114',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: '7th to 12th',
      ),
    ],
  ),
  AnnouncementModel(
    title: 'Community Service Day',
    body:
        'Join us for Community Service Day on November 30th. Students will volunteer at local shelters. Sign up with your class teacher.',
    id: 'a020',
    createdAt: DateTime(2024, 11, 15, 9, 45),
    author: AnnouncementAuthorModel(
      firstName: 'Kiran',
      lastName: 'Bansal',
      publicId: 'k115',
    ),
    scopes: [
      AnnouncementScope(
        filter: 'stu_standard_division',
        filterData: 'All',
      ),
    ],
  ),
];
