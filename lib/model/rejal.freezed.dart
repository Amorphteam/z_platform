// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rejal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Rejal _$RejalFromJson(Map<String, dynamic> json) {
  return _Rejal.fromJson(json);
}

/// @nodoc
mixin _$Rejal {
  int? get ID => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get name2 => throw _privateConstructorUsedError;
  String get det => throw _privateConstructorUsedError;
  int get joz => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  String get harf => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RejalCopyWith<Rejal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RejalCopyWith<$Res> {
  factory $RejalCopyWith(Rejal value, $Res Function(Rejal) then) =
      _$RejalCopyWithImpl<$Res, Rejal>;
  @useResult
  $Res call(
      {int? ID,
      String name,
      String name2,
      String det,
      int joz,
      int page,
      String harf});
}

/// @nodoc
class _$RejalCopyWithImpl<$Res, $Val extends Rejal>
    implements $RejalCopyWith<$Res> {
  _$RejalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ID = freezed,
    Object? name = null,
    Object? name2 = null,
    Object? det = null,
    Object? joz = null,
    Object? page = null,
    Object? harf = null,
  }) {
    return _then(_value.copyWith(
      ID: freezed == ID
          ? _value.ID
          : ID // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      name2: null == name2
          ? _value.name2
          : name2 // ignore: cast_nullable_to_non_nullable
              as String,
      det: null == det
          ? _value.det
          : det // ignore: cast_nullable_to_non_nullable
              as String,
      joz: null == joz
          ? _value.joz
          : joz // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      harf: null == harf
          ? _value.harf
          : harf // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RejalImplCopyWith<$Res> implements $RejalCopyWith<$Res> {
  factory _$$RejalImplCopyWith(
          _$RejalImpl value, $Res Function(_$RejalImpl) then) =
      __$$RejalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? ID,
      String name,
      String name2,
      String det,
      int joz,
      int page,
      String harf});
}

/// @nodoc
class __$$RejalImplCopyWithImpl<$Res>
    extends _$RejalCopyWithImpl<$Res, _$RejalImpl>
    implements _$$RejalImplCopyWith<$Res> {
  __$$RejalImplCopyWithImpl(
      _$RejalImpl _value, $Res Function(_$RejalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ID = freezed,
    Object? name = null,
    Object? name2 = null,
    Object? det = null,
    Object? joz = null,
    Object? page = null,
    Object? harf = null,
  }) {
    return _then(_$RejalImpl(
      ID: freezed == ID
          ? _value.ID
          : ID // ignore: cast_nullable_to_non_nullable
              as int?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      name2: null == name2
          ? _value.name2
          : name2 // ignore: cast_nullable_to_non_nullable
              as String,
      det: null == det
          ? _value.det
          : det // ignore: cast_nullable_to_non_nullable
              as String,
      joz: null == joz
          ? _value.joz
          : joz // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      harf: null == harf
          ? _value.harf
          : harf // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RejalImpl implements _Rejal {
  _$RejalImpl(
      {this.ID = null,
      required this.name,
      required this.name2,
      required this.det,
      required this.joz,
      required this.page,
      required this.harf});

  factory _$RejalImpl.fromJson(Map<String, dynamic> json) =>
      _$$RejalImplFromJson(json);

  @override
  @JsonKey()
  final int? ID;
  @override
  final String name;
  @override
  final String name2;
  @override
  final String det;
  @override
  final int joz;
  @override
  final int page;
  @override
  final String harf;

  @override
  String toString() {
    return 'Rejal(ID: $ID, name: $name, name2: $name2, det: $det, joz: $joz, page: $page, harf: $harf)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RejalImpl &&
            (identical(other.ID, ID) || other.ID == ID) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.name2, name2) || other.name2 == name2) &&
            (identical(other.det, det) || other.det == det) &&
            (identical(other.joz, joz) || other.joz == joz) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.harf, harf) || other.harf == harf));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, ID, name, name2, det, joz, page, harf);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RejalImplCopyWith<_$RejalImpl> get copyWith =>
      __$$RejalImplCopyWithImpl<_$RejalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RejalImplToJson(
      this,
    );
  }
}

abstract class _Rejal implements Rejal {
  factory _Rejal(
      {final int? ID,
      required final String name,
      required final String name2,
      required final String det,
      required final int joz,
      required final int page,
      required final String harf}) = _$RejalImpl;

  factory _Rejal.fromJson(Map<String, dynamic> json) = _$RejalImpl.fromJson;

  @override
  int? get ID;
  @override
  String get name;
  @override
  String get name2;
  @override
  String get det;
  @override
  int get joz;
  @override
  int get page;
  @override
  String get harf;
  @override
  @JsonKey(ignore: true)
  _$$RejalImplCopyWith<_$RejalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
