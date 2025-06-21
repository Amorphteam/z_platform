import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting_state.dart';
part 'setting_cubit.freezed.dart';
class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(const SettingState.loaded());

  void updateFontSize(double size) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(fontSize: size));
    });
  }

  void updateLineHeight(double height) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(lineHeight: height));
    });
  }

  void toggleEnglish(bool value) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(english: value));
    });
  }

  void toggleFarsiFaidh(bool value) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiFaidh: value));
    });
  }

  void toggleFarsiAnsarian(bool value) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiAnsarian: value));
    });
  }

  void toggleFarsiJafari(bool value) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiJafari: value));
    });
  }

  void toggleFarsiShahidi(bool value) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiShahidi: value));
    });
  }

  void setTheme(String theme) {
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(theme: theme));
    });
  }
}
