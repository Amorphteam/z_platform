import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/screen/toc_with_number/cubit/toc_with_number_state.dart';

import '../../../repository/json_repository.dart';

class TocWithNumberCubit extends Cubit<TocWithNumberState> {
  TocWithNumberCubit() : super(const TocWithNumberState.initial());
  final JsonRepository _jsonRepository = JsonRepository();

  Future<void> fetchItems({int? id}) async {
    try {
      emit(const TocWithNumberState.loading());
      if (id == null) {
        final items = await _jsonRepository.fetchAllJsonToc('assets/json/khotab_index.json');
        emit(TocWithNumberState.loaded(items));
        return;
      }
      emit(const TocWithNumberState.loaded([]));
    } catch (e) {
      emit(TocWithNumberState.error(e.toString()));
    }
  }
} 