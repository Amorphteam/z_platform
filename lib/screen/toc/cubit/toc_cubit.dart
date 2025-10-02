import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:masaha/model/toc_item.dart';

import '../../../repository/json_repository.dart';
import '../../../util/arabic_text_helper.dart';

part 'toc_state.dart';
part 'toc_cubit.freezed.dart';

class TocCubit extends Cubit<TocState> {

  TocCubit() : super(const TocState.initial());
  final JsonRepository _jsonRepository = JsonRepository();
  List<TocItem> _originalItems = [];

  Future<void> fetchItems({int? id}) async {
    try {
      emit(const TocState.loading());
      if (id == null) {
        final items = await _jsonRepository.fetchAllJsonToc();
        _originalItems = items;
        emit(TocState.loaded(items));
        return;
      }
      final items = await _jsonRepository.fetchJsonTocById(id);
      _originalItems = items;
      emit(TocState.loaded(items));
    } on Exception catch (e) {
      emit(TocState.error(e.toString()));
    }
  }

  void filterTocItems(String query) {
    if (query.isEmpty) {
      emit(TocState.loaded(_originalItems));
      return;
    }

    final normalizedQuery = normalizeArabicText(query.toLowerCase());
    final filteredItems = _flattenAndFilterTocItems(_originalItems, normalizedQuery);

    emit(TocState.loaded(_originalItems, filteredItems: filteredItems));
  }

  List<TocItem> _flattenAndFilterTocItems(List<TocItem> items, String query) {
    final List<TocItem> matchingItems = [];
    
    for (final item in items) {
      // Check if current item matches (normalize both texts for comparison)
      if (ArabicTextHelper.containsNormalized(item.title, query)) {
        // Add the item without its children to create a flat structure
        matchingItems.add(TocItem(
          id: item.id,
          title: item.title,
          key: item.key,
          level: item.level,
          parentId: item.parentId,
          childs: null, // Remove children to flatten the structure
        ),);
      }
      
      // Recursively check children
      if (item.childs != null && item.childs!.isNotEmpty) {
        final childMatches = _flattenAndFilterTocItems(item.childs!, query);
        matchingItems.addAll(childMatches);
      }
    }
    
    return matchingItems;
  }

  void clearFilter() {
    emit(TocState.loaded(_originalItems));
  }

  /// Normalizes Arabic text by removing diacritics and normalizing similar characters
  @visibleForTesting
  String normalizeArabicText(String text) {
    // Remove Arabic diacritics (Tashkeel/Erab)
    final RegExp diacriticsRegex = RegExp(
      r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]',
      unicode: true,
    );
    String normalizedText = text.replaceAll(diacriticsRegex, '');

    // Normalize different forms of Alif
    normalizedText = normalizedText
        .replaceAll('أ', 'ا')  // Alif with Hamza above
        .replaceAll('إ', 'ا')  // Alif with Hamza below  
        .replaceAll('آ', 'ا')  // Alif with Madda above
        .replaceAll('ٱ', 'ا'); // Alif Wasla

    // Normalize Ta Marbuta and Ha
    normalizedText = normalizedText
        .replaceAll('ة', 'ه');  // Ta Marbuta to Ha

    // Normalize different forms of Ya and Hamza
    normalizedText = normalizedText
        .replaceAll('ى', 'ي')   // Alif Maksura to Ya
        .replaceAll('ئ', 'ي')   // Ya with Hamza above
        .replaceAll('ؤ', 'و')   // Waw with Hamza above
        .replaceAll('ء', '');   // Remove standalone Hamza

    return normalizedText;
  }
}
