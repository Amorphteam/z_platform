import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';

class EpubViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearchOpen;
  final bool isBookmarked;
  final bool isAboutUsBook;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchToggle;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onStylePressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onTocPressed;

  const EpubViewerAppBar({
    super.key,
    required this.isSearchOpen,
    required this.isBookmarked,
    required this.isAboutUsBook,
    required this.focusNode,
    required this.textEditingController,
    this.onBackPressed,
    this.onSearchToggle,
    this.onSearchSubmitted,
    this.onStylePressed,
    this.onBookmarkPressed,
    this.onTocPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: isSearchOpen
            ? Icon(isIOS ? CupertinoIcons.xmark : Icons.close)
            : Icon(isIOS ? CupertinoIcons.chevron_back : Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      title: isSearchOpen
          ? TextField(
              autofocus: true,
              focusNode: focusNode,
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'أدخل كلمة لبدء البحث ...',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: SvgPicture.asset('assets/icon/search.svg'),
                  onPressed: onSearchSubmitted != null
                      ? () {
                          if (textEditingController.text.isNotEmpty) {
                            onSearchSubmitted!();
                          }
                        }
                      : null,
                ),
              ),
              onSubmitted: (_) => onSearchSubmitted?.call(),
            )
          : const SizedBox.shrink(),
      actions: isSearchOpen || isAboutUsBook
          ? null
          : [
              IconButton(
                icon: Icon(
                    isIOS ? CupertinoIcons.search : Icons.search_rounded),
                onPressed: onSearchToggle,
              ),
              IconButton(
                icon: Icon(isIOS
                    ? CupertinoIcons.textformat
                    : Icons.format_color_text_rounded),
                onPressed: onStylePressed,
              ),
              IconButton(
                icon: isBookmarked
                    ? Icon(isIOS
                        ? CupertinoIcons.bookmark_fill
                        : Icons.bookmark)
                    : Icon(isIOS
                        ? CupertinoIcons.bookmark
                        : Icons.bookmark_border),
                onPressed: onBookmarkPressed,
              ),
              IconButton(
                icon: Icon(
                    isIOS ? CupertinoIcons.list_bullet : Icons.toc_rounded),
                onPressed: onTocPressed,
              ),
            ],
    );
  }
}

