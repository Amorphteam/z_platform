import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/book_model.dart';
import '../../model/deep_link_model.dart';
import '../../model/history_model.dart';
import '../../model/reference_model.dart';
import '../../model/search_model.dart';
import '../../model/tree_toc_model.dart';
import '../../util/page_helper.dart';
import '../bookmark/cubit/bookmark_cubit.dart';
import 'cubit/epub_viewer_cubit.dart';
import 'widgets/epub_content_list.dart';
import 'widgets/epub_page_slider.dart';
import 'widgets/epub_viewer_app_bar.dart';
import 'widgets/epub_viewer_state_extractor.dart';
import 'widgets/page_jump_dialog.dart';
import 'widgets/search_navigation_buttons.dart';
import 'widgets/style_sheet.dart';
import 'widgets/toc_tree_list_widget.dart';

class EpubViewerScreenV2 extends StatefulWidget {
  const EpubViewerScreenV2({
    super.key,
    this.referenceModel,
    this.book,
    this.tocModel,
    this.searchModel,
    this.historyModel,
    this.deepLinkModel,
    this.enableContentCache = true,
  });

  final ReferenceModel? referenceModel;
  final HistoryModel? historyModel;
  final Book? book;
  final EpubChaptersWithBookPath? tocModel;
  final SearchModel? searchModel;
  final DeepLinkModel? deepLinkModel;
  final bool enableContentCache;

  @override
  _EpubViewerScreenV2State createState() => _EpubViewerScreenV2State();
}

class _EpubViewerScreenV2State extends State<EpubViewerScreenV2> {
  // Controllers
  late final ItemScrollController itemScrollController;
  late final ScrollOffsetController scrollOffsetController;
  late final ItemPositionsListener itemPositionsListener;
  late final ScrollOffsetListener scrollOffsetListener;
  final focusNode = FocusNode();
  final textEditingController = TextEditingController();
  final Map<int, String> _processedContentCache = {};
  List<String>? _lastContentListRef;
  Timer? _scrollPositionDebounce;
  
  // GlobalKey for current page to enable anchor scrolling
  GlobalKey? _currentPageKey;
  int _lastPageForKey = -1;

  bool _hasLoadedEpub = false;
  bool _hasHandledInitialPageJump = false;
  bool _shouldJumpToPage = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load EPUB based on source (only once)
    if (!_hasLoadedEpub) {
      _hasLoadedEpub = true;
      _loadEpubFromSource();
      _setupScrollListener();
    }
  }

  void _setupScrollListener() {
    // Listen to scroll position changes to update current page
    itemPositionsListener.itemPositions.addListener(() {
      _scrollPositionDebounce?.cancel();
      _scrollPositionDebounce = Timer(const Duration(milliseconds: 100), () {
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isEmpty) return;

        Iterable<ItemPosition> visiblePositions =
            positions.where((position) => position.itemLeadingEdge < 1);
        if (visiblePositions.isEmpty) {
          visiblePositions = positions;
        }

        final currentPageIndex = visiblePositions.reduce(
          (max, position) => position.index > max.index ? position : max,
        ).index;

        // Update cubit's current page
        final cubit = context.read<EpubViewerCubit>();
        if (cubit.currentPage != currentPageIndex) {
          cubit.updateCurrentPageFromScroll(currentPageIndex);
        }
      });
    });
  }


  void _initializeControllers() {
    itemScrollController = ItemScrollController();
    scrollOffsetController = ScrollOffsetController();
    itemPositionsListener = ItemPositionsListener.create();
    scrollOffsetListener = ScrollOffsetListener.create();
  }

  void _loadEpubFromSource() {
    final cubit = context.read<EpubViewerCubit>();
    
    // Determine initial page based on source
    int? initialPage;
    String? tocChapterFileName;
    String? bookmarkFileName;
    
    if (widget.referenceModel != null) {
      // From bookmark
      // Check if fileName is provided (takes priority over navIndex)
      if (widget.referenceModel!.fileName != null && 
          widget.referenceModel!.fileName!.isNotEmpty) {
        bookmarkFileName = widget.referenceModel!.fileName;
      } else if (widget.referenceModel!.navIndex != null) {
        // Fall back to navIndex if no fileName
        initialPage = int.tryParse(widget.referenceModel!.navIndex) ?? 0;
      }
    } else if (widget.historyModel?.navIndex != null) {
      // From history
      initialPage = int.tryParse(widget.historyModel!.navIndex) ?? 0;
    } else if (widget.searchModel?.pageIndex != null) {
      // From search (pageIndex is 1-based, convert to 0-based)
      initialPage = widget.searchModel!.pageIndex - 1;
    } else if (widget.tocModel?.epubChapter.ContentFileName != null) {
      // From TOC - use chapter file name for navigation
      tocChapterFileName = widget.tocModel!.epubChapter.ContentFileName;
    } else if (widget.deepLinkModel != null) {
      // From deep link
      if (widget.deepLinkModel!.epubIndex != null) {
        initialPage = widget.deepLinkModel!.epubIndex;
      }
      // fileName will be handled separately if provided
    }
    
    cubit.initializeEpubLoading(
      bookPath: widget.book?.epub,
      bookmarkPath: widget.referenceModel?.bookPath,
      bookmarkFileName: bookmarkFileName,
      historyPath: widget.historyModel?.bookPath,
      searchPath: widget.searchModel?.bookAddress,
      tocPath: widget.tocModel?.bookPath,
      deepLinkPath: widget.deepLinkModel?.epubName,
      tocChapterFileName: tocChapterFileName,
      deepLinkFileName: widget.deepLinkModel?.fileName,
      initialPage: initialPage,
    );
  }

  @override
  void dispose() {
    // History saving is handled by cubit.close() which is called automatically
    // But we also save here to ensure it happens before widget disposal
    final cubit = context.read<EpubViewerCubit>();
    cubit.saveCurrentHistory();
    
    // Save page data using PageHelper (if needed)
    final bookPath = cubit.currentBookPath;
    if (bookPath != null) {
      final pageHelper = PageHelper();
      final cleanPath = bookPath.replaceFirst('assets/epub/', '');
      pageHelper.saveBookData(cleanPath, cubit.currentPage as double);
    }
    
    cubit.cancelIOSSliderDebounce();
    _scrollPositionDebounce?.cancel();
    _processedContentCache.clear();
    _lastContentListRef = null;
    itemPositionsListener.itemPositions.removeListener(() {});
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<EpubViewerCubit, EpubViewerState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final cubit = context.read<EpubViewerCubit>();
        final stateData = EpubViewerStateExtractor.extract(state, cubit);
        _updateSystemUI(cubit.isSliderVisible);

        return Scaffold(
          backgroundColor: stateData.backgroundColor,
          appBar: cubit.isSliderVisible
              ? EpubViewerAppBar(
                  isSearchOpen: cubit.isSearchOpen,
                  isBookmarked: stateData.isBookmarked,
                  isAboutUsBook: cubit.isAboutUsBook,
                  focusNode: focusNode,
                  textEditingController: textEditingController,
                  onBackPressed: () => _handleBackPressed(cubit),
                  onSearchToggle: () {
                    // Toggle search - this will emit a state to trigger rebuild
                    final wasOpen = cubit.isSearchOpen;
                    cubit.toggleSearch(!wasOpen);
                    // Focus the search field when opened
                    if (!wasOpen) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && focusNode.canRequestFocus) {
                          focusNode.requestFocus();
                        }
                      });
                    }
                  },
                  onSearchSubmitted: () {
                    if (textEditingController.text.isNotEmpty) {
                      _shouldJumpToPage = true;
                      cubit.searchUsingHtmlList(textEditingController.text);
                    }
                  },
                  onStylePressed: () => _showStyleBottomSheet(context, cubit, stateData),
                  onBookmarkPressed: () => _handleBookmarkToggle(context, cubit),
                  onTocPressed: () => _showTocBottomSheet(context, cubit, isDarkMode),
                )
              : null,
          body: Stack(
            children: [
              _buildContentArea(context, state, stateData, isDarkMode),
              _buildSearchNavigation(stateData),
            ],
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, EpubViewerState state) {
    final cubit = context.read<EpubViewerCubit>();
    
    state.maybeWhen(
      loaded: (content, title, tocList) {
        if (!_hasHandledInitialPageJump) {
          _hasHandledInitialPageJump = true;

          // Set flag for initial navigation (handled by cubit.handlePostLoadNavigation)
          // This ensures that when pageChanged is emitted from post-load navigation,
          // the screen will actually jump to the page
          _shouldJumpToPage = true;

          // Navigation is now handled by cubit.handlePostLoadNavigation()
          // which is called automatically after loading
          // But we still need to handle search and deep links here

          // Handle search model if provided (external search)
          if (widget.searchModel?.searchedWord != null) {
            // Wait a bit for content to be fully loaded and initial navigation to complete
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _shouldJumpToPage = true;
                cubit.searchUsingHtmlList(widget.searchModel!.searchedWord!);
              }
            });
          }

          // Handle deep link file name jump after content loads
          if (widget.deepLinkModel?.fileName != null &&
              widget.deepLinkModel!.fileName!.isNotEmpty) {
            final String fileName = widget.deepLinkModel!.fileName!;
            // Wait for initial navigation to complete
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                // Try as-is, then try with common 'Text/' prefix
                _shouldJumpToPage = true;
                cubit.jumpToPage(chapterFileName: fileName);
                if (!fileName.contains('/')) {
                  // Fallback attempt with Text/ prefix
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      _shouldJumpToPage = true;
                      cubit.jumpToPage(chapterFileName: 'Text/$fileName');
                    }
                  });
                }
              }
            });
          }
        }

        // Load user preferences
        cubit.loadUserPreferences();
      },
      searchResultsFound: (searchResults) {
        // Search results are handled automatically by cubit (auto-highlights first result)
        // No additional action needed here
      },
      contentHighlighted: (content, highlightedIndex, pageHighlights) {
        // Scroll to the highlighted page
        _scrollToPage(highlightedIndex);
        
        // Scroll to the highlight ID after a short delay to ensure content is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final cubit = context.read<EpubViewerCubit>();
          final highlightId = cubit.getCurrentHighlightId();
          if (highlightId != null) {
            _scrollToHighlight(highlightId);
          }
        });
      },
      pageChanged: (pageNumber) {
        // Scroll to the page when pageChanged is emitted from cubit
        if (pageNumber != null) {
          final cubit = context.read<EpubViewerCubit>();
          final highlightId = cubit.getCurrentHighlightId();
          
          // Scroll to page (only if page changed)
          _scrollToPage(pageNumber);
          
          // If this is a highlight navigation, scroll to the highlight
          // Use a longer delay to ensure the widget has rebuilt with the anchor key
          if (highlightId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Add a small delay to ensure the HTML widget has rendered with the anchor
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _scrollToHighlight(highlightId);
                }
              });
            });
          }
        }
      },
      error: (error) {
        if (error.toLowerCase().contains('translation') ||
            error.contains('No translation content found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'لا توجد ترجمات مفعلة. يرجى تفعيل ترجمة واحدة على الأقل من الإعدادات.'),
              duration: const Duration(seconds: 6),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'الإعدادات',
                onPressed: () => Navigator.pushNamed(context, '/settingScreen'),
              ),
            ),
          );
        }
      },
      orElse: () {},
    );
  }

  void _scrollToPage(int pageNumber) {
    // Update GlobalKey if page changed (needed for anchor scrolling)
    // Don't recreate key if staying on same page (for highlight navigation)
    final bool pageChanged = _lastPageForKey != pageNumber;
    if (pageChanged) {
      _currentPageKey = GlobalKey();
      _lastPageForKey = pageNumber;
    }
    
    if (!itemScrollController.isAttached) {
      // If controller not attached yet, defer the scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && itemScrollController.isAttached) {
          try {
            // Only jump to page if page actually changed
            if (pageChanged && _shouldJumpToPage) {
              itemScrollController.jumpTo(index: pageNumber);
            }
          } catch (e) {
            debugPrint('Error scrolling to page: $e');
          }
        }
      });
      return;
    }
    
    try {
      // Only jump to page if page actually changed
      if (pageChanged && _shouldJumpToPage) {
        itemScrollController.jumpTo(index: pageNumber);
      }
    } catch (e) {
      debugPrint('Error scrolling to page: $e');
    }

    // Reset the flag after attempting to jump
    _shouldJumpToPage = false;
  }

  void _updateSystemUI(bool isSliderVisible) {
    if (!isSliderVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  void _handleBackPressed(EpubViewerCubit cubit) {
    if (cubit.isSearchOpen) {
      cubit.toggleSearch(false);
      textEditingController.clear();
      focusNode.unfocus();
      // Content restoration is handled by cubit.toggleSearch(false)
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildContentArea(
    BuildContext context,
    EpubViewerState state,
    EpubViewerStateData stateData,
    bool isDarkMode,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: stateData.backgroundColor,
        child: state.maybeWhen(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.red),
          ),
          initial: () => const Center(
            child: CircularProgressIndicator(),
          ),
          orElse: () => _buildContent(
            context,
            stateData,
            isDarkMode,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EpubViewerStateData stateData,
    bool isDarkMode,
  ) {
    final cubit = context.read<EpubViewerCubit>();
    
    // Use cached content from cubit if current state doesn't have content
    final content = stateData.content.isNotEmpty
        ? stateData.content
        : cubit.cachedContent;
    final bookTitle = stateData.bookTitle.isNotEmpty
        ? stateData.bookTitle
        : cubit.cachedBookTitle;
    // Style is already extracted with fallback to cached values in state extractor
    final fontSize = stateData.fontSize;
    final lineHeight = stateData.lineHeight;
    final fontFamily = stateData.fontFamily;
    final styleSignature =
        '${fontSize.index}-${lineHeight.index}-${fontFamily.index}-${stateData.backgroundColor.value}-${stateData.useUniformTextColor}-${stateData.uniformTextColor.value}';

    if (content.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.enableContentCache) {
      _syncContentCacheReference(content);
    } else {
      _processedContentCache.clear();
      _lastContentListRef = null;
    }

    return Column(
      children: [
        Expanded(
          child: EpubContentList(
            content: content,
            itemScrollController: itemScrollController,
            scrollOffsetController: scrollOffsetController,
            itemPositionsListener: itemPositionsListener,
            scrollOffsetListener: scrollOffsetListener,
            fontSize: fontSize,
            lineHeight: lineHeight,
            fontFamily: fontFamily,
            isDarkMode: isDarkMode,
            currentPage: cubit.currentPage,
            currentPageKey: _currentPageKey,
            processedContentBuilder: widget.enableContentCache
                ? (index) => _getProcessedContent(index, content[index])
                : null,
            backgroundColor: stateData.backgroundColor,
            useUniformTextColor: stateData.useUniformTextColor,
            uniformTextColor: stateData.uniformTextColor,
            styleSignature: styleSignature,
          ),
        ),
        EpubPageSlider(
          currentPage: stateData.currentPage,
          maxPages: content.length.toDouble(),
          bookTitle: bookTitle,
          isAboutUsBook: cubit.isAboutUsBook,
          onChanged: (newValue) {
            final cubit = context.read<EpubViewerCubit>();
            // Update page immediately for UI feedback
            cubit.updateCurrentPageFromSlider(newValue);
            
            // For iOS, debounce the jump since CNSlider doesn't have onChangeEnd
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              cubit.handleIOSSliderChange(newValue, () {
                if (mounted) {
                  _shouldJumpToPage = true;
                  cubit.jumpToPage(newPage: newValue.toInt());
                }
              });
            }
          },
          onChangedEnd: (newValue) {
            // Android: Jump to page when slider is released
            _shouldJumpToPage = true;
            context.read<EpubViewerCubit>().jumpToPageFromSlider(newValue);
          },
          onPageJump: () {
            final cubit = context.read<EpubViewerCubit>();
            _handlePageJump(context, cubit, content.length);
          },
        ),
      ],
    );
  }

  Widget _buildSearchNavigation(EpubViewerStateData stateData) {
    final cubit = context.read<EpubViewerCubit>();
    
    return SearchNavigationButtons(
      searchResults: cubit.currentSearchResults.isNotEmpty 
          ? cubit.currentSearchResults 
          : stateData.searchResults,
      currentSearchIndex: cubit.currentSearchIndex,
      onPrevious: () {
        final results = cubit.currentSearchResults.isNotEmpty 
            ? cubit.currentSearchResults 
            : stateData.searchResults;
        if (results.isNotEmpty) {
          _shouldJumpToPage = true;
          cubit.navigateToPreviousSearchResult(results);
        }
      },
      onNext: () {
        final results = cubit.currentSearchResults.isNotEmpty 
            ? cubit.currentSearchResults 
            : stateData.searchResults;
        if (results.isNotEmpty) {
          _shouldJumpToPage = true;
          cubit.navigateToNextSearchResult(results);
        }
      },
      onShowResults: () {
        _showSearchResultsDialog(context, cubit);
      },
    );
  }
  
  void _scrollToHighlight(String highlightId) {
    // Use AnchorKey to find the anchor and scroll to it
    if (_currentPageKey == null) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // AnchorKey is from flutter_html package
        // It allows finding anchors by ID within an Html widget
        final anchorContext = AnchorKey.forId(_currentPageKey, highlightId)?.currentContext;
        if (anchorContext != null) {
          Scrollable.ensureVisible(
            anchorContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          debugPrint('⚠️ Could not find anchor context for highlight: $highlightId');
        }
      } catch (e) {
        debugPrint('Error scrolling to highlight: $e');
      }
    });
  }

  void _showSearchResultsDialog(BuildContext context, EpubViewerCubit cubit) {
    final searchResults = cubit.currentSearchResults;
    if (searchResults.isEmpty) return;

    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(isIOS ? CupertinoIcons.xmark : Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 16, top: 8, bottom: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'كل النتائج: ${searchResults.length}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    title: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _shouldJumpToPage = true;
                        cubit.navigateToSearchResult(index);
                      },
                      child: Row(
                        children: [
                          Text(
                            '${result.pageIndex}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Expanded(
                            child: Html(
                              data: result.spanna ?? '',
                              style: {
                                'html': Style(
                                  fontSize: FontSize.medium,
                                  lineHeight: LineHeight(1.2),
                                  textAlign: TextAlign.right,
                                ),
                                'mark': Style(
                                  backgroundColor: Colors.yellow,
                                ),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < searchResults.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.3,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handlePageJump(
    BuildContext context,
    EpubViewerCubit cubit,
    int totalPages,
  ) async {
    if (totalPages <= 0) return;

    final targetPage = await PageJumpDialog.show(
      context: context,
      totalPages: totalPages,
    );

    if (targetPage != null) {
      _shouldJumpToPage = true;
      cubit.jumpToPage(newPage: targetPage);
    }
  }

  void _showStyleBottomSheet(BuildContext context, EpubViewerCubit cubit, EpubViewerStateData stateData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  StyleSheet(
                    epubViewerCubit: cubit,
                    lineSpace: stateData.lineHeight,
                    fontFamily: stateData.fontFamily,
                    fontSize: stateData.fontSize,
                    backgroundColor: stateData.backgroundColor,
                    useUniformTextColor: stateData.useUniformTextColor,
                    uniformTextColor: stateData.uniformTextColor,
                  ),
                ],
              ),
            ),
        ),
    );
  }

  Future<void> _handleBookmarkToggle(BuildContext context, EpubViewerCubit cubit) async {
    await cubit.toggleBookmark();
    // Refresh bookmark list in BookmarkCubit if available
    if (context.mounted) {
      final bookmarkCubit = context.read<BookmarkCubit>();
      bookmarkCubit.loadAllBookmarks();
    }
  }

  void _showTocBottomSheet(BuildContext context, EpubViewerCubit cubit, bool isDarkMode) {
    final tocList = cubit.tocTreeList;
    if (tocList == null || tocList.isEmpty) return;

    // This variable holds the state of the AppBar visibility
    final ValueNotifier<bool> showAppBar = ValueNotifier(false);

    showModalBottomSheet(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          // When the sheet is fully expanded, show the AppBar
          showAppBar.value = notification.extent == notification.maxExtent;
          return true; // Return true to cancel the notification bubbling.
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.25,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) => Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 26, right: 16, left: 16),
                  // Reserve space for the AppBar-like header
                  child: EpubChapterListWidget(
                    tocTreeList: tocList,
                    scrollController: scrollController,
                    epubViewerCubit: cubit,
                    onClose: () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ),
                // Use ValueListenableBuilder to react to changes in showAppBar
                ValueListenableBuilder<bool>(
                  valueListenable: showAppBar,
                  builder: (context, value, child) {
                    if (value) {
                      return Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Container(
                            height: 56,
                            // Standard AppBar height
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerRight,
                            color: Colors.transparent,
                            // Adjust the color as needed
                            child: IconButton(
                              icon: Icon(defaultTargetPlatform == TargetPlatform.iOS
                                  ? Icons.chevron_left
                                  : Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    } // If false, don't show anything
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncContentCacheReference(List<String> content) {
    final bool isNewList = !identical(_lastContentListRef, content);
    final bool lengthChanged =
        _lastContentListRef != null && _lastContentListRef!.length != content.length;
    if (isNewList || lengthChanged) {
      _processedContentCache.clear();
      _lastContentListRef = content;
    } else if (_processedContentCache.isNotEmpty) {
      _processedContentCache.removeWhere((key, _) => key >= content.length);
    }
  }

  String _getProcessedContent(int index, String rawContent) {
    final cachedContent = _processedContentCache[index];
    if (cachedContent != null) {
      return cachedContent;
    }

    final processedContent = _processHtmlContent(rawContent);
    _processedContentCache[index] = processedContent;
    return processedContent;
  }

  String _processHtmlContent(String content) {
    // Placeholder for future preprocessing (e.g., localization tweaks, caching)
    return content;
  }
}
