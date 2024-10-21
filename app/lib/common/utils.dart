import 'dart:convert';

import 'package:app/models/login_data.dart';
import 'package:app/screens/welcome/welcome.dart';
import 'package:app/widgets/providers/login_provider.dart';
import 'package:app/widgets/state/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

dynamic loadJsonFromAssetFile(String fileName) async {
  String data = await rootBundle.loadString(fileName);
  return jsonDecode(data);
}

void clearAndNavigateBackToLogin(BuildContext context) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginProvider(
              state: LoginState(data: LoginData()),
              child: const WelcomeScreen())),
      (_) => false);
}

// https://stackoverflow.com/questions/69099121/how-to-get-ordinal-numbers-in-flutter
String ordinal(int number) {
  if (!(number >= 1 && number <= 100)) {
    //here you change the range
    throw Exception('Invalid number');
  }

  if (number >= 11 && number <= 13) {
    return 'th';
  }

  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

String formatDate(DateTime date) {
  date = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));

  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return 'Today, ${DateFormat.jm().format(date)}';
  } else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Yesterday, ${DateFormat.jm().format(date)}';
  } else if (date.isAfter(startOfWeek) && date.isBefore(endOfWeek)) {
    return '${DateFormat.EEEE().format(date)}, ${DateFormat.jm().format(date)}';
  } else {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
