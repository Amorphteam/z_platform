// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onscreen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Onscreen _$OnscreenFromJson(Map<String, dynamic> json) {
  return _Onscreen.fromJson(json);
}

/// @nodoc
mixin _$Onscreen {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'text_ar')
  String get textAr => throw _privateConstructorUsedError;

  /// Serializes this Onscreen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Onscreen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnscreenCopyWith<Onscreen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnscreenCopyWith<$Res> {
  factory $OnscreenCopyWith(Onscreen value, $Res Function(Onscreen) then) =
      _$OnscreenCopyWithImpl<$Res, Onscreen>;
  @useResult
  $Res call({int id, @JsonKey(name: 'text_ar') String textAr});
}

/// @nodoc
class _$OnscreenCopyWithImpl<$Res, $Val extends Onscreen>
    implements $OnscreenCopyWith<$Res> {
  _$OnscreenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Onscreen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? textAr = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      textAr: null == textAr
          ? _value.textAr
          : textAr // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnscreenImplCopyWith<$Res>
    implements $OnscreenCopyWith<$Res> {
  factory _$$OnscreenImplCopyWith(
          _$OnscreenImpl value, $Res Function(_$OnscreenImpl) then) =
      __$$OnscreenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, @JsonKey(name: 'text_ar') String textAr});
}

/// @nodoc
class __$$OnscreenImplCopyWithImpl<$Res>
    extends _$OnscreenCopyWithImpl<$Res, _$OnscreenImpl>
    implements _$$OnscreenImplCopyWith<$Res> {
  __$$OnscreenImplCopyWithImpl(
      _$OnscreenImpl _value, $Res Function(_$OnscreenImpl) _then)
      : super(_value, _then);

  /// Create a copy of Onscreen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? textAr = null,
  }) {
    return _then(_$OnscreenImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      textAr: null == textAr
          ? _value.textAr
          : textAr // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OnscreenImpl implements _Onscreen {
  const _$OnscreenImpl(
      {required this.id, @JsonKey(name: 'text_ar') required this.textAr});

  factory _$OnscreenImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnscreenImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'text_ar')
  final String textAr;

  @override
  String toString() {
    return 'Onscreen(id: $id, textAr: $textAr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnscreenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.textAr, textAr) || other.textAr == textAr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, textAr);

  /// Create a copy of Onscreen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnscreenImplCopyWith<_$OnscreenImpl> get copyWith =>
      __$$OnscreenImplCopyWithImpl<_$OnscreenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OnscreenImplToJson(
      this,
    );
  }
}

abstract class _Onscreen implements Onscreen {
  const factory _Onscreen(
      {required final int id,
      @JsonKey(name: 'text_ar') required final String textAr}) = _$OnscreenImpl;

  factory _Onscreen.fromJson(Map<String, dynamic> json) =
      _$OnscreenImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'text_ar')
  String get textAr;

  /// Create a copy of Onscreen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnscreenImplCopyWith<_$OnscreenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
