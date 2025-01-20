part of 'bookmark_cubit.dart';

abstract class BookmarkState {}

class AllBookmarksLoadedState extends BookmarkState {
  AllBookmarksLoadedState(this.bookmarks);
  final List<ReferenceModel> bookmarks;
}
class AllHistoryLoadedState extends BookmarkState {
  AllHistoryLoadedState(this.history);
  final List<ReferenceModel> history;
}

class BookmarkDeletedState extends BookmarkState {}

class BookmarkLoadingState extends BookmarkState {}

class BookmarkInitState extends BookmarkState {}

class BookmarkErrorState extends BookmarkState {
  BookmarkErrorState(this.error);
  final Exception error;
}

class BookmarkTappedState extends BookmarkState {
  BookmarkTappedState(this.item);
  final ReferenceModel item;
}


