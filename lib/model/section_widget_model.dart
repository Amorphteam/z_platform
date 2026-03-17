import 'item_model.dart';

/// Section widget with title, subtitle, show more, and items.
/// Each of the 4 section types shares the same structure; only the items layout differs.
class SectionWidgetModel {
  const SectionWidgetModel({
    required this.title,
    this.subtitle,
    this.showMoreLink,
    this.showMoreUrl,
    required this.items,
    required this.layout,
  });

  final String title;
  final String? subtitle;
  final LinkTo? showMoreLink;
  final String? showMoreUrl;
  final List<SectionItem> items;
  /// Layout: fullWidthImages | halfWidthItems | thumbnail2x2 | thumbnail3x3
  final String layout;

  /// Parses showMoreLink only when visible is true. When visible, uses jsonList with id.
  static LinkTo? _parseShowMoreLink(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return null;
    final visible = json['visible'] as bool? ?? false;
    if (!visible) return null;
    final goto = json['goto'] as String?;
    final id = (json['id'] as num?)?.toInt();
    if (goto == null || goto.isEmpty || id == null) return null;
    return LinkTo(goto: goto, key: json['key'] as String?, id: id);
  }

  factory SectionWidgetModel.fromJson(Map<String, dynamic> json, {required String layout}) {
    return SectionWidgetModel(
      title: json['title'] as String? ?? '',
      subtitle: (json['subtitle'] ?? json['subTitle']) as String?,
      showMoreLink: _parseShowMoreLink(json['showMoreLink']),
      showMoreUrl: json['showMoreUrl'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SectionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      layout: layout,
    );
  }
}

class SectionItem {
  const SectionItem({
    this.picName,
    this.title,
    this.goto,
    this.key,
    this.id,
    this.items = const [],
  });

  final String? picName;
  final String? title;
  final String? goto;
  final String? key;
  final int? id;
  final List<SectionSubItem> items;

  factory SectionItem.fromJson(Map<String, dynamic> json) {
    return SectionItem(
      picName: (json['picName'] ?? json['imageName']) as String?,
      title: json['title'] as String?,
      goto: json['goto'] as String?,
      key: json['key'] as String?,
      id: (json['id'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SectionSubItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SectionSubItem {
  const SectionSubItem({
    this.title,
    this.goto,
    this.key,
    this.id,
  });

  final String? title;
  final String? goto;
  final String? key;
  final int? id;

  factory SectionSubItem.fromJson(Map<String, dynamic> json) {
    return SectionSubItem(
      title: json['title'] as String?,
      goto: json['goto'] as String?,
      key: json['key'] as String?,
      id: (json['id'] as num?)?.toInt(),
    );
  }
}
