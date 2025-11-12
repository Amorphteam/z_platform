import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../model/book_model.dart';
import '../../model/history_model.dart';
import '../../model/reference_model.dart';
import '../../model/search_model.dart';
import '../../model/style_model.dart';
import '../../model/tree_toc_model.dart';
import '../bookmark/cubit/bookmark_cubit.dart';
import 'cubit/epub_viewer_cubit.dart';
import 'widgets/epub_viewer_app_bar.dart';
import 'widgets/search_navigation_buttons.dart';
import 'widgets/epub_content_list.dart';
import 'widgets/epub_page_slider.dart';
import 'widgets/epub_viewer_state_extractor.dart';
import 'widgets/style_sheet.dart';
import 'widgets/toc_tree_list_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/cupertino.dart';

class EpubViewerScreenV2 extends StatefulWidget {
  const EpubViewerScreenV2({
    super.key,
    this.referenceModel,
    this.book,
    this.tocModel,
    this.searchModel,
    this.historyModel,
    this.deepLinkFileName,
  });

  final ReferenceModel? referenceModel;
  final HistoryModel? historyModel;
  final Book? book;
  final EpubChaptersWithBookPath? tocModel;
  final SearchModel? searchModel;
  final String? deepLinkFileName;

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
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Get the first visible item (current page)
        final firstVisible = positions.first;
        final currentPageIndex = firstVisible.index;
        
        // Update cubit's current page
        final cubit = context.read<EpubViewerCubit>();
        if (cubit.currentPage != currentPageIndex) {
          cubit.updateCurrentPageFromScroll(currentPageIndex);
        }
      }
    });
  }


  void _initializeControllers() {
    itemScrollController = ItemScrollController();
    scrollOffsetController = ScrollOffsetController();
    itemPositionsListener = ItemPositionsListener.create();
    scrollOffsetListener = ScrollOffsetListener.create();
  }

  void _loadEpubFromSource() {
    context.read<EpubViewerCubit>().initializeEpubLoading(
      bookPath: widget.book?.epub,
      bookmarkPath: widget.referenceModel?.bookPath,
      historyPath: widget.historyModel?.bookPath,
      searchPath: widget.searchModel?.bookAddress,
      tocPath: widget.tocModel?.bookPath,
    );
  }

  @override
  void dispose() {
    context.read<EpubViewerCubit>().cancelIOSSliderDebounce();
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

          // Handle initial page jump based on source
          int? initialPage;
          
          // Check bookmark model
          if (widget.referenceModel?.navIndex != null) {
            initialPage = int.tryParse(widget.referenceModel!.navIndex) ?? 0;
          }
          // Check history model
          else if (widget.historyModel?.navIndex != null) {
            initialPage = int.tryParse(widget.historyModel!.navIndex) ?? 0;
          }
          // Check search model
          else if (widget.searchModel?.pageIndex != null) {
            initialPage = widget.searchModel!.pageIndex - 1; // pageIndex is 1-based
          }
          // Check TOC model
          else if (widget.tocModel?.epubChapter.ContentFileName != null) {
            // TOC navigation is handled by openEpubByChapter, so we don't need to jump here
            // The chapter navigation will emit pageChanged
          }

          // Jump to initial page if we have one
          if (initialPage != null && initialPage >= 0) {
            _shouldJumpToPage = true;
            cubit.jumpToPage(newPage: initialPage);
          }

          // Handle search model if provided
          if (widget.searchModel?.searchedWord != null) {
            _shouldJumpToPage = true;
            cubit.searchUsingHtmlList(widget.searchModel!.searchedWord!);
          }

          // Handle deep link file name jump after content loads
          if (widget.deepLinkFileName != null &&
              widget.deepLinkFileName!.isNotEmpty) {
            final String fileName = widget.deepLinkFileName!;
            // Try as-is, then try with common 'Text/' prefix
            _shouldJumpToPage = true;
            cubit.jumpToPage(chapterFileName: fileName);
            if (!fileName.contains('/')) {
              // Fallback attempt with Text/ prefix
              _shouldJumpToPage = true;
              cubit.jumpToPage(chapterFileName: 'Text/$fileName');
            }
          }
        }

        // Load user preferences and check bookmark
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

    if (content.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
            // TODO: Move logic to cubit - show page jump dialog
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

  void _showStyleBottomSheet(BuildContext context, EpubViewerCubit cubit, EpubViewerStateData stateData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  StyleSheet(
                    epubViewerCubit: cubit,
                    lineSpace: stateData.lineHeight,
                    fontFamily: stateData.fontFamily,
                    fontSize: stateData.fontSize,
                  ),
                ],
              ),
            );
          },
        );
      },
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
}
