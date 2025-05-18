import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/model/item_model.dart';
import 'package:zahra/repository/database_repository.dart';
import '../../../repository/json_repository.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final DatabaseRepository _databaseRepository = DatabaseRepository();
  final List<String> items = [
    'مقدمة الشريف الرضي',
    'الخُطِب والأوامر',
    'الكُتُب والرَّسائِل',
    'الحِكَم والمواعظ',
    'غريب الكلمات',
  ];

  HomeCubit() : super(const HomeState.initial());

  Future<void> fetchItems() async {
    try {
      emit(const HomeState.loading());
      final randomText = await _databaseRepository.getRandomOnscreenText();
      if (randomText != null) {
        emit(HomeState.loaded(items, hekamText: randomText.textAr));
      } else {
        emit(HomeState.loaded(items));
      }
    } catch (e) {
      emit(HomeState.error(e.toString()));
    }
  }
}
