import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_zone_model.freezed.dart';
part 'time_zone_model.g.dart';

@freezed
class TimeZoneModel with _$TimeZoneModel {
  const factory TimeZoneModel({
    @JsonKey(name: 'country_code') String? countryCode,
    double? latitude,
    double? longitude,
    String? comments,
    required String zone,
  }) = _TimeZoneModel;

  factory TimeZoneModel.fromJson(Map<String, dynamic> json) =>
      _$TimeZoneModelFromJson(json);
}
