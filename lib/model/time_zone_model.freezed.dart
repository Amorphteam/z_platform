// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_zone_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeZoneModel _$TimeZoneModelFromJson(Map<String, dynamic> json) {
  return _TimeZoneModel.fromJson(json);
}

/// @nodoc
mixin _$TimeZoneModel {
  @JsonKey(name: 'country_code')
  String? get countryCode => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get comments => throw _privateConstructorUsedError;
  String get zone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeZoneModelCopyWith<TimeZoneModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeZoneModelCopyWith<$Res> {
  factory $TimeZoneModelCopyWith(
          TimeZoneModel value, $Res Function(TimeZoneModel) then) =
      _$TimeZoneModelCopyWithImpl<$Res, TimeZoneModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'country_code') String? countryCode,
      double? latitude,
      double? longitude,
      String? comments,
      String zone});
}

/// @nodoc
class _$TimeZoneModelCopyWithImpl<$Res, $Val extends TimeZoneModel>
    implements $TimeZoneModelCopyWith<$Res> {
  _$TimeZoneModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? comments = freezed,
    Object? zone = null,
  }) {
    return _then(_value.copyWith(
      countryCode: freezed == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      comments: freezed == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String?,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeZoneModelImplCopyWith<$Res>
    implements $TimeZoneModelCopyWith<$Res> {
  factory _$$TimeZoneModelImplCopyWith(
          _$TimeZoneModelImpl value, $Res Function(_$TimeZoneModelImpl) then) =
      __$$TimeZoneModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'country_code') String? countryCode,
      double? latitude,
      double? longitude,
      String? comments,
      String zone});
}

/// @nodoc
class __$$TimeZoneModelImplCopyWithImpl<$Res>
    extends _$TimeZoneModelCopyWithImpl<$Res, _$TimeZoneModelImpl>
    implements _$$TimeZoneModelImplCopyWith<$Res> {
  __$$TimeZoneModelImplCopyWithImpl(
      _$TimeZoneModelImpl _value, $Res Function(_$TimeZoneModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? comments = freezed,
    Object? zone = null,
  }) {
    return _then(_$TimeZoneModelImpl(
      countryCode: freezed == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      comments: freezed == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String?,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeZoneModelImpl implements _TimeZoneModel {
  const _$TimeZoneModelImpl(
      {@JsonKey(name: 'country_code') this.countryCode,
      this.latitude,
      this.longitude,
      this.comments,
      required this.zone});

  factory _$TimeZoneModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeZoneModelImplFromJson(json);

  @override
  @JsonKey(name: 'country_code')
  final String? countryCode;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? comments;
  @override
  final String zone;

  @override
  String toString() {
    return 'TimeZoneModel(countryCode: $countryCode, latitude: $latitude, longitude: $longitude, comments: $comments, zone: $zone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeZoneModelImpl &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.zone, zone) || other.zone == zone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, countryCode, latitude, longitude, comments, zone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeZoneModelImplCopyWith<_$TimeZoneModelImpl> get copyWith =>
      __$$TimeZoneModelImplCopyWithImpl<_$TimeZoneModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeZoneModelImplToJson(
      this,
    );
  }
}

abstract class _TimeZoneModel implements TimeZoneModel {
  const factory _TimeZoneModel(
      {@JsonKey(name: 'country_code') final String? countryCode,
      final double? latitude,
      final double? longitude,
      final String? comments,
      required final String zone}) = _$TimeZoneModelImpl;

  factory _TimeZoneModel.fromJson(Map<String, dynamic> json) =
      _$TimeZoneModelImpl.fromJson;

  @override
  @JsonKey(name: 'country_code')
  String? get countryCode;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get comments;
  @override
  String get zone;
  @override
  @JsonKey(ignore: true)
  _$$TimeZoneModelImplCopyWith<_$TimeZoneModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
