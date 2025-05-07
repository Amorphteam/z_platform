import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_date_model.freezed.dart';

@freezed
class UpdateDate with _$UpdateDate {
  const factory UpdateDate({
    required String data,
    required int statusCode,
    required bool success,
  }) = _UpdateDate;
}
