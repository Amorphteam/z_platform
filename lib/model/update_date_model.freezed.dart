// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_date_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UpdateDate {
  String get data => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UpdateDateCopyWith<UpdateDate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateDateCopyWith<$Res> {
  factory $UpdateDateCopyWith(
          UpdateDate value, $Res Function(UpdateDate) then) =
      _$UpdateDateCopyWithImpl<$Res, UpdateDate>;
  @useResult
  $Res call({String data, int statusCode, bool success});
}

/// @nodoc
class _$UpdateDateCopyWithImpl<$Res, $Val extends UpdateDate>
    implements $UpdateDateCopyWith<$Res> {
  _$UpdateDateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
              as String,
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
abstract class _$$UpdateDateImplCopyWith<$Res>
    implements $UpdateDateCopyWith<$Res> {
  factory _$$UpdateDateImplCopyWith(
          _$UpdateDateImpl value, $Res Function(_$UpdateDateImpl) then) =
      __$$UpdateDateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String data, int statusCode, bool success});
}

/// @nodoc
class __$$UpdateDateImplCopyWithImpl<$Res>
    extends _$UpdateDateCopyWithImpl<$Res, _$UpdateDateImpl>
    implements _$$UpdateDateImplCopyWith<$Res> {
  __$$UpdateDateImplCopyWithImpl(
      _$UpdateDateImpl _value, $Res Function(_$UpdateDateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? statusCode = null,
    Object? success = null,
  }) {
    return _then(_$UpdateDateImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
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

class _$UpdateDateImpl implements _UpdateDate {
  const _$UpdateDateImpl(
      {required this.data, required this.statusCode, required this.success});

  @override
  final String data;
  @override
  final int statusCode;
  @override
  final bool success;

  @override
  String toString() {
    return 'UpdateDate(data: $data, statusCode: $statusCode, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateDateImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.success, success) || other.success == success));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, statusCode, success);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateDateImplCopyWith<_$UpdateDateImpl> get copyWith =>
      __$$UpdateDateImplCopyWithImpl<_$UpdateDateImpl>(this, _$identity);
}

abstract class _UpdateDate implements UpdateDate {
  const factory _UpdateDate(
      {required final String data,
      required final int statusCode,
      required final bool success}) = _$UpdateDateImpl;

  @override
  String get data;
  @override
  int get statusCode;
  @override
  bool get success;
  @override
  @JsonKey(ignore: true)
  _$$UpdateDateImplCopyWith<_$UpdateDateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
