import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/item_model.dart';
import '../model/section_widget_model.dart';
import '../util/navigation_helper.dart';
import 'common_style.dart';

const _defaultImage = 'assets/image/icon1024.png';

String _imageAsset(SectionItem item) {
  return item.picName != null && item.picName!.isNotEmpty
      ? 'assets/image/${item.picName}'
      : _defaultImage;
}

/// Builds image or SVG for a section item. Use for any size; supports .svg (SvgPicture) and raster (Image.asset).
/// [width]/[height] null means expand to fill; use [boxFit] for full-width cards.
Widget _sectionItemImage(
  BuildContext context,
  SectionItem item, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  final path = _imageAsset(item);
  final isSvg = path.toLowerCase().endsWith('.svg');
  final effectiveRadius = borderRadius ?? BorderRadius.circular(4);

  if (isSvg) {
    return ClipRRect(
      borderRadius: effectiveRadius,
      child: SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _defaultImagePlaceholder(width, height),
      ),
    );
  }
  return ClipRRect(
    borderRadius: effectiveRadius,
    child: Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _defaultImagePlaceholder(width, height),
    ),
  );
}

Widget _defaultImagePlaceholder(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFE0E0E0),
    child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF9E9E9E)),
  );
}

Widget _leadingImage(BuildContext context, SectionItem item, {double size = 40}) {
  return _sectionItemImage(context, item, width: size, height: size, fit: BoxFit.contain);
}

class SectionWidget extends StatelessWidget {
  const SectionWidget({super.key, required this.section});
  final SectionWidgetModel section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: section.title,
            subtitle: section.subtitle,
            showMoreLink: section.showMoreLink,
            showMoreUrl: section.showMoreUrl,
          ),
          const SizedBox(height: 8),
          _buildItemsLayout(context),
        ],
      ),
    );
  }

  Widget _buildItemsLayout(BuildContext context) {
    switch (section.layout) {
      case 'fullWidthImages':
        return _FullWidthImagesLayout(items: section.items);
      case 'halfWidthItems':
        return _HalfWidthItemsLayout(items: section.items);
      case 'thumbnail2x2':
        return _Thumbnail2x2Layout(items: section.items);
      case 'thumbnail3x3':
        return _Thumbnail3x3Layout(items: section.items);
      case 'simpleList':
        return _SimpleListLayout(items: section.items);
      default:
        return _FullWidthImagesLayout(items: section.items);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.showMoreLink,
    this.showMoreUrl,
  });

  final String title;
  final String? subtitle;
  final LinkTo? showMoreLink;
  final String? showMoreUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CommonStyles.titleTextStyle(context)?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (showMoreLink != null || showMoreUrl != null)
            GestureDetector(
              onTap: () => _onShowMoreTap(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'عرض المزيد',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onShowMoreTap(BuildContext context) async {
    if (showMoreUrl != null && showMoreUrl!.isNotEmpty) {
      final uri = Uri.tryParse(showMoreUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (showMoreLink != null) {
      NavigationHelper.navigateTo(
        context: context,
        goto: showMoreLink!.goto ?? '',
        subItem: SubItems(
          goto: showMoreLink!.goto,
          key: showMoreLink!.key,
          id: showMoreLink!.id,
        ),
        title: title,
      );
    }
  }
}

class _FullWidthImagesLayout extends StatelessWidget {
  const _FullWidthImagesLayout({required this.items});
  final List<SectionItem> items;

  static const _cornerRadius = 24.0;
  static const _horizontalPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.94),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: GestureDetector(
              onTap: () => _navigateSectionItem(context, item),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _sectionItemImage(
                  context,
                  item,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(_cornerRadius),
                    bottomLeft: Radius.circular(_cornerRadius),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HalfWidthItemsLayout extends StatelessWidget {
  const _HalfWidthItemsLayout({required this.items});
  final List<SectionItem> items;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth > 600 ? 200.0 : (screenWidth - 48) / 2;

    return SizedBox(
      height: 140,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.5),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => _navigateSectionItem(context, item),
              child: _sectionItemImage(
                context,
                item,
                width: itemWidth,
                height: 140,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Thumbnail2x2Layout extends StatelessWidget {
  const _Thumbnail2x2Layout({required this.items});
  final List<SectionItem> items;

  @override
  Widget build(BuildContext context) {
    const rowHeight = 56.0;
    const thumbnailSize = 44.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;

        return SizedBox(
          height: rowHeight * 2 + 16,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 1.0),
            itemCount: (items.length / 2).ceil(),
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 2;
              final pageItems = items.skip(start).take(2).toList();
              return SizedBox(
                width: fullWidth,
                child: _buildColumn(context, pageItems, fullWidth, rowHeight, thumbnailSize),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildColumn(BuildContext context, List<SectionItem> columnItems, double width, double rowHeight, double thumbnailSize) {
    return SizedBox(
      width: width,
      child: Column(
        children: columnItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _navigateSectionItem(context, item),
            child: SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  _sectionItemImage(
                    context,
                    item,
                    width: thumbnailSize,
                    height: thumbnailSize,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _Thumbnail3x3Layout extends StatelessWidget {
  const _Thumbnail3x3Layout({required this.items});
  final List<SectionItem> items;

  @override
  Widget build(BuildContext context) {
    const rowHeight = 48.0;
    const thumbnailSize = 36.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;

        return SizedBox(
          height: rowHeight * 3 + 20,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 1.0),
            itemCount: (items.length / 3).ceil(),
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 3;
              final pageItems = items.skip(start).take(3).toList();
              return SizedBox(
                width: fullWidth,
                child: _buildColumn(context, pageItems, fullWidth, rowHeight, thumbnailSize),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildColumn(BuildContext context, List<SectionItem> columnItems, double width, double rowHeight, double thumbnailSize) {
    return SizedBox(
      width: width,
      child: Column(
        children: columnItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => _navigateSectionItem(context, item),
            child: SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  _sectionItemImage(
                    context,
                    item,
                    width: thumbnailSize,
                    height: thumbnailSize,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _SimpleListLayout extends StatelessWidget {
  const _SimpleListLayout({required this.items});
  final List<SectionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _navigateSectionItem(context, item),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _leadingImage(context, item, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

void _navigateSectionItem(BuildContext context, SectionItem item) {
  NavigationHelper.navigateTo(
    context: context,
    goto: item.goto ?? '',
    subItem: SubItems(
      title: item.title,
      goto: item.goto,
      key: item.key,
      id: item.id,
    ),
    title: item.title,
  );
}

void _navigateSectionSubItem(BuildContext context, SectionSubItem sub) {
  NavigationHelper.navigateTo(
    context: context,
    goto: sub.goto ?? '',
    subItem: SubItems(
      title: sub.title,
      goto: sub.goto,
      key: sub.key,
      id: sub.id,
    ),
    title: sub.title,
  );
}
