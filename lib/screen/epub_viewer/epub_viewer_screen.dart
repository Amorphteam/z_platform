import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:zahra/model/word.dart';
import 'package:zahra/screen/epub_viewer/widgets/WordBottomSheetContent.dart';
import 'package:zahra/screen/epub_viewer/widgets/toc_tree_list_widget.dart';
import '../../model/book_model.dart';
import '../../model/history_model.dart';
import '../../model/reference_model.dart';
import '../../model/search_model.dart';
import '../../model/style_model.dart';
import '../../model/tree_toc_model.dart';
import '../../repository/database_repository.dart';
import '../../util/epub_helper.dart';
import '../../util/page_helper.dart';
import '../../util/style_helper.dart';
import '../bookmark/cubit/bookmark_cubit.dart';
import 'cubit/epub_viewer_cubit.dart';
import 'internal_search/internal_search_screen.dart';
import 'widgets/style_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

typedef DataCallback = void Function(dynamic data);

class EpubViewerScreen extends StatefulWidget {

  const EpubViewerScreen({
    super.key,
    this.referenceModel,
    this.book,
    this.tocModel,
    this.searchModel,
    this.historyModel,
  });
  final ReferenceModel? referenceModel;
  final HistoryModel? historyModel;
  final Book? book;
  final EpubChaptersWithBookPath? tocModel;
  final SearchModel? searchModel;

  @override
  _EpubViewerScreenState createState() => _EpubViewerScreenState();
}

class _EpubViewerScreenState extends State<EpubViewerScreen> {
  int _currentIndex = -1;
  bool _hasHandledInitialPageJump = false;
  int _initialPageIndex = 0;
  late final ItemScrollController itemScrollController;
  late final ScrollOffsetController scrollOffsetController;
  late final ItemPositionsListener itemPositionsListener;
  late final ScrollOffsetListener scrollOffsetListener;
  String _bookName = '';
  PageHelper pageHelper = PageHelper();
  double _currentPage = 0;
  bool isSliderVisible = true;
  bool isAboutUsBook = false;
  bool isBookmarked = false;
  EpubChapter? _chapter;
  List<EpubChapter>? _tocList;
  String? _bookPath;
  FontSizeCustom fontSize = FontSizeCustom.medium;
  LineHeightCustom lineHeight = LineHeightCustom.medium;
  FontFamily fontFamily = FontFamily.font1;
  final String _pathUrl = 'assets/epub/';
  List<String> _content = [];
  List<String> _orginalContent = [];
  bool _isSliderChange = false;
  EpubViewerCubit? _epubViewerCubit;
  String searchedWord = '';
  bool isSearchOpen = false;
  bool isDarkMode = false;
  final focusNode = FocusNode();
  final textEditingController = TextEditingController();
  List<SearchModel> _currentSearchResults = [];
  int _currentSearchIndex = 0;
  final Map<int, dom.Document> _htmlCache = {};
  final Map<int, String> _processedContentCache = {};
  bool _isControllerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Save the cubit reference safely.
    _epubViewerCubit = context.read<EpubViewerCubit>();

    // If we have a search model, set up the initial search state
    if (widget.searchModel != null) {
      setState(() {
        _currentSearchResults = [widget.searchModel!];
        _currentSearchIndex = 0;
        searchedWord = widget.searchModel!.searchedWord!;
      });
      // Trigger the highlight after a short delay to ensure content is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        context.read<EpubViewerCubit>().highlightContent(
          widget.searchModel!.pageIndex,
          widget.searchModel!.searchedWord!
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _buildCurrentUi(context, null);
    _determineEpubSourceAndLoad();
    
    // Set initial page based on the source
    if (widget.referenceModel?.navIndex != null) {
      final double doubleValue = double.parse(widget.referenceModel!.navIndex);
      _initialPageIndex = doubleValue.toInt();
    } else if (widget.historyModel?.navIndex != null) {
      final double doubleValue = double.parse(widget.historyModel!.navIndex);
      _initialPageIndex = doubleValue.toInt();
    } else if (widget.searchModel?.pageIndex != null) {
      _initialPageIndex = widget.searchModel!.pageIndex - 1;
    }

    // Debounce the item positions listener to reduce rebuilds
    Timer? _debounceTimer;
    itemPositionsListener.itemPositions.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isNotEmpty) {
          final int firstVisibleItemIndex = positions
              .where((position) => position.itemLeadingEdge < 1)
              .reduce(
                  (max, position) => position.index > max.index ? position : max,)
              .index;

          if (_currentIndex != firstVisibleItemIndex) {
            _currentIndex = firstVisibleItemIndex;
            _updateCurrentPage(firstVisibleItemIndex.toDouble());
          }
        }
      });
    });
  }

  void _initializeControllers() {
    itemScrollController = ItemScrollController();
    scrollOffsetController = ScrollOffsetController();
    itemPositionsListener = ItemPositionsListener.create();
    scrollOffsetListener = ScrollOffsetListener.create();
    _isControllerInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_chapter != null) {
      context
          .read<EpubViewerCubit>()
          .jumpToPage(chapterFileName: _chapter!.ContentFileName);
    }

    if (!isSliderVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values,);
    }

    return BlocConsumer<EpubViewerCubit, EpubViewerState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (content, _, tocList) {
            _storeContentLoaded(content, context, state, tocList);
            
            if (!_hasHandledInitialPageJump) {
              _hasHandledInitialPageJump = true;
              if (widget.searchModel?.searchedWord != null) {
                _search(widget.searchModel!.searchedWord!);
              }
            }
            
            context.read<EpubViewerCubit>().loadUserPreferences();
            context.read<EpubViewerCubit>().checkBookmark(_bookPath!, _currentPage.toString());
          },
          translationLoaded: (translation) {
            // Check if there are any translations available
            if (translation.isEmpty) {
              // Show snackbar with action button instead of opening bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('لا توجد ترجمات مفعلة. يرجى تفعيل ترجمة واحدة على الأقل من الإعدادات.'),
                  duration: const Duration(seconds: 6),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  action: SnackBarAction(
                    label: 'الإعدادات',
                    textColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.pushNamed(context, '/settingScreen');
                    },
                  ),
                ),
              );
              return;
            }
            
            // Show the translation in a full page bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return TranslationBottomSheetContent(translation: translation);
              },
            ).then((_) {
              // Emit the loaded state to preserve content
              context.read<EpubViewerCubit>().emit(EpubViewerState.loaded(
                content: _content,
                epubTitle: _bookName,
                tocTreeList: _tocList,
              ));
            });
          },
          searchResultsFound: (searchResults) {
            setState(() {
              _currentSearchResults = searchResults;
              // Find the index of the current search result if we're opening from search
              if (widget.searchModel != null) {
                _currentSearchIndex = searchResults.indexWhere(
                  (result) => result.pageIndex == widget.searchModel!.pageIndex
                );
                if (_currentSearchIndex == -1) _currentSearchIndex = 0;
              } else {
                _currentSearchIndex = 0;
              }
            });
            // Remove the dialog and directly highlight the first result
            if (searchResults.isNotEmpty) {
              context.read<EpubViewerCubit>().highlightContent(
                searchResults[_currentSearchIndex].pageIndex,
                searchedWord
              );
            }
          },
          styleChanged: (fontSize, lineSpace, fontFamily){
            print('loadUserPreferences $lineSpace add $fontFamily');

            _changeStyle(fontSize, lineSpace, fontFamily);
          },
          bookmarkPresent: () => setState(() => isBookmarked = true),
          bookmarkAbsent: () => setState(() => isBookmarked = false),
          error: (error) {
            // Check if this is a translation-related error
            if (error.toLowerCase().contains('translation') || 
                error.contains('No translation content found')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('لا توجد ترجمات مفعلة. يرجى تفعيل ترجمة واحدة على الأقل من الإعدادات.'),
                  duration: const Duration(seconds: 6),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  action: SnackBarAction(
                    label: 'الإعدادات',
                    textColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.pushNamed(context, '/settingScreen');
                    },
                  ),
                ),
              );
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) => Scaffold(
        body: Stack(
          children: [
            if (isSliderVisible)
              AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                leading: IconButton(
                  icon: isSearchOpen
                      ? Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant)
                      : Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () {
                    if (isSearchOpen) {
                      _toggleSearch(false);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
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
                      icon: SvgPicture.asset('assets/icon/search.svg', color: Theme.of(context).colorScheme.onSurfaceVariant),
                      onPressed: () {
                        if (textEditingController.text.isNotEmpty) {
                          final String searchQuery = textEditingController.text;
                          _search(searchQuery);
                        }
                      },
                    ),
                  ),
                  onSubmitted: _search,
                )
                    : const SizedBox.shrink(),
                actions: isSearchOpen || isAboutUsBook
                    ? null // No actions when search is open or when it's About Us page
                    : [
                  IconButton(
                    icon: SvgPicture.asset('assets/icon/search.svg', color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () => _toggleSearch(true),
                  ),
                  IconButton(
                    icon: SvgPicture.asset('assets/icon/font.svg', color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {
                      _showBottomSheet(
                        context, context.read<EpubViewerCubit>(),
                      );
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      isBookmarked
                          ? 'assets/icon/bookmarked.svg'
                          : 'assets/icon/bookmark.svg',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _toggleBookmark();
                      if (isBookmarked) {
                        _addBookmark(context);
                      } else {
                        _removeBookmark(context);
                      }
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset('assets/icon/list.svg', color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {
                      _openInternalToc(context);
                    },
                  ),
                  (_bookPath!.contains('khotab') || _bookPath!.contains('letter')) ? IconButton(
                    icon: Icon(Icons.translate_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {
                      if (_bookPath != null) {
                        context.read<EpubViewerCubit>().getTranslation(_bookPath!, _currentPage.toInt()+1);
                      }
                    },
                  ):Container(),

                ],
              ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(
                  top: !isSliderVisible
                      ? 0
                      : kToolbarHeight +
                      MediaQuery.of(context).padding.top,),
                child: state.when(
                  loaded: (content, _, tocList) {
                    _storeContentLoaded(content, context, state, tocList);
                    
                    return _buildCurrentUi(context, _content);
                  },
                      contentHighlighted: (content, page) {
                        _orginalContent = _content;
                        _content = content;
                        _jumpTo(pageNumber: page);
                        return _buildCurrentUi(context, content);
                      },
                      bookmarkAbsent: () => _buildCurrentUi(context, _content),
                      bookmarkPresent: () => _buildCurrentUi(context, _content),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.red,),
                      ),
                      error: (error) => _buildCurrentUi(context, _content),
                      initial: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      pageChanged: (int? pageNumber) {
                        _jumpTo(pageNumber: pageNumber);
                        return _buildCurrentUi(context, _content);
                      },
                      styleChanged: (fontSize,
                          lineHeight,
                          fontFamily,) => _buildCurrentUi(context, _content),
                      bookmarkAdded: (int? status) => _buildCurrentUi(context, _content),
                      historyAdded: (int? status) => _buildCurrentUi(context, _content),
                      searchResultsFound: (List<SearchModel> searchResults) => _buildCurrentUi(context, _content), translationLoaded: (Map<String, dynamic> translation) => _buildCurrentUi(context, _content),),
                ),
              ),
              // Add floating navigation buttons when search results exist
              if (_currentSearchResults.isNotEmpty)
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "prevSearch",
                        mini: true,
                        backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        child: Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.surface,),
                        onPressed: _navigateToPreviousResult,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showSearchResultsDialog(context, _currentSearchResults);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${_currentSearchResults.length}/${_currentSearchIndex + 1}',
                              style: TextStyle(color: Theme.of(context).colorScheme.surface),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "nextSearch",
                        mini: true,
                        backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        child: Icon(Icons.arrow_downward, color: Theme.of(context).colorScheme.surface),
                        onPressed: _navigateToNextResult,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    );
  }

  void _storeContentLoaded(List<String> htmlContent, BuildContext context,
      EpubViewerState state, List<EpubChapter>? tocList,) {
    // Convert each content page's numbers from Latin to Arabic
    _content = htmlContent;
    _orginalContent = _content;
    _bookName = _getAppBarTitle(state);
    _tocList = tocList;
  }


  void _toggleSearch(bool open) {
    setState(() {
      isSearchOpen = open;
    });

    if (isSearchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(focusNode);
      });
    } else {
      setState(() {
        _content = _orginalContent;
      });
      focusNode.unfocus();
      textEditingController.clear();
    }
  }

  void showSearchResultsDialog(
      BuildContext context, List<SearchModel> searchResults,) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 16, top: 8, bottom: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('كل النتائج: ${searchResults.length}',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return ListView.builder(
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
                            setDialogState(() {
                              _currentSearchIndex = _currentSearchResults.indexOf(result);
                            });
                            _jumpTo(pageNumber: result.pageIndex - 1);
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUi(BuildContext context, List<String>? content) {
    if (content == null){
      return Placeholder();
    } else {
      final allPagesCount = content.length.toDouble();
      return Column(
        children: [
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: content.length ?? 0,
              itemScrollController: itemScrollController,
              scrollOffsetController: scrollOffsetController,
              itemPositionsListener: itemPositionsListener,
              scrollOffsetListener: scrollOffsetListener,
              physics: const BouncingScrollPhysics(),
              key: PageStorageKey('epub_content'),
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              initialScrollIndex: _initialPageIndex,
              itemBuilder: (BuildContext context, int index) {
                final double screenHeight = MediaQuery.of(context).size.height;

                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    // onDoubleTap: () {
                    //   setState(() {
                    //     isSliderVisible = !isSliderVisible;
                    //   });
                    // },
                    // onLongPress: () {
                    //   setState(() {
                    //     isSliderVisible = !isSliderVisible;
                    //   });
                    // },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenHeight),
                      child: Container(
                        margin: const EdgeInsets.only(right: 16, left: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectionArea(
                          child: _buildHtmlContent(index, content[index]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isSliderVisible && !isAboutUsBook)
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  Slider(
                    thumbColor: Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                    activeColor:Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                    value: _currentPage,
                    min: 0,
                    max: allPagesCount ?? -1,
                    onChanged: (newValue) {
                      _isSliderChange = true;
                      setState(() {
                        _currentPage = newValue;
                      });
                    },
                    onChangeEnd: (newValue) {
                      _jumpTo(pageNumber: newValue.toInt());
                      _isSliderChange = false;
                    },
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(
                        right: 16.0, left: 16.0, bottom: 20.0, top: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _bookName,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .labelLarge,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showPageJumpDialog(context);
                          },
                          child: Text(
                            '${allPagesCount?.toInt()}/${_currentPage.toInt() +
                                1}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .labelLarge,
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
  }

  Widget _buildHtmlContent(int index, String content) {
    // Check cache first
    if (_processedContentCache.containsKey(index)) {
      return Html(
        data: _processedContentCache[index]!,
        onAnchorTap: _handleAnchorTap,
        style: {
          'body': Style(
            direction: TextDirection.rtl,
            textAlign: TextAlign.justify,
            lineHeight: LineHeight(lineHeight.size),
            textDecoration: TextDecoration.none,
          ),
          'p': Style(
            color: isDarkMode ? Colors.white : Colors.black,
            textAlign: TextAlign.justify,
            margin: Margins.only(bottom: 10),
            fontSize: FontSize(fontSize.size),
            fontFamily: fontFamily.name,
            padding: HtmlPaddings.only(right: 7),
          ),
          'p.center': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF996633),
            textAlign: TextAlign.center,
            margin: Margins.zero,
            fontSize: FontSize(fontSize.size),
            fontFamily: fontFamily.name,
            padding: HtmlPaddings.zero,
          ),
          'p.title3': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF2B5100),
            textAlign: TextAlign.right,
            margin: Margins.zero,
            fontSize: FontSize(fontSize.size),
            fontFamily: fontFamily.name,
            fontWeight: FontWeight.bold,
            padding: HtmlPaddings.zero,
            lineHeight: LineHeight(1.2),
            textDecoration: TextDecoration.none,
          ),
          'p.title3_1': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF12116C),
            textAlign: TextAlign.right,
            fontWeight: FontWeight.bold,
            margin: Margins.zero,
            fontSize: FontSize(fontSize.size),
            fontFamily: fontFamily.name,
            padding: HtmlPaddings.zero,
            lineHeight: LineHeight(1.2),
            textDecoration: TextDecoration.none,
          ),
          'a': Style(
            textDecoration: TextDecoration.none,
          ),
          'a:link': Style(
            color: const Color(0xFF2484C6),
          ),
          'a:visited': Style(
            color: Colors.red,
          ),
          'h1': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF00AA00),
            fontSize: FontSize(fontSize.size * 1.1),
            textAlign: TextAlign.center,
            margin: Margins.only(bottom: 10),
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          'h2': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF000080),
            fontSize: FontSize(fontSize.size),
            textAlign: TextAlign.center,
            margin: Margins.only(bottom: 10),
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          'h3': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF006400),
            fontSize: FontSize(fontSize.size),
            textAlign: TextAlign.right,
            margin: Margins.only(bottom: 10),
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          'h3.tit3_1': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF800000),
            fontSize: FontSize(fontSize.size),
            textAlign: TextAlign.right,
            margin: Margins.only(bottom: 10),
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          'h4.tit4': Style(
            color: isDarkMode ? Colors.white : Colors.red,
            fontSize: FontSize(fontSize.size),
            textAlign: TextAlign.center,
            margin: Margins.zero,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          '.pagen': Style(
            textAlign: TextAlign.center,
            color: isDarkMode ? Color(0xfff9825e) : Colors.red,
            fontSize: FontSize(fontSize.size),
            fontFamily: fontFamily.name,
          ),
          '.shareef': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF996633),
            fontSize: FontSize(fontSize.size * 0.9),
            textAlign: TextAlign.justify,
            margin: Margins.only(bottom: 5),
            padding: HtmlPaddings.only(right: 7),
            fontFamily: fontFamily.name,
          ),
          '.shareef_sher': Style(
            textAlign: TextAlign.center,
            color: isDarkMode ? Colors.white : const Color(0xFF996633),
            fontSize: FontSize(fontSize.size * 0.9),
            margin: Margins.symmetric(vertical: 5),
            padding: HtmlPaddings.zero,
          ),
          '.fnote': Style(
            color: isDarkMode ? const Color(0xFF8a8afa) : const Color(0xFF000080),
            fontSize: FontSize(fontSize.size * 0.75),
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          '.sher': Style(
            textAlign: TextAlign.center,
            color: isDarkMode ? Colors.white : const Color(0xFF990000),
            fontSize: FontSize(fontSize.size),
            margin: Margins.symmetric(vertical: 10),
            padding: HtmlPaddings.zero,
          ),
          '.psm': Style(
            textAlign: TextAlign.center,
            color: isDarkMode ? Colors.white : const Color(0xFF990000),
            fontSize: FontSize(fontSize.size * 0.8),
            margin: Margins.symmetric(vertical: 10),
            padding: HtmlPaddings.zero,
          ),
          '.shareh': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF996633),
          ),
          '.msaleh': Style(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          '.onwan': Style(
            color: isDarkMode ? Colors.white : const Color(0xFF088888),
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily.name,
          ),
          '.fn': Style(
            color: isDarkMode ? const Color(0xff8a8afa) : const Color(0xFF000080),
            fontWeight: FontWeight.normal,
            fontSize: FontSize(fontSize.size * 0.75),
            textDecoration: TextDecoration.none,
            verticalAlign: VerticalAlign.top,
          ),
          '.fm': Style(
            color: isDarkMode ? Color(0xffa2e1a2) : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: FontSize(fontSize.size * 0.75),
            textDecoration: TextDecoration.none,
          ),
          '.quran': Style(
            fontWeight: FontWeight.bold,
            fontSize: FontSize(fontSize.size),
            color: isDarkMode ? Color(0xffa2e1a2) : const Color(0xFF509368),
            fontFamily: fontFamily.name,
          ),
          '.hadith': Style(
            fontSize: FontSize(fontSize.size),
            color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
          ),
          '.hadith-num': Style(
            fontWeight: FontWeight.bold,
            fontSize: FontSize(fontSize.size),
            color: isDarkMode ? Color(0xfff9825e) : Colors.red,
            fontFamily: fontFamily.name,
          ),
          '.shreah': Style(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
            fontFamily: fontFamily.name,
          ),
          '.kalema': Style(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFFCC0066),
          ),
          'mark': Style(
            backgroundColor: Colors.yellow,
          ),
        },
      );
    }

    // Process and cache the content
    final processedContent = _processHtmlContent(content);
    _processedContentCache[index] = processedContent;

    return Html(
      onAnchorTap: _handleAnchorTap,
      data: processedContent,
      style: {
        'body': Style(
          direction: TextDirection.rtl,
          textAlign: TextAlign.justify,
          lineHeight: LineHeight(lineHeight.size),
          textDecoration: TextDecoration.none,
        ),
        'p': Style(
          color: isDarkMode ? Colors.white : Colors.black,
          textAlign: TextAlign.justify,
          margin: Margins.only(bottom: 10),
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          padding: HtmlPaddings.only(right: 7),
        ),
        'p.center': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF996633),
          textAlign: TextAlign.center,
          margin: Margins.zero,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          padding: HtmlPaddings.zero,
        ),
        'p.title3': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF2B5100),
          textAlign: TextAlign.right,
          margin: Margins.zero,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          fontWeight: FontWeight.bold,
          padding: HtmlPaddings.zero,
          lineHeight: LineHeight(1.2),
          textDecoration: TextDecoration.none,
        ),
        'p.title3_1': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF12116C),
          textAlign: TextAlign.right,
          fontWeight: FontWeight.bold,
          margin: Margins.zero,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          padding: HtmlPaddings.zero,
          lineHeight: LineHeight(1.2),
          textDecoration: TextDecoration.none,
        ),
        'a': Style(
          textDecoration: TextDecoration.none,
        ),
        'a:link': Style(
          color: const Color(0xFF2484C6),
        ),
        'a:visited': Style(
          color: Colors.red,
        ),
        'h1': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF00AA00),
          fontSize: FontSize(fontSize.size * 1.1),
          textAlign: TextAlign.center,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h2': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF000080),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.center,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h3': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF006400),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.right,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h3.tit3_1': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF800000),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.right,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h4.tit4': Style(
          color: isDarkMode ? Colors.white : Colors.red,
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.center,
          margin: Margins.zero,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        '.pagen': Style(
          textAlign: TextAlign.center,
          color: isDarkMode ? Color(0xfff9825e) : Colors.red,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
        ),
        '.shareef': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF996633),
          fontSize: FontSize(fontSize.size * 0.9),
          textAlign: TextAlign.justify,
          margin: Margins.only(bottom: 5),
          padding: HtmlPaddings.only(right: 7),
          fontFamily: fontFamily.name,
        ),
        '.shareef_sher': Style(
          textAlign: TextAlign.center,
          color: isDarkMode ? Colors.white : const Color(0xFF996633),
          fontSize: FontSize(fontSize.size * 0.9),
          margin: Margins.symmetric(vertical: 5),
          padding: HtmlPaddings.zero,
        ),
        '.fnote': Style(
          color: isDarkMode ? const Color(0xFF8a8afa) : const Color(0xFF000080),
          fontSize: FontSize(fontSize.size * 0.75),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        '.sher': Style(
          textAlign: TextAlign.center,
          color: isDarkMode ? Colors.white : const Color(0xFF990000),
          fontSize: FontSize(fontSize.size),
          margin: Margins.symmetric(vertical: 10),
          padding: HtmlPaddings.zero,
        ),
        '.psm': Style(
          textAlign: TextAlign.center,
          color: isDarkMode ? Colors.white : const Color(0xFF990000),
          fontSize: FontSize(fontSize.size * 0.8),
          margin: Margins.symmetric(vertical: 10),
          padding: HtmlPaddings.zero,
        ),
        '.shareh': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF996633),
        ),
        '.msaleh': Style(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        '.onwan': Style(
          color: isDarkMode ? Colors.white : const Color(0xFF088888),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        '.fn': Style(
          color: isDarkMode ? const Color(0xff8a8afa) : const Color(0xFF000080),
          fontWeight: FontWeight.normal,
          fontSize: FontSize(fontSize.size * 0.75),
          textDecoration: TextDecoration.none,
          verticalAlign: VerticalAlign.top,
        ),
        '.fm': Style(
          color: isDarkMode ? Color(0xffa2e1a2) : Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize.size * 0.75),
          textDecoration: TextDecoration.none,
        ),
        '.quran': Style(
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize.size),
          color: isDarkMode ? Color(0xffa2e1a2) : const Color(0xFF509368),
          fontFamily: fontFamily.name,
        ),
        '.hadith': Style(
          fontSize: FontSize(fontSize.size),
          color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
        ),
        '.hadith-num': Style(
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize.size),
          color: isDarkMode ? Color(0xfff9825e) : Colors.red,
          fontFamily: fontFamily.name,
        ),
        '.shreah': Style(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
          fontFamily: fontFamily.name,
        ),
        '.kalema': Style(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : const Color(0xFFCC0066),
        ),
        'mark': Style(
          backgroundColor: Colors.yellow,
        ),
      },
    );
  }

  String _processHtmlContent(String content) {
    // Add any preprocessing logic here if needed
    return content;
  }

  // Helper function to convert Arabic numbers to Latin numbers
  String _convertArabicToLatin(String input) {
    final arabicToLatin = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9'
    };

    String result = input;
    arabicToLatin.forEach((arabic, latin) {
      result = result.replaceAll(arabic, latin);
    });
    return result;
  }



  void _showPageJumpDialog(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController pageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: pageController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل رقم الصفحة (بين 1 و ${_content.length})',
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1), // Grey underline when not focused
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1), // Black underline when focused
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.5), // Red underline for validation errors
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2), // Red underline when error & focused
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الصفحة';
                }
                // Convert Arabic numbers to Latin before parsing
                final String latinValue = _convertArabicToLatin(value);
                final int? pageNumber = int.tryParse(latinValue);
                if (pageNumber == null || pageNumber <= 0 || pageNumber > _content.length) {
                  return ' الرقم يجب أن يكون بين ١ و ${_content.length}';
                }
                return null;  // Means the input is valid
              },
              onFieldSubmitted: (value) {
                if (formKey.currentState!.validate()) {
                  final String latinValue = _convertArabicToLatin(value);
                  final int? pageNumber = int.tryParse(latinValue);
                  _jumpTo(pageNumber: pageNumber! - 1);
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء', style: Theme.of(context).textTheme.labelLarge),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('انتقل',  style: Theme.of(context).textTheme.labelLarge),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final String latinValue = _convertArabicToLatin(pageController.text);
                  final int? pageNumber = int.tryParse(latinValue);
                  _jumpTo(pageNumber: pageNumber! - 1);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }



  void _search(String value) {
    searchedWord = value;
    context.read<EpubViewerCubit>().searchUsingHtmlList(value);
  }

  void _handleSearchResultTap(SearchModel result) {
    setState(() {
      _currentSearchIndex = _currentSearchResults.indexOf(result);
    });
    context.read<EpubViewerCubit>().highlightContent(
      result.pageIndex,
      searchedWord
    );
  }

  void _navigateToNextResult() {
    if (_currentSearchIndex < _currentSearchResults.length - 1) {
      setState(() {
        _currentSearchIndex++;
      });
      context.read<EpubViewerCubit>().highlightContent(
        _currentSearchResults[_currentSearchIndex].pageIndex,
        searchedWord
      );
    }
  }

  void _navigateToPreviousResult() {
    if (_currentSearchIndex > 0) {
      setState(() {
        _currentSearchIndex--;
      });
      context.read<EpubViewerCubit>().highlightContent(
        _currentSearchResults[_currentSearchIndex].pageIndex,
        searchedWord
      );
    }
  }

  _openInternalSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InternalSearchScreen(
          cubit: context.read<EpubViewerCubit>(),
        ),
      ),
    );
  }

  Future<void> _addBookmark(BuildContext context) async {
    final String? headingTitle = _findPreviousHeading(_currentPage);

    final reference = ReferenceModel(
      title: headingTitle ?? ' علامة مرجعية على كتاب $_bookName',
      bookName: _bookName,
      bookPath: widget.referenceModel?.bookPath ?? _bookPath!,
      navIndex: _currentPage.toString(),
    );

    // Await the addBookmark function
    await BlocProvider.of<EpubViewerCubit>(context).addBookmark(reference);

    // Await the checkBookmark function
    await context.read<EpubViewerCubit>().checkBookmark(_bookPath!, _currentPage.toString());

    // Finally, load all bookmarks
    await BlocProvider.of<BookmarkCubit>(context).loadAllBookmarks();

  }


  void _openInternalToc(BuildContext context) {
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
                    tocTreeList: _tocList ?? [],
                    scrollController: scrollController,
                    epubViewerCubit: this.context.read<EpubViewerCubit>(),
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
                              icon: const Icon(Icons.arrow_back),
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

  _showBottomSheet(BuildContext context, EpubViewerCubit cubit) {
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
                  StyleSheet(epubViewerCubit: cubit, lineSpace: lineHeight, fontFamily: fontFamily, fontSize: fontSize),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  _determineEpubSourceAndLoad() {
    if (widget.referenceModel != null) {
      _loadEpubFromBookmark();
    } else if (widget.tocModel != null) {
      _loadEpubFromTableOfContents();
    } else if (widget.searchModel != null) {
      _loadEpubFromSearchResult();
    } else if (widget.historyModel != null){
      _loadEpubFromHistory();
    } else {
      _loadEpubFromCategory();
    }
  }

  _loadEpubFromBookmark() {
    final int bookmarkPageNumber =
        int.tryParse(widget.referenceModel?.navIndex ?? '') ?? 0;
    // _pageController.jumpToPage(bookmarkPageNumber);
    _bookPath = widget.referenceModel!.bookPath;
    _loadAndParseEpub(bookPath: _bookPath!);
    if (_bookPath == '0.epub'){
      isAboutUsBook = true;
    }
  }


  _loadEpubFromHistory() {
    final int bookmarkPageNumber =
        int.tryParse(widget.historyModel?.navIndex ?? '') ?? 0;
    // _pageController.jumpToPage(bookmarkPageNumber);
    _bookPath = widget.historyModel!.bookPath;
    _loadAndParseEpub(bookPath: _bookPath!);
    if (_bookPath == '0.epub'){
      isAboutUsBook = true;
    }
  }

  _loadEpubFromTableOfContents() {
    _bookPath = widget.tocModel!.epubChapter.ContentFileName;
    _loadAndParseEpub(
        bookPath: widget.tocModel!.bookPath, fileName: _bookPath!,);
  }

  _loadEpubFromSearchResult() {
    _bookPath = widget.searchModel!.bookAddress;
    _loadAndParseEpub(
        bookPath: _bookPath!,);
  }

  _loadEpubFromCategory() {
    _bookPath = widget.book!.epub!;
    _loadAndParseEpub(bookPath: _bookPath!);

  }



  _loadAndParseEpub({required String bookPath, String? fileName}) {
    context.read<EpubViewerCubit>().loadAndParseEpub('$_pathUrl$bookPath');
  }

  @override
  void dispose() {
    // Save the history before disposing
    if (_epubViewerCubit != null) {
      _saveHistory(); // Save the last visited page before disposing
    }

    final pageHelper = PageHelper();
    pageHelper.saveBookData(widget.referenceModel?.bookPath?? _bookPath!, _currentPage);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values,);
    itemPositionsListener.itemPositions.removeListener(() {});
    focusNode.dispose();
    textEditingController.dispose();
    _htmlCache.clear();
    _processedContentCache.clear();

    super.dispose();
  }

  Future<void> _saveHistory() async {
    if (_bookPath == null || _bookName.isEmpty) return;
    final String? headingTitle = _findPreviousHeading(_currentPage);

    final history = HistoryModel(
      title: headingTitle ?? ' علامة مرجعية على كتاب $_bookName',
      bookName: _bookName,
      bookPath: _bookPath!,
      navIndex: _currentPage.toString(),
    );

    // Save the history using your database logic
    await _epubViewerCubit!.addHistory(history);

  }


  String _getAppBarTitle(EpubViewerState state) => state.maybeWhen(
      loaded: (_, title, __) => title,
      orElse: () => '',
    );


  _changeStyle(FontSizeCustom? fontSize, LineHeightCustom? lineHeight,
      FontFamily? fontFamily,) {
    this.fontFamily = fontFamily ?? FontFamily.font1;
    this.lineHeight = lineHeight ?? LineHeightCustom.medium;
    this.fontSize = fontSize ?? FontSizeCustom.medium;
  }

  _jumpTo({int? pageNumber}) {
    if (!_isControllerInitialized || pageNumber == null) return;
    
    try {
      itemScrollController.jumpTo(index: pageNumber);
      _currentPage = pageNumber.toDouble();
      if (_bookPath != null) {
        context.read<EpubViewerCubit>().checkBookmark(_bookPath!, _currentPage.toString());
      }
    } catch (e) {
      debugPrint('Error jumping to page: $e');
    }
  }

  _storeCurrentPage({int? currentPageNumber}) {
    final newPage = currentPageNumber?.toDouble() ?? 0.0;
    if (_currentPage != newPage) {
      _currentPage = currentPageNumber?.toDouble() ?? 0.0;
    }
  }

  Future<void> _removeBookmark(BuildContext context) async {
    // Await the removeBookmark function
    await context.read<EpubViewerCubit>().removeBookmark(_bookPath!, _currentPage.toString());

    // Await the checkBookmark function
    await context.read<EpubViewerCubit>().checkBookmark(_bookPath!, _currentPage.toString());

    // Finally, load all bookmarks
    await BlocProvider.of<BookmarkCubit>(context).loadAllBookmarks();
  }


  String? _findPreviousHeading(double currentPage) {
    String? headingText;
    final int contentIndex = currentPage.toInt();

    // Traverse the pages backward from the current page to find the first heading
    for (int i = contentIndex; i >= 0; i--) {
      final dom.Document document = html_parser.parse(_content[i]);
      final List<dom.Element> headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');

      if (headings.isNotEmpty) {
        // Check if the heading has a title attribute
        final dom.Element lastHeading = headings.last;
        final String? title = lastHeading.attributes['title'];

        if (title != null) {
          headingText = title.trim();
        } else {
          headingText = lastHeading.text.trim();
        }
        break;
      }
    }

    return headingText;
  }







  void _updateCurrentPage(double newPage) {
    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage;
      });
      // Debounce the bookmark check to reduce database calls
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<EpubViewerCubit>().checkBookmark(_bookPath!, _currentPage.toString());
        }
      });
    }
  }

  void _handleAnchorTap(String? href, Map<String, String> attributes, dom.Element? element) {
    if (href != null) {
      final Uri uri = Uri.parse(href);
      if (uri.fragment.isNotEmpty) {
        _handleFragment(href);
      } else {
        debugPrint('Anchor href: $href'); // For cases without `#`
      }
    }
  }

  Future<void> _handleFragment(String fragment) async {
    String ids = fragment.split('#').last;
    final databaseRepository = DatabaseRepository();
    Word? word = await databaseRepository.getWordById(int.parse(ids));
      // If no data is found, show a default message
    if (word == null) {
      await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Error'),
              content: const Text('No details found for this reference.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
      _showSingleWordDialog(word);

  }

  void _showSingleWordDialog(Word? word) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => WordBottomSheetContent(
          word: word,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Widget _buildTranslationChip(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.secondaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
        labelStyle: TextStyle(
          color: isSelected 
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class TranslationBottomSheetContent extends StatefulWidget {
  final Map<String, dynamic> translation;

  const TranslationBottomSheetContent({
    Key? key,
    required this.translation,
  }) : super(key: key);

  @override
  State<TranslationBottomSheetContent> createState() => _TranslationBottomSheetContentState();
}

class _TranslationBottomSheetContentState extends State<TranslationBottomSheetContent> {
  String selectedTranslation = ''; // Will be set dynamically
  late FontSizeCustom _fontSize;
  late LineHeightCustom _lineHeight;
  late FontFamily _fontFamily;

  @override
  void initState() {
    super.initState();
    _loadFontPreferences();
    _setInitialTranslation();
  }

  void _setInitialTranslation() {
    // Set the first available translation as selected
    if (widget.translation['فارسي ـ جعفري'] != null) {
      selectedTranslation = 'فارسي ـ جعفري';
    } else if (widget.translation['فارسي ـ انصاريان'] != null) {
      selectedTranslation = 'فارسي ـ انصاريان';
    } else if (widget.translation['فارسي ـ فيض الإسلام'] != null) {
      selectedTranslation = 'فارسي ـ فيض الإسلام';
    } else if (widget.translation['فارسي ـ شهيدي'] != null) {
      selectedTranslation = 'فارسي ـ شهيدي';
    } else if (widget.translation['English'] != null) {
      selectedTranslation = 'English';
    }
  }

  Future<void> _loadFontPreferences() async {
    final styleHelper = await StyleHelper.loadFromPrefs();
    setState(() {
      _fontSize = styleHelper.fontSize;
      _lineHeight = styleHelper.lineSpace;
      _fontFamily = styleHelper.fontFamily;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Top bar with title and controls
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: Center(
                        child: Text(
                          'الترجمة',
                          style: Theme.of(context).textTheme.titleLarge
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Translation chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (widget.translation['فارسي ـ جعفري'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ جعفري',
                      selectedTranslation == 'فارسي ـ جعفري',
                      () => setState(() => selectedTranslation = 'فارسي ـ جعفري'),
                    ),
                  if (widget.translation['فارسي ـ انصاريان'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ انصاريان',
                      selectedTranslation == 'فارسي ـ انصاريان',
                      () => setState(() => selectedTranslation = 'فارسي ـ انصاريان'),
                    ),
                  if (widget.translation['فارسي ـ فيض الإسلام'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ فيض الإسلام',
                      selectedTranslation == 'فارسي ـ فيض الإسلام',
                      () => setState(() => selectedTranslation = 'فارسي ـ فيض الإسلام'),
                    ),
                  if (widget.translation['فارسي ـ شهيدي'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ شهيدي',
                      selectedTranslation == 'فارسي ـ شهيدي',
                      () => setState(() => selectedTranslation = 'فارسي ـ شهيدي'),
                    ),
                  if (widget.translation['English'] != null)
                    _buildTranslationChip(
                      context,
                      'English',
                      selectedTranslation == 'English',
                      () => setState(() => selectedTranslation = 'English'),
                    ),
                ],
              ),
            ),
            // Selected translation content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (widget.translation[selectedTranslation] != null)
                      buildCard(
                        context,
                        widget.translation[selectedTranslation].toString(),
                        selectedTranslation,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTranslationChip(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            fontFamily: 'almarai',
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        checkmarkColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Colors.transparent,
        selectedColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Card buildCard(BuildContext context, String content, String title) {
    final bool isEnglish = selectedTranslation == 'English';
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: Html(
                data: content,
                style: {
                  ...StyleHelper.getStyles(context),
                  'html': Style(
                    fontSize: FontSize(_fontSize.size),
                    lineHeight: LineHeight(_lineHeight.size),
                    textAlign: TextAlign.justify,
                    color: isDarkMode ? const Color(0xFFE0E0E0) : Theme.of(context).colorScheme.onSurface,
                    fontFamily: isEnglish ? 'arial' : _fontFamily.name,
                  ),
                  'h1': Style(
                    fontSize: FontSize(_fontSize.size * 1.2),
                    color: isDarkMode ? Colors.white : const Color(0xFF00AA00),
                    textAlign: isEnglish ? TextAlign.left: TextAlign.right,
                    fontFamily: isEnglish ? 'arial': _fontFamily.name,
                  ),
                  'p': Style(
                    textAlign: TextAlign.justify,
                    fontFamily: isEnglish ? 'arial' : _fontFamily.name,
                  ),
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}




