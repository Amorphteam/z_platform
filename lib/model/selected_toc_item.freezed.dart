// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_toc_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SelectedTocItem _$SelectedTocItemFromJson(Map<String, dynamic> json) {
  return _SelectedTocItem.fromJson(json);
}

/// @nodoc
mixin _$SelectedTocItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get epub => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SelectedTocItemCopyWith<SelectedTocItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectedTocItemCopyWith<$Res> {
  factory $SelectedTocItemCopyWith(
          SelectedTocItem value, $Res Function(SelectedTocItem) then) =
      _$SelectedTocItemCopyWithImpl<$Res, SelectedTocItem>;
  @useResult
  $Res call({int id, String title, String epub, String section});
}

/// @nodoc
class _$SelectedTocItemCopyWithImpl<$Res, $Val extends SelectedTocItem>
    implements $SelectedTocItemCopyWith<$Res> {
  _$SelectedTocItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? epub = null,
    Object? section = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      epub: null == epub
          ? _value.epub
          : epub // ignore: cast_nullable_to_non_nullable
              as String,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectedTocItemImplCopyWith<$Res>
    implements $SelectedTocItemCopyWith<$Res> {
  factory _$$SelectedTocItemImplCopyWith(_$SelectedTocItemImpl value,
          $Res Function(_$SelectedTocItemImpl) then) =
      __$$SelectedTocItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title, String epub, String section});
}

/// @nodoc
class __$$SelectedTocItemImplCopyWithImpl<$Res>
    extends _$SelectedTocItemCopyWithImpl<$Res, _$SelectedTocItemImpl>
    implements _$$SelectedTocItemImplCopyWith<$Res> {
  __$$SelectedTocItemImplCopyWithImpl(
      _$SelectedTocItemImpl _value, $Res Function(_$SelectedTocItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? epub = null,
    Object? section = null,
  }) {
    return _then(_$SelectedTocItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      epub: null == epub
          ? _value.epub
          : epub // ignore: cast_nullable_to_non_nullable
              as String,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectedTocItemImpl implements _SelectedTocItem {
  const _$SelectedTocItemImpl(
      {required this.id,
      required this.title,
      required this.epub,
      required this.section});

  factory _$SelectedTocItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectedTocItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String epub;
  @override
  final String section;

  @override
  String toString() {
    return 'SelectedTocItem(id: $id, title: $title, epub: $epub, section: $section)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectedTocItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.epub, epub) || other.epub == epub) &&
            (identical(other.section, section) || other.section == section));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, epub, section);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectedTocItemImplCopyWith<_$SelectedTocItemImpl> get copyWith =>
      __$$SelectedTocItemImplCopyWithImpl<_$SelectedTocItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectedTocItemImplToJson(
      this,
    );
  }
}

abstract class _SelectedTocItem implements SelectedTocItem {
  const factory _SelectedTocItem(
      {required final int id,
      required final String title,
      required final String epub,
      required final String section}) = _$SelectedTocItemImpl;

  factory _SelectedTocItem.fromJson(Map<String, dynamic> json) =
      _$SelectedTocItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get epub;
  @override
  String get section;
  @override
  @JsonKey(ignore: true)
  _$$SelectedTocItemImplCopyWith<_$SelectedTocItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
