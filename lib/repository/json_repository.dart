import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/book_model.dart';

class JsonRepository {
  Future<List<Book>> loadEpubFromJson() async {
    final String response = await rootBundle.loadString('assets/json/library.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }
}