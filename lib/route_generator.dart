import 'dart:io';
import 'package:epub_search/epub_search.dart' as epub_search_package;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:epub_viewer/epub_viewer.dart' as epub_viewer;
import 'package:epub_bookmarks/epub_bookmarks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masaha/screen/chat/chat_screen.dart';
import 'package:masaha/screen/chat/cubit/chat_cubit.dart';
import 'package:masaha/api/ai_provider.dart';
import 'package:masaha/screen/host/cubit/host_cubit.dart';
import 'package:masaha/screen/host/host_screen.dart';
import 'package:masaha/screen/color_palette/color_palette_screen.dart';
import 'package:masaha/screen/color_picker/color_picker_screen.dart';
import 'package:masaha/screen/liquid_glass_test/liquid_glass_test_screen.dart';
import 'package:masaha/epub_integration/epub_adapter_factory.dart'
    as epub_adapters;
import 'model/book_model.dart';
import 'model/deep_link_model.dart';
import 'model/history_model.dart';
import 'model/reference_model.dart';
import 'model/search_model.dart' as host_search;
import 'model/tree_toc_model.dart';
import 'util/constants.dart';
import 'util/epub_helper.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final isIOS = Platform.isIOS;

    switch (settings.name) {
      case '/':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => BlocProvider(
            create: (context) => HostCubit(),
            child: HostScreen(),
          ),
        );
      case '/epubViewer':
        if (args != null) {
          final epub_viewer.EpubViewerEntryData? providedEntryData =
              args['entryData'] as epub_viewer.EpubViewerEntryData?;
          final bool enableContentCache = args['enableContentCache'] is bool
              ? args['enableContentCache'] as bool
              : true;
          final Book? cat = args['cat'];
          final ReferenceModel? reference = args['reference'];
          final HistoryModel? history = args['history'];
          final EpubChaptersWithBookPath? toc = args['toc'];
          final host_search.SearchModel? search = args['search'];
          final DeepLinkModel? deepLink = args['deepLink'];
          // Support legacy fileName parameter for backward compatibility
          final String? fileName = args['fileName'];
          final Map<String, Style>? customStyle = args['customStyle'] as Map<String, Style>?;
          // CustomStyleBuilder is a typedef exported from epub_viewer package
          // We extract it without casting since typedefs can't be used in 'as' expressions
          // The package will validate the function signature matches CustomStyleBuilder
          final customStyleBuilder = args['customStyleBuilder'];

          // Create DeepLinkModel from legacy fileName if needed
          DeepLinkModel? deepLinkModel = deepLink;
          if (deepLinkModel == null && fileName != null && reference != null) {
            deepLinkModel = DeepLinkModel(
              fileName: fileName,
              epubName: reference.bookPath,
              epubIndex: null,
            );
          }

          final epub_viewer.EpubViewerEntryData entryData = providedEntryData ??
              epub_viewer.EpubViewerEntryData(
                primaryBookPath: cat?.epub,
                bookmarkBookPath: reference?.bookPath,
                bookmarkFileName: reference?.fileName,
                bookmarkPageIndex: reference?.navIndex,
                historyBookPath: history?.bookPath,
                historyPageIndex: history?.navIndex,
                searchBookPath: search?.bookAddress,
                searchPageIndex: search?.pageIndex,
                searchQuery: search?.searchedWord,
                tocBookPath: toc?.bookPath,
                tocChapterFileName: toc?.epubChapter.ContentFileName,
                deepLinkBookPath: deepLinkModel?.epubName,
                deepLinkPageIndex: deepLinkModel?.epubIndex,
                deepLinkChapterFileName: deepLinkModel?.fileName,

              );

          return _buildRoute(
            isIOS: isIOS,
            builder: (context) => BlocProvider(
              create: (context) => epub_viewer.EpubViewerCubit(
                persistence: epub_adapters.createEpubViewerPersistence(),
              ),
              child: epub_viewer.EpubViewerScreenV2(
                entryData: entryData,
                enableContentCache: enableContentCache,
                customStyle: customStyle,
                customStyleBuilder: customStyleBuilder,
                onBookmarksChanged: () async {
                  try {
                    final bookmarkCubit = context.read<BookmarkCubit>();
                    bookmarkCubit.loadAllBookmarks();
                  } catch (_) {
                    // BookmarkCubit not available in ancestor tree – ignore.
                  }
                },
                onAnchorIdTap: (ctx, anchorId) async {
                  // anchorId already includes '#', e.g. "#note_12"
                  // 1) query your DB using anchorId as filter
                  final data = 'await myRepository.loadByAnchor(anchorId)';

                  // 2) show bottom sheet for this app
                  if (!ctx.mounted) return;
                  showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    builder: (_) => Container(
                      padding: EdgeInsets.all(20),
                      height: 600,
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [Text(anchorId)],
                      ),
                    ),
                  );
                },
                onTranslatePressed: (ctx,
                    {required pageNumber,
                    required sectionName,
                    required bookName,
                    required bookPath}) {
                  showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    builder: (_) => Container(
                      padding: EdgeInsets.all(20),
                      height: 600,
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('''
                          کتاب $bookName 
                          عنوان $bookPath
                          الصفحة${pageNumber + 1}
                          '''),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return _errorRoute();
      case '/bookmarkScreen':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => BookmarkScreen(
            persistence: epub_adapters.createBookmarkPersistence(),
            appBar: BookmarkAppBar(
              title: 'منصة مساحة',
            ),
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
          ),
        );
      case '/colorPalette':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => const ColorPaletteScreen(),
        );
      case '/colorPicker':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => const ColorPickerScreen(),
        );
      case '/chat':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) {
            final chatCubit = ChatCubit();
            // Initialize AI service with both API keys
            try {
              chatCubit.setOpenAIApiKey(Constants.openAIApiKey);
            } catch (e) {
              // OpenAI key not set, will show error when trying to use ChatGPT
            }
            final claudeKey = Constants.claudeApiKey;
            if (claudeKey != null && claudeKey.isNotEmpty) {
              chatCubit.setClaudeApiKey(claudeKey);
            }
            // Set EPUB asset path for Claude (use the same EPUB as vector store if available)
            // You can change this to any EPUB file in assets/epub/ (e.g., 'assets/epub/1.epub')
            chatCubit.setEpubAssetPath('assets/epub/mafatih.epub'); // Default to first EPUB
            // Default to ChatGPT
            chatCubit.setProvider(AIProvider.chatGPT);
            return BlocProvider(
              create: (context) => chatCubit,
              child: const ChatScreen(),
            );
          },
        );
      case '/liquidGlassTest':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => const LiquidGlassTestScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _buildRoute({
    required bool isIOS,
    required WidgetBuilder builder,
  }) {
    // Use MaterialWithModalsPageRoute to support iOS-style modal bottom sheets
    return MaterialWithModalsPageRoute(
      builder: builder,
    );
  }

  static Route _errorRoute() => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Error: Page not found')),
        ),
      );
}
