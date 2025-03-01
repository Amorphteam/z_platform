import 'package:bloc/bloc.dart';
import '../../../model/reference_model.dart';
import '../../../repository/hostory_database.dart';
import '../../../repository/reference_database.dart';
import 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit() : super(const BookmarkState.initial());

  final ReferencesDatabase referencesDatabase = ReferencesDatabase.instance;
  final HistoryDatabase historyDatabase = HistoryDatabase.instance;

  Future<void> loadAllBookmarks() async {
    emit(const BookmarkState.loading());
    try {
      final bookmarks = await referencesDatabase.getAllReferences();
      emit(BookmarkState.bookmarksLoaded(bookmarks));
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }

  Future<void> clearAllBookmarks() async {
    emit(const BookmarkState.loading());
    try {
      await referencesDatabase.clearAllReferences(); // New method to clear database
      await loadAllBookmarks(); // Fetch updated (empty) list
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }

  Future<void> clearAllHistory() async {
    emit(const BookmarkState.loading());
    try {
      await historyDatabase.clearAllHistory(); // New method to clear database
      await loadAllHistory(); // Fetch updated (empty) list
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }

  Future<void> deleteBookmark(int id) async {
    emit(const BookmarkState.loading());
    try {
      await referencesDatabase.deleteReference(id);
      await loadAllBookmarks();
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }

  Future<void> deleteHistory(int id) async {
    emit(const BookmarkState.loading());
    try {
      await historyDatabase.deleteHistory(id);
      await loadAllHistory();
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }

  Future<void> filterBookmarks(String query) async {
    emit(const BookmarkState.loading());
    try {
      final filteredBookmarks = await referencesDatabase.getFilterReference(query);
      emit(BookmarkState.bookmarksLoaded(filteredBookmarks));
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }

  void openEpub(ReferenceModel item) {
    emit(BookmarkState.bookmarkTapped(item));
  }

  Future<void> loadAllHistory() async {
    emit(const BookmarkState.loading());
    try {
      final history = await historyDatabase.getAllHistory();
      emit(BookmarkState.historyLoaded(history));
    } catch (error) {
      emit(BookmarkState.error(error.toString()));
    }
  }
}
