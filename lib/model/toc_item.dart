import 'package:freezed_annotation/freezed_annotation.dart';

part 'toc_item.freezed.dart';
part 'toc_item.g.dart';

@freezed
class TocItem with _$TocItem {
  const factory TocItem({
    required int level,
    String? key,
    required String title,
    int? id,
    int? parentId,
    @Default([]) List<TocItem>? childs,
    @Default([]) List<Items>? items,

  }) = _TocItem;

  factory TocItem.fromJson(Map<String, dynamic> json) => _$TocItemFromJson(json);
}

@freezed
class Items with _$Items {
  const factory Items({
    String? addressType,
    int? addressNo,
    String? text,
  }) = _Items;

  factory Items.fromJson(Map<String, dynamic> json) => _$ItemsFromJson(json);
}