import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cupertino_native/cupertino_native.dart';

import 'package:epub_bookmarks/epub_bookmarks.dart';
import 'package:epub_search/epub_search.dart' as epub_search_package;

import 'package:masaha/epub_integration/epub_adapter_factory.dart'
    as epub_adapters;
import 'package:masaha/screen/home/cubit/home_cubit.dart';
import 'package:masaha/screen/home/home_screen.dart';

import '../../model/search_model.dart';
import '../../model/reference_model.dart';
import '../../model/history_model.dart';
import '../../repository/json_repository.dart';
import '../../util/epub_helper.dart';
import '../library/cubit/library_cubit.dart';
import '../library/library_screen.dart';
import '../toc/cubit/toc_cubit.dart';
import '../toc/toc_screen.dart';
import '../../widget/toc_nav_provider.dart';
import 'package:audio_player/audio_player.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  _HostScreenState createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  int _currentIndex = 0;
  int? _tocIdToLoad;
  String? _tocTitle;

  // Helper function to check iOS version support for liquid glass
  bool _shouldUseLiquidGlass() {
    if (!Platform.isIOS) return false;
    try {
      // iOS 16+ supports liquid glass
      final String version = Platform.operatingSystemVersion;
      if (version.contains('26')) {
        return true;
      }
      return false;
    } catch (e) {
      // If we can't detect version, use Material design for compatibility
      return false;
    }
  }

  late final LibraryCubit _libraryCubit;

  @override
  void initState() {
    super.initState();
    _libraryCubit = LibraryCubit();
  }

  @override
  void dispose() {
    _libraryCubit.close();
    super.dispose();
  }

  void _openTocWithId(int? id, String? title) {
    setState(() {
      _currentIndex = 2;
      _tocIdToLoad = id;
      _tocTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TocNavProvider(
      openToc: _openTocWithId,
      child: Scaffold(
      extendBody: _shouldUseLiquidGlass(),
      body: Stack(
        children: [
          _getScreen(_currentIndex),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AudioPlayerMini(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _shouldUseLiquidGlass()
          ? // Liquid Glass Tab Bar for iOS 16+
      Material(
        color: Colors.transparent,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            primaryColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
         child: CNTabBar(
              items: const [
                CNTabBarItem(
                  label: 'الإشارات',
                  icon: CNSymbol('bookmark.fill'),
                ),
                CNTabBarItem(
                  label: 'البحث',
                  icon: CNSymbol('magnifyingglass'),
                ),
                CNTabBarItem(
                  label: 'الموضوعي',
                  icon: CNSymbol('book.fill'),
                ),
                CNTabBarItem(
                  label: 'الرئيسية',
                  icon: CNSymbol('house.fill'),
                ),
                CNTabBarItem(
                  label: 'القالب',
                  icon: CNSymbol('menucard.fill'),
                ),
              ],
              currentIndex: 4 - _currentIndex, // Reverse index for RTL
              onTap: (index) {
                setState(() {
                  _currentIndex = 4 - index; // Reverse index back
                  if (_currentIndex != 2) _tocIdToLoad = null;
                });
              },
            )))
          : // Material Bottom Navigation Bar for Android
          Directionality(
              textDirection: TextDirection.rtl,
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                    if (_currentIndex != 2) _tocIdToLoad = null;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                        _currentIndex == 0 ? Icons.line_style_rounded : Icons.line_style_outlined),
                    label: 'القالب',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                        _currentIndex == 1 ? Icons.home : Icons.home_outlined),
                    label: 'الرئيسية',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(_currentIndex == 2
                        ? Icons.library_books
                        : Icons.library_books_outlined),
                    label: 'الموضوعي',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(_currentIndex == 3
                        ? CupertinoIcons.search_circle_fill
                        : CupertinoIcons.search),
                    label: 'البحث',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(_currentIndex == 4
                        ? CupertinoIcons.bookmark_solid
                        : CupertinoIcons.bookmark),
                    label: 'الإشارات',
                  ),

                ],
              ),
            ),
      ),
    );
  }

  /// Returns the title for the app bar dynamically.
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'اخترنا لكم';
      case 1:
        return 'الفهرست';
      case 2:
        return 'الكتب';
      case 2:
        return 'البحث';
      case 3:
        return 'العلامات';
      default:
        return '';
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return BlocProvider(
          create: (context) => HomeCubit(JsonRepository()),
          child: const HomeScreen(),
        );
      case 1:
        return BlocProvider.value(
          value: _libraryCubit,
          child: LibraryScreen(),
        );
      case 2:
        return BlocProvider(
          create: (context) => TocCubit(),
          child: TocScreen(id: _tocIdToLoad, title: _tocTitle),
        );
      // case 2:
      //   return BlocProvider(
      //     create: (context) => LibraryCubit(),
      //     child: const LibraryScreen(),
      //   );
      case 3:
        return epub_search_package.SearchScreen(
          persistence: epub_adapters.createSearchPersistence(),
          onResultTap: (epub_search_package.SearchModel result) {
            // Convert epub_search package's SearchModel to our local SearchModel
            final searchResult = SearchModel(
              pageIndex: result.pageIndex,
              searchCount: result.searchCount,
              bookAddress: result.bookAddress,
              bookTitle: result.bookTitle,
              pageId: result.pageId,
              searchedWord: result.searchedWord,
              spanna: result.spanna ?? '',
            );
            openEpub(context: context, search: searchResult);
          },
        );

      case 4:
        return BookmarkScreen(
          persistence: epub_adapters.createBookmarkPersistence(),
          onBookmarkTap: (screenContext, bookmark) async {
            final reference = ReferenceModel(
              id: bookmark.id,
              title: bookmark.title,
              bookName: bookmark.bookName,
              bookPath: bookmark.bookPath,
              navIndex: bookmark.pageIndex,
              fileName: bookmark.fileName,
            );
            await openEpub(context: screenContext, reference: reference);
          },
          onHistoryTap: (screenContext, history) async {
            final historyModel = HistoryModel(
              id: history.id,
              title: history.title,
              bookName: history.bookName,
              bookPath: history.bookPath,
              navIndex: history.pageIndex,
            );
            await openEpub(context: screenContext, history: historyModel);
          },
        );
      default:
        return Container();
    }
  }
}
