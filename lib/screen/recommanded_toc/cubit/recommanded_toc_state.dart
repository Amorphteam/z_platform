part of 'recommanded_toc_cubit.dart';

@freezed
class RecommandedTocState with _$RecommandedTocState {
  const factory RecommandedTocState.initial() = _Initial;
  const factory RecommandedTocState.loading() = _Loading;
  const factory RecommandedTocState.loaded(List<SelectedTocItem> items) = _Loaded;
  const factory RecommandedTocState.error(String message) = _Error;
}
