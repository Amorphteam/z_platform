import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../model/book_model.dart';
import '../../../model/epubBookLocal.dart';
import '../../../model/search_model.dart';
import '../../../repository/json_repository.dart';
import '../../../util/search_helper.dart';

part 'search_state.dart';
part 'search_cubit.freezed.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState.initial());
  List<EpubBookLocal> epubBooks = [];

  Future<void> search(String searchTerm, {int? maxResultsPerBook, void Function()? onComplete}) async {
    try {
      emit(const SearchState.loading());
      final Set<SearchModel> uniqueResults = {};

      await SearchHelper().searchAllBooks(
        epubBooks, 
        searchTerm, 
        (partialResults) {
          uniqueResults.addAll(partialResults);
          emit(SearchState.loaded(searchResults: uniqueResults.toList(), isRuningSearch: true));
        },
        maxResultsPerBook,
      );


      // Call the onComplete callback if provided
      if (onComplete == null) {
        emit(SearchState.loaded(searchResults: uniqueResults.toList(), isRuningSearch: false));
      }
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
        final String fileName = getFileNameFromPath(bookPath);

        final epubBookLocal = await compute(
          _parseEpubInIsolate,
          _EpubParseParams(
            bytes: epubData.buffer.asUint8List(),
            fileName: fileName,
          ),
        );

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

class _EpubParseParams {
  const _EpubParseParams({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

Future<EpubBookLocal> _parseEpubInIsolate(_EpubParseParams params) async {
  final epubBook = await EpubReader.readBook(params.bytes);
  return EpubBookLocal(epubBook, params.fileName);
}
