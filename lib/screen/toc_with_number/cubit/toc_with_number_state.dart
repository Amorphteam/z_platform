import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/model/toc_item.dart';

part 'toc_with_number_state.freezed.dart';

@freezed
class TocWithNumberState with _$TocWithNumberState {
  const factory TocWithNumberState.initial() = _Initial;
  const factory TocWithNumberState.loading() = _Loading;
  const factory TocWithNumberState.loaded(List<TocItem> items) = _Loaded;
  const factory TocWithNumberState.error(String message) = _Error;
} 