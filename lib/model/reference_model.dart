import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_model.freezed.dart';
part 'reference_model.g.dart';

@freezed
class ReferenceModel with _$ReferenceModel {
  const factory ReferenceModel({
    int? id, // Nullable for auto-generated IDs
    required String title,
    required String bookName,
    required String bookPath,
    required String navIndex,
  }) = _ReferenceModel;

  factory ReferenceModel.fromJson(Map<String, dynamic> json) =>
      _$ReferenceModelFromJson(json);
}
