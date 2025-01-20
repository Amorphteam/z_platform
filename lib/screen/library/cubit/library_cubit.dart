import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/repository/json_repository.dart';

import '../../../model/book_model.dart';

part 'library_state.dart';
part 'library_cubit.freezed.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit() : super(const LibraryState.initial());
  Future<void> fetchBooks() async {
    final List<Book> books = await JsonRepository().loadEpubFromJson();
    emit(LibraryState.loaded(books));
  }

}
