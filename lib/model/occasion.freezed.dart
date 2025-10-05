// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occasion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Occasion _$OccasionFromJson(Map<String, dynamic> json) {
  return _Occasion.fromJson(json);
}

/// @nodoc
mixin _$Occasion {
  int get day => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  String get occasion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OccasionCopyWith<Occasion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OccasionCopyWith<$Res> {
  factory $OccasionCopyWith(Occasion value, $Res Function(Occasion) then) =
      _$OccasionCopyWithImpl<$Res, Occasion>;
  @useResult
  $Res call({int day, int month, String occasion});
}

/// @nodoc
class _$OccasionCopyWithImpl<$Res, $Val extends Occasion>
    implements $OccasionCopyWith<$Res> {
  _$OccasionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? month = null,
    Object? occasion = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      occasion: null == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OccasionImplCopyWith<$Res>
    implements $OccasionCopyWith<$Res> {
  factory _$$OccasionImplCopyWith(
          _$OccasionImpl value, $Res Function(_$OccasionImpl) then) =
      __$$OccasionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int day, int month, String occasion});
}

/// @nodoc
class __$$OccasionImplCopyWithImpl<$Res>
    extends _$OccasionCopyWithImpl<$Res, _$OccasionImpl>
    implements _$$OccasionImplCopyWith<$Res> {
  __$$OccasionImplCopyWithImpl(
      _$OccasionImpl _value, $Res Function(_$OccasionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? month = null,
    Object? occasion = null,
  }) {
    return _then(_$OccasionImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      occasion: null == occasion
          ? _value.occasion
          : occasion // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OccasionImpl implements _Occasion {
  const _$OccasionImpl(
      {required this.day, required this.month, required this.occasion});

  factory _$OccasionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OccasionImplFromJson(json);

  @override
  final int day;
  @override
  final int month;
  @override
  final String occasion;

  @override
  String toString() {
    return 'Occasion(day: $day, month: $month, occasion: $occasion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OccasionImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, day, month, occasion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OccasionImplCopyWith<_$OccasionImpl> get copyWith =>
      __$$OccasionImplCopyWithImpl<_$OccasionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OccasionImplToJson(
      this,
    );
  }
}

abstract class _Occasion implements Occasion {
  const factory _Occasion(
      {required final int day,
      required final int month,
      required final String occasion}) = _$OccasionImpl;

  factory _Occasion.fromJson(Map<String, dynamic> json) =
      _$OccasionImpl.fromJson;

  @override
  int get day;
  @override
  int get month;
  @override
  String get occasion;
  @override
  @JsonKey(ignore: true)
  _$$OccasionImplCopyWith<_$OccasionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
