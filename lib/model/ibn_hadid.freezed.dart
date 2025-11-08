// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ibn_hadid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IbnHadid _$IbnHadidFromJson(Map<String, dynamic> json) {
  return _IbnHadid.fromJson(json);
}

/// @nodoc
mixin _$IbnHadid {
  int get id => throw _privateConstructorUsedError;
  String get det => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
  bool get isFavorite => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IbnHadidCopyWith<IbnHadid> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IbnHadidCopyWith<$Res> {
  factory $IbnHadidCopyWith(IbnHadid value, $Res Function(IbnHadid) then) =
      _$IbnHadidCopyWithImpl<$Res, IbnHadid>;
  @useResult
  $Res call(
      {int id,
      String det,
      @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
      bool isFavorite});
}

/// @nodoc
class _$IbnHadidCopyWithImpl<$Res, $Val extends IbnHadid>
    implements $IbnHadidCopyWith<$Res> {
  _$IbnHadidCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? det = null,
    Object? isFavorite = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      det: null == det
          ? _value.det
          : det // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IbnHadidImplCopyWith<$Res>
    implements $IbnHadidCopyWith<$Res> {
  factory _$$IbnHadidImplCopyWith(
          _$IbnHadidImpl value, $Res Function(_$IbnHadidImpl) then) =
      __$$IbnHadidImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String det,
      @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
      bool isFavorite});
}

/// @nodoc
class __$$IbnHadidImplCopyWithImpl<$Res>
    extends _$IbnHadidCopyWithImpl<$Res, _$IbnHadidImpl>
    implements _$$IbnHadidImplCopyWith<$Res> {
  __$$IbnHadidImplCopyWithImpl(
      _$IbnHadidImpl _value, $Res Function(_$IbnHadidImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? det = null,
    Object? isFavorite = null,
  }) {
    return _then(_$IbnHadidImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      det: null == det
          ? _value.det
          : det // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IbnHadidImpl implements _IbnHadid {
  const _$IbnHadidImpl(
      {required this.id,
      required this.det,
      @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
      this.isFavorite = false});

  factory _$IbnHadidImpl.fromJson(Map<String, dynamic> json) =>
      _$$IbnHadidImplFromJson(json);

  @override
  final int id;
  @override
  final String det;
  @override
  @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
  final bool isFavorite;

  @override
  String toString() {
    return 'IbnHadid(id: $id, det: $det, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IbnHadidImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.det, det) || other.det == det) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, det, isFavorite);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IbnHadidImplCopyWith<_$IbnHadidImpl> get copyWith =>
      __$$IbnHadidImplCopyWithImpl<_$IbnHadidImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IbnHadidImplToJson(
      this,
    );
  }
}

abstract class _IbnHadid implements IbnHadid {
  const factory _IbnHadid(
      {required final int id,
      required final String det,
      @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
      final bool isFavorite}) = _$IbnHadidImpl;

  factory _IbnHadid.fromJson(Map<String, dynamic> json) =
      _$IbnHadidImpl.fromJson;

  @override
  int get id;
  @override
  String get det;
  @override
  @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
  bool get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$IbnHadidImplCopyWith<_$IbnHadidImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
