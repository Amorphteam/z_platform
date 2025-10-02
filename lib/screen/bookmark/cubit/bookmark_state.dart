import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:masaha/model/history_model.dart';
import 'package:masaha/repository/hostory_database.dart';
import '../../../model/reference_model.dart';

part 'bookmark_state.freezed.dart';

@freezed
class BookmarkState with _$BookmarkState {
  const factory BookmarkState.initial() = _Initial;
  const factory BookmarkState.loading() = _Loading;
  const factory BookmarkState.bookmarksLoaded(List<ReferenceModel> bookmarks) = _BookmarksLoaded;
  const factory BookmarkState.historyLoaded(List<HistoryModel> history) = _HistoryLoaded;
  const factory BookmarkState.bookmarkTapped(ReferenceModel bookmark) = _BookmarkTapped;
  const factory BookmarkState.historyTapped(HistoryDatabase history) = _HistoryTapped;
  const factory BookmarkState.error(String message) = _Error;
}
