// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_page_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookPageModel _$BookPageModelFromJson(Map<String, dynamic> json) {
  return _BookPageModel.fromJson(json);
}

/// @nodoc
mixin _$BookPageModel {
  @JsonKey(name: 'book_id')
  int get bookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_num')
  int get pageNum => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookPageModelCopyWith<BookPageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookPageModelCopyWith<$Res> {
  factory $BookPageModelCopyWith(
          BookPageModel value, $Res Function(BookPageModel) then) =
      _$BookPageModelCopyWithImpl<$Res, BookPageModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'book_id') int bookId,
      @JsonKey(name: 'page_num') int pageNum,
      String text});
}

/// @nodoc
class _$BookPageModelCopyWithImpl<$Res, $Val extends BookPageModel>
    implements $BookPageModelCopyWith<$Res> {
  _$BookPageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? pageNum = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      pageNum: null == pageNum
          ? _value.pageNum
          : pageNum // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookPageModelImplCopyWith<$Res>
    implements $BookPageModelCopyWith<$Res> {
  factory _$$BookPageModelImplCopyWith(
          _$BookPageModelImpl value, $Res Function(_$BookPageModelImpl) then) =
      __$$BookPageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'book_id') int bookId,
      @JsonKey(name: 'page_num') int pageNum,
      String text});
}

/// @nodoc
class __$$BookPageModelImplCopyWithImpl<$Res>
    extends _$BookPageModelCopyWithImpl<$Res, _$BookPageModelImpl>
    implements _$$BookPageModelImplCopyWith<$Res> {
  __$$BookPageModelImplCopyWithImpl(
      _$BookPageModelImpl _value, $Res Function(_$BookPageModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? pageNum = null,
    Object? text = null,
  }) {
    return _then(_$BookPageModelImpl(
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      pageNum: null == pageNum
          ? _value.pageNum
          : pageNum // ignore: cast_nullable_to_non_nullable
              as int,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookPageModelImpl implements _BookPageModel {
  const _$BookPageModelImpl(
      {@JsonKey(name: 'book_id') required this.bookId,
      @JsonKey(name: 'page_num') required this.pageNum,
      required this.text});

  factory _$BookPageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookPageModelImplFromJson(json);

  @override
  @JsonKey(name: 'book_id')
  final int bookId;
  @override
  @JsonKey(name: 'page_num')
  final int pageNum;
  @override
  final String text;

  @override
  String toString() {
    return 'BookPageModel(bookId: $bookId, pageNum: $pageNum, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookPageModelImpl &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.pageNum, pageNum) || other.pageNum == pageNum) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, bookId, pageNum, text);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookPageModelImplCopyWith<_$BookPageModelImpl> get copyWith =>
      __$$BookPageModelImplCopyWithImpl<_$BookPageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookPageModelImplToJson(
      this,
    );
  }
}

abstract class _BookPageModel implements BookPageModel {
  const factory _BookPageModel(
      {@JsonKey(name: 'book_id') required final int bookId,
      @JsonKey(name: 'page_num') required final int pageNum,
      required final String text}) = _$BookPageModelImpl;

  factory _BookPageModel.fromJson(Map<String, dynamic> json) =
      _$BookPageModelImpl.fromJson;

  @override
  @JsonKey(name: 'book_id')
  int get bookId;
  @override
  @JsonKey(name: 'page_num')
  int get pageNum;
  @override
  String get text;
  @override
  @JsonKey(ignore: true)
  _$$BookPageModelImplCopyWith<_$BookPageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookPagesResponse _$BookPagesResponseFromJson(Map<String, dynamic> json) {
  return _BookPagesResponse.fromJson(json);
}

/// @nodoc
mixin _$BookPagesResponse {
  bool get success => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  BookPagesData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookPagesResponseCopyWith<BookPagesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookPagesResponseCopyWith<$Res> {
  factory $BookPagesResponseCopyWith(
          BookPagesResponse value, $Res Function(BookPagesResponse) then) =
      _$BookPagesResponseCopyWithImpl<$Res, BookPagesResponse>;
  @useResult
  $Res call({bool success, int statusCode, BookPagesData data});

  $BookPagesDataCopyWith<$Res> get data;
}

/// @nodoc
class _$BookPagesResponseCopyWithImpl<$Res, $Val extends BookPagesResponse>
    implements $BookPagesResponseCopyWith<$Res> {
  _$BookPagesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? statusCode = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as BookPagesData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $BookPagesDataCopyWith<$Res> get data {
    return $BookPagesDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookPagesResponseImplCopyWith<$Res>
    implements $BookPagesResponseCopyWith<$Res> {
  factory _$$BookPagesResponseImplCopyWith(_$BookPagesResponseImpl value,
          $Res Function(_$BookPagesResponseImpl) then) =
      __$$BookPagesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, int statusCode, BookPagesData data});

  @override
  $BookPagesDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$BookPagesResponseImplCopyWithImpl<$Res>
    extends _$BookPagesResponseCopyWithImpl<$Res, _$BookPagesResponseImpl>
    implements _$$BookPagesResponseImplCopyWith<$Res> {
  __$$BookPagesResponseImplCopyWithImpl(_$BookPagesResponseImpl _value,
      $Res Function(_$BookPagesResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? statusCode = null,
    Object? data = null,
  }) {
    return _then(_$BookPagesResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as BookPagesData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookPagesResponseImpl implements _BookPagesResponse {
  const _$BookPagesResponseImpl(
      {required this.success, required this.statusCode, required this.data});

  factory _$BookPagesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookPagesResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final int statusCode;
  @override
  final BookPagesData data;

  @override
  String toString() {
    return 'BookPagesResponse(success: $success, statusCode: $statusCode, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookPagesResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, statusCode, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookPagesResponseImplCopyWith<_$BookPagesResponseImpl> get copyWith =>
      __$$BookPagesResponseImplCopyWithImpl<_$BookPagesResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookPagesResponseImplToJson(
      this,
    );
  }
}

abstract class _BookPagesResponse implements BookPagesResponse {
  const factory _BookPagesResponse(
      {required final bool success,
      required final int statusCode,
      required final BookPagesData data}) = _$BookPagesResponseImpl;

  factory _BookPagesResponse.fromJson(Map<String, dynamic> json) =
      _$BookPagesResponseImpl.fromJson;

  @override
  bool get success;
  @override
  int get statusCode;
  @override
  BookPagesData get data;
  @override
  @JsonKey(ignore: true)
  _$$BookPagesResponseImplCopyWith<_$BookPagesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookPagesData _$BookPagesDataFromJson(Map<String, dynamic> json) {
  return _BookPagesData.fromJson(json);
}

/// @nodoc
mixin _$BookPagesData {
  List<BookPageModel> get records => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookPagesDataCopyWith<BookPagesData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookPagesDataCopyWith<$Res> {
  factory $BookPagesDataCopyWith(
          BookPagesData value, $Res Function(BookPagesData) then) =
      _$BookPagesDataCopyWithImpl<$Res, BookPagesData>;
  @useResult
  $Res call({List<BookPageModel> records, int total});
}

/// @nodoc
class _$BookPagesDataCopyWithImpl<$Res, $Val extends BookPagesData>
    implements $BookPagesDataCopyWith<$Res> {
  _$BookPagesDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<BookPageModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookPagesDataImplCopyWith<$Res>
    implements $BookPagesDataCopyWith<$Res> {
  factory _$$BookPagesDataImplCopyWith(
          _$BookPagesDataImpl value, $Res Function(_$BookPagesDataImpl) then) =
      __$$BookPagesDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BookPageModel> records, int total});
}

/// @nodoc
class __$$BookPagesDataImplCopyWithImpl<$Res>
    extends _$BookPagesDataCopyWithImpl<$Res, _$BookPagesDataImpl>
    implements _$$BookPagesDataImplCopyWith<$Res> {
  __$$BookPagesDataImplCopyWithImpl(
      _$BookPagesDataImpl _value, $Res Function(_$BookPagesDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? total = null,
  }) {
    return _then(_$BookPagesDataImpl(
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<BookPageModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookPagesDataImpl implements _BookPagesData {
  const _$BookPagesDataImpl(
      {required final List<BookPageModel> records, required this.total})
      : _records = records;

  factory _$BookPagesDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookPagesDataImplFromJson(json);

  final List<BookPageModel> _records;
  @override
  List<BookPageModel> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  final int total;

  @override
  String toString() {
    return 'BookPagesData(records: $records, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookPagesDataImpl &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_records), total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookPagesDataImplCopyWith<_$BookPagesDataImpl> get copyWith =>
      __$$BookPagesDataImplCopyWithImpl<_$BookPagesDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookPagesDataImplToJson(
      this,
    );
  }
}

abstract class _BookPagesData implements BookPagesData {
  const factory _BookPagesData(
      {required final List<BookPageModel> records,
      required final int total}) = _$BookPagesDataImpl;

  factory _BookPagesData.fromJson(Map<String, dynamic> json) =
      _$BookPagesDataImpl.fromJson;

  @override
  List<BookPageModel> get records;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$BookPagesDataImplCopyWith<_$BookPagesDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
