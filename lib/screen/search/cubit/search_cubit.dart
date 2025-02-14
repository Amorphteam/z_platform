import 'package:bloc/bloc.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/model/epubBookLocal.dart';

import '../../../model/book_model.dart';
import '../../../model/search_model.dart';
import '../../../repository/json_repository.dart';
import '../../../util/search_helper.dart';

part 'search_state.dart';
part 'search_cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState.initial());
  List<EpubBookLocal> epubBooks = [];
  Future<void> search(String searchTerm) async {
    try {
      emit(const SearchState.loading());
      final Set<SearchModel> uniqueResults = {};

      await SearchHelper().searchAllBooks(epubBooks, searchTerm, (partialResults) {
        uniqueResults.addAll(partialResults);
        emit(SearchState.loaded(searchResults: uniqueResults.toList()));
      });

      emit(SearchState.loaded(searchResults: uniqueResults.toList()));
    } catch (error) {
      emit(SearchState.error(error: error.toString()));
    }
  }

  Future<void> fetchBooksList() async {
    final List<Book> books = await JsonRepository().loadEpubFromJson();
    emit(SearchState.loadedList(books));
  }

  void resetState() {
    emit(const SearchState.initial());
  }


  Future<void> storeEpubBooks(Map<String, bool> selectedBooks) async {
    emit(const SearchState.loading());
    final List<String> allBooks = selectedBooks.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    epubBooks = await getEpubsFromAssets(allBooks);
  }

  Future<List<EpubBookLocal>> getEpubsFromAssets(List<String> allBooks) async {
    final List<EpubBookLocal> epubBooks = [];

    for (final bookPath in allBooks) {
      try {
        final epubData = await rootBundle.load('assets/epub/$bookPath');
        final epubBook = await EpubReader.readBook(epubData.buffer.asUint8List());

        final String fileName = getFileNameFromPath(bookPath);
        final epubBookLocal = EpubBookLocal(epubBook, fileName);
        epubBooks.add(epubBookLocal);
      } catch (e) {
        print("❌ Could not load book: $bookPath - Skipping... Error: $e");
        continue; // Skip missing books without crashing
      }
    }

    return epubBooks;
  }


  String getFileNameFromPath(String bookPath) {
    final RegExp regExp = RegExp(r'[^/]+\.epub$');
    final String fileName = regExp.stringMatch(bookPath) ?? '';
    return fileName;
  }
}
