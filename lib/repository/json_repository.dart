import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/book_model.dart';
import '../model/toc_item.dart';

class JsonRepository {
  Future<List<Book>> loadEpubFromJson() async {
    final String response = await rootBundle.loadString('assets/json/library.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }

  Future<List<TocItem>> fetchJsonTocById(int id, String jsonPath) async {
    final allTocItem = await fetchJsonToc(jsonPath);
    final List<TocItem> result = [];

    void searchTocItems(List<TocItem> items) {
      for (final item in items) {
        if (item.id == id) {
          result.addAll(item.childs??[]);
          return;
        } else {
          searchTocItems(item.childs??[]);
        }
      }
    }

    searchTocItems(allTocItem);
    return result;
  }

  Future<List<TocItem>> fetchAllJsonToc(String jsonPAth) async {
    final allTocItem = await fetchJsonToc(jsonPAth);
    final List<TocItem> result = [];

    void collectTocItems(List<TocItem> items) {
      for (final item in items) {
        result.add(item);
        collectTocItems(item.childs ?? []);
      }
    }

    collectTocItems(allTocItem);
    return result;
  }

  Future<List<TocItem>> fetchJsonToc(String jsonPath) async {
    final String response = await rootBundle.loadString(jsonPath);
    final List<dynamic> data = json.decode(response) as List<dynamic>;

    return data.map((item) => TocItem.fromJson(item as Map<String, dynamic>)).toList();
  }

}