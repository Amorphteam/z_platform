import 'package:flutter/material.dart';

/// Provides a callback to open the TOC tab with an optional id and title.
/// Used when navigating from "show more" to switch to TOC tab instead of pushing a new route.
class TocNavProvider extends InheritedWidget {
  const TocNavProvider({
    super.key,
    required this.openToc,
    required super.child,
  });

  final void Function(int? id, String? title) openToc;

  static TocNavProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TocNavProvider>();
  }

  static void maybeOpenToc(BuildContext context, int? id, String? title) {
    TocNavProvider.of(context)?.openToc(id, title);
  }

  @override
  bool updateShouldNotify(TocNavProvider oldWidget) =>
      openToc != oldWidget.openToc;
}
