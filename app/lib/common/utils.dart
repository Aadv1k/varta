import 'dart:convert';

import 'package:flutter/services.dart';

dynamic loadJsonFromAssetFile(String fileName) async {
  String data = await rootBundle.loadString(fileName);
  return jsonDecode(data);
}
