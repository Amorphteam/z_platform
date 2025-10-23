import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:masaha/repository/json_repository.dart';

import '../../../model/book_model.dart';
import '../../../model/qamari_date_model.dart';
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
    final AMPM = await DateHelper.handleAMPM();
    
    String? todayHijri;
    if (AMPM?.tomorrow == true) {
      // Add one day to Gregorian date first, then get hijri date
      todayHijri = await _getHijriDateForTomorrow(hijriDates);
    } else {
      // Use current date
      todayHijri = await DateHelper().getTodayCalendarHijri(qamariDate: hijriDates);
    }
    
    return 'Now in hijri: ${todayHijri ?? 'Unknown'}   |   ${AMPM?.ampm ?? 'Unknown'}';
  }

  // Helper method to get hijri date for tomorrow (Gregorian date + 1 day)
  Future<String?> _getHijriDateForTomorrow(QamariDateModel qamariDate) async {
    final currentDate = DateTime.now();
    final tomorrowDate = currentDate.add(const Duration(days: 1));
    
    final day = tomorrowDate.day;
    final month = tomorrowDate.month;
    final year = tomorrowDate.year;
    
    if (qamariDate.data.isEmpty) return null;

    // Find the matching date in the Qamari data for tomorrow's Gregorian date
    final matchingDate = qamariDate.data.firstWhere(
      (date) => date.gDate == '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year',
      orElse: () => qamariDate.data.first,
    );
    
    return '${matchingDate.hYear}-${matchingDate.hMonth.toString().padLeft(2, '0')}-${matchingDate.hDay.toString().padLeft(2, '0')}';
  }
}
