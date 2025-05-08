// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'toc_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TocItem _$TocItemFromJson(Map<String, dynamic> json) {
  return _TocItem.fromJson(json);
}

/// @nodoc
mixin _$TocItem {
  int get level => throw _privateConstructorUsedError;
  String? get key => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  int? get parentId => throw _privateConstructorUsedError;
  List<TocItem>? get childs => throw _privateConstructorUsedError;
  List<Items>? get items => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TocItemCopyWith<TocItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TocItemCopyWith<$Res> {
  factory $TocItemCopyWith(TocItem value, $Res Function(TocItem) then) =
      _$TocItemCopyWithImpl<$Res, TocItem>;
  @useResult
  $Res call(
      {int level,
      String? key,
      String title,
      int? id,
      int? parentId,
      List<TocItem>? childs,
      List<Items>? items});
}

/// @nodoc
class _$TocItemCopyWithImpl<$Res, $Val extends TocItem>
    implements $TocItemCopyWith<$Res> {
  _$TocItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? key = freezed,
    Object? title = null,
    Object? id = freezed,
    Object? parentId = freezed,
    Object? childs = freezed,
    Object? items = freezed,
  }) {
    return _then(_value.copyWith(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      childs: freezed == childs
          ? _value.childs
          : childs // ignore: cast_nullable_to_non_nullable
              as List<TocItem>?,
      items: freezed == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Items>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TocItemImplCopyWith<$Res> implements $TocItemCopyWith<$Res> {
  factory _$$TocItemImplCopyWith(
          _$TocItemImpl value, $Res Function(_$TocItemImpl) then) =
      __$$TocItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int level,
      String? key,
      String title,
      int? id,
      int? parentId,
      List<TocItem>? childs,
      List<Items>? items});
}

/// @nodoc
class __$$TocItemImplCopyWithImpl<$Res>
    extends _$TocItemCopyWithImpl<$Res, _$TocItemImpl>
    implements _$$TocItemImplCopyWith<$Res> {
  __$$TocItemImplCopyWithImpl(
      _$TocItemImpl _value, $Res Function(_$TocItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? level = null,
    Object? key = freezed,
    Object? title = null,
    Object? id = freezed,
    Object? parentId = freezed,
    Object? childs = freezed,
    Object? items = freezed,
  }) {
    return _then(_$TocItemImpl(
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      childs: freezed == childs
          ? _value._childs
          : childs // ignore: cast_nullable_to_non_nullable
              as List<TocItem>?,
      items: freezed == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Items>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TocItemImpl implements _TocItem {
  const _$TocItemImpl(
      {required this.level,
      this.key,
      required this.title,
      this.id,
      this.parentId,
      final List<TocItem>? childs = const [],
      final List<Items>? items = const []})
      : _childs = childs,
        _items = items;

  factory _$TocItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TocItemImplFromJson(json);

  @override
  final int level;
  @override
  final String? key;
  @override
  final String title;
  @override
  final int? id;
  @override
  final int? parentId;
  final List<TocItem>? _childs;
  @override
  @JsonKey()
  List<TocItem>? get childs {
    final value = _childs;
    if (value == null) return null;
    if (_childs is EqualUnmodifiableListView) return _childs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Items>? _items;
  @override
  @JsonKey()
  List<Items>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'TocItem(level: $level, key: $key, title: $title, id: $id, parentId: $parentId, childs: $childs, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TocItemImpl &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            const DeepCollectionEquality().equals(other._childs, _childs) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      level,
      key,
      title,
      id,
      parentId,
      const DeepCollectionEquality().hash(_childs),
      const DeepCollectionEquality().hash(_items));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TocItemImplCopyWith<_$TocItemImpl> get copyWith =>
      __$$TocItemImplCopyWithImpl<_$TocItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TocItemImplToJson(
      this,
    );
  }
}

abstract class _TocItem implements TocItem {
  const factory _TocItem(
      {required final int level,
      final String? key,
      required final String title,
      final int? id,
      final int? parentId,
      final List<TocItem>? childs,
      final List<Items>? items}) = _$TocItemImpl;

  factory _TocItem.fromJson(Map<String, dynamic> json) = _$TocItemImpl.fromJson;

  @override
  int get level;
  @override
  String? get key;
  @override
  String get title;
  @override
  int? get id;
  @override
  int? get parentId;
  @override
  List<TocItem>? get childs;
  @override
  List<Items>? get items;
  @override
  @JsonKey(ignore: true)
  _$$TocItemImplCopyWith<_$TocItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Items _$ItemsFromJson(Map<String, dynamic> json) {
  return _Items.fromJson(json);
}

/// @nodoc
mixin _$Items {
  String? get addressType => throw _privateConstructorUsedError;
  int? get addressNo => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ItemsCopyWith<Items> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemsCopyWith<$Res> {
  factory $ItemsCopyWith(Items value, $Res Function(Items) then) =
      _$ItemsCopyWithImpl<$Res, Items>;
  @useResult
  $Res call({String? addressType, int? addressNo, String? text});
}

/// @nodoc
class _$ItemsCopyWithImpl<$Res, $Val extends Items>
    implements $ItemsCopyWith<$Res> {
  _$ItemsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressType = freezed,
    Object? addressNo = freezed,
    Object? text = freezed,
  }) {
    return _then(_value.copyWith(
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      addressNo: freezed == addressNo
          ? _value.addressNo
          : addressNo // ignore: cast_nullable_to_non_nullable
              as int?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemsImplCopyWith<$Res> implements $ItemsCopyWith<$Res> {
  factory _$$ItemsImplCopyWith(
          _$ItemsImpl value, $Res Function(_$ItemsImpl) then) =
      __$$ItemsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? addressType, int? addressNo, String? text});
}

/// @nodoc
class __$$ItemsImplCopyWithImpl<$Res>
    extends _$ItemsCopyWithImpl<$Res, _$ItemsImpl>
    implements _$$ItemsImplCopyWith<$Res> {
  __$$ItemsImplCopyWithImpl(
      _$ItemsImpl _value, $Res Function(_$ItemsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? addressType = freezed,
    Object? addressNo = freezed,
    Object? text = freezed,
  }) {
    return _then(_$ItemsImpl(
      addressType: freezed == addressType
          ? _value.addressType
          : addressType // ignore: cast_nullable_to_non_nullable
              as String?,
      addressNo: freezed == addressNo
          ? _value.addressNo
          : addressNo // ignore: cast_nullable_to_non_nullable
              as int?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemsImpl implements _Items {
  const _$ItemsImpl({this.addressType, this.addressNo, this.text});

  factory _$ItemsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemsImplFromJson(json);

  @override
  final String? addressType;
  @override
  final int? addressNo;
  @override
  final String? text;

  @override
  String toString() {
    return 'Items(addressType: $addressType, addressNo: $addressNo, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemsImpl &&
            (identical(other.addressType, addressType) ||
                other.addressType == addressType) &&
            (identical(other.addressNo, addressNo) ||
                other.addressNo == addressNo) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, addressType, addressNo, text);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemsImplCopyWith<_$ItemsImpl> get copyWith =>
      __$$ItemsImplCopyWithImpl<_$ItemsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemsImplToJson(
      this,
    );
  }
}

abstract class _Items implements Items {
  const factory _Items(
      {final String? addressType,
      final int? addressNo,
      final String? text}) = _$ItemsImpl;

  factory _Items.fromJson(Map<String, dynamic> json) = _$ItemsImpl.fromJson;

  @override
  String? get addressType;
  @override
  int? get addressNo;
  @override
  String? get text;
  @override
  @JsonKey(ignore: true)
  _$$ItemsImplCopyWith<_$ItemsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
