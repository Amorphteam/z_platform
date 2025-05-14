part of 'hekam_cubit.dart';

@freezed
class HekamState with _$HekamState {
  const factory HekamState.initial() = _Initial;
  const factory HekamState.loading() = _Loading;
  const factory HekamState.loaded(List<Hekam> hekam) = _Loaded;
  const factory HekamState.error(String message) = _Error;
} 