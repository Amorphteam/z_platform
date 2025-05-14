import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/repository/database_repository.dart';

part 'hekam_state.dart';
part 'hekam_cubit.freezed.dart';

class HekamCubit extends Cubit<HekamState> {
  final DatabaseRepository _databaseRepository = DatabaseRepository();

  HekamCubit() : super(const HekamState.initial());

  Future<void> fetchHekam() async {
    try {
      emit(const HekamState.loading());
      final hekam = await _databaseRepository.getAllHekam();
      emit(HekamState.loaded(hekam));
    } catch (e) {
      emit(HekamState.error(e.toString()));
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final currentState = state;
      if (currentState is _Loaded) {
        final updatedHekam = currentState.hekam.map((item) {
          if (item.id == id) {
            return item.copyWith(isFavorite: !item.isFavorite);
          }
          return item;
        }).toList();
        emit(HekamState.loaded(updatedHekam));
        await _databaseRepository.toggleFavorite(id);
      }
    } catch (e) {
      emit(HekamState.error(e.toString()));
    }
  }
} 