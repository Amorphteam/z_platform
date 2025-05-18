// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qamari_date_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QamariDateModel _$QamariDateModelFromJson(Map<String, dynamic> json) {
  return _QamariDateModel.fromJson(json);
}

/// @nodoc
mixin _$QamariDateModel {
  List<QamariData> get data => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;

  /// Serializes this QamariDateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QamariDateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QamariDateModelCopyWith<QamariDateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QamariDateModelCopyWith<$Res> {
  factory $QamariDateModelCopyWith(
          QamariDateModel value, $Res Function(QamariDateModel) then) =
      _$QamariDateModelCopyWithImpl<$Res, QamariDateModel>;
  @useResult
  $Res call({List<QamariData> data, int statusCode, bool success});
}

/// @nodoc
class _$QamariDateModelCopyWithImpl<$Res, $Val extends QamariDateModel>
    implements $QamariDateModelCopyWith<$Res> {
  _$QamariDateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QamariDateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? statusCode = null,
    Object? success = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<QamariData>,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QamariDateModelImplCopyWith<$Res>
    implements $QamariDateModelCopyWith<$Res> {
  factory _$$QamariDateModelImplCopyWith(_$QamariDateModelImpl value,
          $Res Function(_$QamariDateModelImpl) then) =
      __$$QamariDateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<QamariData> data, int statusCode, bool success});
}

/// @nodoc
class __$$QamariDateModelImplCopyWithImpl<$Res>
    extends _$QamariDateModelCopyWithImpl<$Res, _$QamariDateModelImpl>
    implements _$$QamariDateModelImplCopyWith<$Res> {
  __$$QamariDateModelImplCopyWithImpl(
      _$QamariDateModelImpl _value, $Res Function(_$QamariDateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of QamariDateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? statusCode = null,
    Object? success = null,
  }) {
    return _then(_$QamariDateModelImpl(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<QamariData>,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QamariDateModelImpl implements _QamariDateModel {
  const _$QamariDateModelImpl(
      {required final List<QamariData> data,
      required this.statusCode,
      required this.success})
      : _data = data;

  factory _$QamariDateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QamariDateModelImplFromJson(json);

  final List<QamariData> _data;
  @override
  List<QamariData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final int statusCode;
  @override
  final bool success;

  @override
  String toString() {
    return 'QamariDateModel(data: $data, statusCode: $statusCode, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QamariDateModelImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.success, success) || other.success == success));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_data), statusCode, success);

  /// Create a copy of QamariDateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QamariDateModelImplCopyWith<_$QamariDateModelImpl> get copyWith =>
      __$$QamariDateModelImplCopyWithImpl<_$QamariDateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QamariDateModelImplToJson(
      this,
    );
  }
}

abstract class _QamariDateModel implements QamariDateModel {
  const factory _QamariDateModel(
      {required final List<QamariData> data,
      required final int statusCode,
      required final bool success}) = _$QamariDateModelImpl;

  factory _QamariDateModel.fromJson(Map<String, dynamic> json) =
      _$QamariDateModelImpl.fromJson;

  @override
  List<QamariData> get data;
  @override
  int get statusCode;
  @override
  bool get success;

  /// Create a copy of QamariDateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QamariDateModelImplCopyWith<_$QamariDateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QamariData _$QamariDataFromJson(Map<String, dynamic> json) {
  return _QamariData.fromJson(json);
}

/// @nodoc
mixin _$QamariData {
  String get gDate => throw _privateConstructorUsedError;
  int get hDay => throw _privateConstructorUsedError;
  int get hMonth => throw _privateConstructorUsedError;
  int get hYear => throw _privateConstructorUsedError;

  /// Serializes this QamariData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QamariData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QamariDataCopyWith<QamariData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QamariDataCopyWith<$Res> {
  factory $QamariDataCopyWith(
          QamariData value, $Res Function(QamariData) then) =
      _$QamariDataCopyWithImpl<$Res, QamariData>;
  @useResult
  $Res call({String gDate, int hDay, int hMonth, int hYear});
}

/// @nodoc
class _$QamariDataCopyWithImpl<$Res, $Val extends QamariData>
    implements $QamariDataCopyWith<$Res> {
  _$QamariDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QamariData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gDate = null,
    Object? hDay = null,
    Object? hMonth = null,
    Object? hYear = null,
  }) {
    return _then(_value.copyWith(
      gDate: null == gDate
          ? _value.gDate
          : gDate // ignore: cast_nullable_to_non_nullable
              as String,
      hDay: null == hDay
          ? _value.hDay
          : hDay // ignore: cast_nullable_to_non_nullable
              as int,
      hMonth: null == hMonth
          ? _value.hMonth
          : hMonth // ignore: cast_nullable_to_non_nullable
              as int,
      hYear: null == hYear
          ? _value.hYear
          : hYear // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QamariDataImplCopyWith<$Res>
    implements $QamariDataCopyWith<$Res> {
  factory _$$QamariDataImplCopyWith(
          _$QamariDataImpl value, $Res Function(_$QamariDataImpl) then) =
      __$$QamariDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String gDate, int hDay, int hMonth, int hYear});
}

/// @nodoc
class __$$QamariDataImplCopyWithImpl<$Res>
    extends _$QamariDataCopyWithImpl<$Res, _$QamariDataImpl>
    implements _$$QamariDataImplCopyWith<$Res> {
  __$$QamariDataImplCopyWithImpl(
      _$QamariDataImpl _value, $Res Function(_$QamariDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of QamariData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gDate = null,
    Object? hDay = null,
    Object? hMonth = null,
    Object? hYear = null,
  }) {
    return _then(_$QamariDataImpl(
      gDate: null == gDate
          ? _value.gDate
          : gDate // ignore: cast_nullable_to_non_nullable
              as String,
      hDay: null == hDay
          ? _value.hDay
          : hDay // ignore: cast_nullable_to_non_nullable
              as int,
      hMonth: null == hMonth
          ? _value.hMonth
          : hMonth // ignore: cast_nullable_to_non_nullable
              as int,
      hYear: null == hYear
          ? _value.hYear
          : hYear // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QamariDataImpl implements _QamariData {
  const _$QamariDataImpl(
      {required this.gDate,
      required this.hDay,
      required this.hMonth,
      required this.hYear});

  factory _$QamariDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$QamariDataImplFromJson(json);

  @override
  final String gDate;
  @override
  final int hDay;
  @override
  final int hMonth;
  @override
  final int hYear;

  @override
  String toString() {
    return 'QamariData(gDate: $gDate, hDay: $hDay, hMonth: $hMonth, hYear: $hYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QamariDataImpl &&
            (identical(other.gDate, gDate) || other.gDate == gDate) &&
            (identical(other.hDay, hDay) || other.hDay == hDay) &&
            (identical(other.hMonth, hMonth) || other.hMonth == hMonth) &&
            (identical(other.hYear, hYear) || other.hYear == hYear));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gDate, hDay, hMonth, hYear);

  /// Create a copy of QamariData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QamariDataImplCopyWith<_$QamariDataImpl> get copyWith =>
      __$$QamariDataImplCopyWithImpl<_$QamariDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QamariDataImplToJson(
      this,
    );
  }
}

abstract class _QamariData implements QamariData {
  const factory _QamariData(
      {required final String gDate,
      required final int hDay,
      required final int hMonth,
      required final int hYear}) = _$QamariDataImpl;

  factory _QamariData.fromJson(Map<String, dynamic> json) =
      _$QamariDataImpl.fromJson;

  @override
  String get gDate;
  @override
  int get hDay;
  @override
  int get hMonth;
  @override
  int get hYear;

  /// Create a copy of QamariData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QamariDataImplCopyWith<_$QamariDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
