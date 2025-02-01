import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_toc_item.freezed.dart';
part 'selected_toc_item.g.dart';

@freezed
class SelectedTocItem with _$SelectedTocItem {
  const factory SelectedTocItem({
    required int id,
    required String title,
    required String epub,
    required String section,
  }) = _SelectedTocItem;

  factory SelectedTocItem.fromJson(Map<String, dynamic> json) => _$SelectedTocItemFromJson(json);
}
