import 'package:freezed_annotation/freezed_annotation.dart';

part 'qamari_date_model.freezed.dart';
part 'qamari_date_model.g.dart';

@freezed
class QamariDateModel with _$QamariDateModel {
  const factory QamariDateModel({
    required List<QamariData> data,
    required int statusCode,
    required bool success,
  }) = _QamariDateModel;

  factory QamariDateModel.fromJson(Map<String, dynamic> json) =>
      _$QamariDateModelFromJson(json);
}

@freezed
class QamariData with _$QamariData {
  const factory QamariData({
    required String gDate,
    required int hDay,
    required int hMonth,
    required int hYear,
  }) = _QamariData;

  factory QamariData.fromJson(Map<String, dynamic> json) =>
      _$QamariDataFromJson(json);
}
