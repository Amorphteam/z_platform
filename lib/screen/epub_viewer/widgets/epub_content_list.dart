import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../model/style_model.dart';
import 'epub_html_content.dart';

class EpubContentList extends StatelessWidget {
  final List<String> content;
  final ItemScrollController itemScrollController;
  final ScrollOffsetController scrollOffsetController;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetListener scrollOffsetListener;
  final FontSizeCustom fontSize;
  final LineHeightCustom lineHeight;
  final FontFamily fontFamily;
  final bool isDarkMode;
  final int currentPage;
  final GlobalKey? currentPageKey;

  const EpubContentList({
    super.key,
    required this.content,
    required this.itemScrollController,
    required this.scrollOffsetController,
    required this.itemPositionsListener,
    required this.scrollOffsetListener,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.isDarkMode,
    required this.currentPage,
    this.currentPageKey,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: content.length,
      itemScrollController: itemScrollController,
      scrollOffsetController: scrollOffsetController,
      itemPositionsListener: itemPositionsListener,
      scrollOffsetListener: scrollOffsetListener,
      physics: const BouncingScrollPhysics(),
      key: const PageStorageKey('epub_content'),
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) => _buildPageItem(context, index),
    );
  }

  Widget _buildPageItem(BuildContext context, int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCurrentPage = index == currentPage;

    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight),
        child: Container(
          margin: const EdgeInsets.only(right: 16, left: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectionArea(
            child: EpubHtmlContent(
              content: content[index],
              fontSize: fontSize,
              lineHeight: lineHeight,
              fontFamily: fontFamily,
              isDarkMode: isDarkMode,
              anchorKey: isCurrentPage ? currentPageKey : null,
            ),
          ),
        ),
      ),
    );
  }
}

