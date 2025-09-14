import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/repository/json_repository.dart';

import '../../../model/book_model.dart';
import '../../../util/date_helper.dart';
import '../../../util/time_zone_helper.dart';

part 'library_state.dart';
part 'library_cubit.freezed.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit() : super(const LibraryState.initial());
  
  Future<void> fetchBooks() async {
    emit(const LibraryState.loading());
    
    try {
      // Fetch books and date in parallel
      final booksFuture = JsonRepository().loadEpubFromJson();
      final dateFuture = _getHijriDate();
      
      final results = await Future.wait([booksFuture, dateFuture]);
      final books = results[0] as List<Book>;
      final hijriDate = results[1] as String;
      
      emit(LibraryState.loaded(books, hijriDate));
    } catch (e) {
      emit(LibraryState.error('Failed to load books: $e'));
    }
  }

  // Helper method to get hijri date
  Future<String> _getHijriDate() async {
    await TimeZoneHelper.initialize(); // Initialize TimeZoneHelper
    final hijriDates = await DateHelper().getHijriDates();
    final todayHijri = await DateHelper().getTodayCalendarHijri(qamariDate: hijriDates);
    final AMPM = await DateHelper.handleAMPM();
    return 'Now in hijri: $todayHijri   |   ${AMPM?.ampm}';
  }
}
