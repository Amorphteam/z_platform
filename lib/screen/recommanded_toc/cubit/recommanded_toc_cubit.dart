import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../model/selected_toc_item.dart';
import '../../../repository/json_repository.dart';

part 'recommanded_toc_state.dart';
part 'recommanded_toc_cubit.freezed.dart';

class RecommandedTocCubit extends Cubit<RecommandedTocState> {
  RecommandedTocCubit() : super(const RecommandedTocState.initial());
  final JsonRepository _jsonRepository = JsonRepository();

  Future<void> fetchItems() async {
    try {
      emit(const RecommandedTocState.loading());
        final items = await _jsonRepository.fetchJsonSelectedToc();
        emit(RecommandedTocState.loaded(items));
        return;
    } catch (e) {
      emit(RecommandedTocState.error(e.toString()));
    }
  }
}
