import 'dart:io';
import 'package:audio_player/audio_player.dart';
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
import 'package:masaha/screen/toc/cubit/toc_cubit.dart';
import 'package:masaha/screen/toc/toc_screen.dart';
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
import 'model/baqyat_sound_model.dart';
import 'util/constants.dart';
import 'util/baqyat_sound_helper.dart';
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
              child: _EpubViewerRouteWrapper(
                entryData: entryData,
                enableContentCache: enableContentCache,
                customStyle: customStyle,
                customStyleBuilder: customStyleBuilder,
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
      case '/toc':
        final tocId = args?['id'] as int?;
        final tocTitle = args?['title'] as String?;
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => BlocProvider(
            create: (context) => TocCubit(),
            child: TocScreen(id: tocId, title: tocTitle),
          ),
        );
      case '/audioPlayer':
        if (args != null) {
          final List<AudioTrack> tracks = args['tracks'] as List<AudioTrack>;
          final int? initialIndex = args['initialIndex'] as int?;
          
          // Show as modal bottom sheet
          return MaterialPageRoute(
            builder: (context) {
              // Show bottom sheet immediately when route is pushed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final content = BlocProvider(
                  create: (context) => AudioPlayerCubit(),
                  child: AudioPlayerScreen(
                    tracks: tracks,
                    initialIndex: initialIndex,
                  ),
                );
                
                if (isIOS) {
                  showCupertinoModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    expand: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => content,
                  ).then((_) {
                    // Pop the route when bottom sheet is dismissed
                    if (context.mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                } else {
                  showMaterialModalBottomSheet(
                    context: context,
                    expand: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => content,
                  ).then((_) {
                    // Pop the route when bottom sheet is dismissed
                    if (context.mounted && Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                }
              });
              
              // Return empty container while bottom sheet is shown
              return const SizedBox.shrink();
            },
            fullscreenDialog: false,
          );
        }
        return _errorRoute();
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

class _EpubViewerRouteWrapper extends StatefulWidget {
  const _EpubViewerRouteWrapper({
    required this.entryData,
    required this.enableContentCache,
    required this.customStyle,
    required this.customStyleBuilder,
  });

  final epub_viewer.EpubViewerEntryData entryData;
  final bool enableContentCache;
  final Map<String, Style>? customStyle;
  final dynamic customStyleBuilder;

  @override
  State<_EpubViewerRouteWrapper> createState() => _EpubViewerRouteWrapperState();
}

class _EpubViewerRouteWrapperState extends State<_EpubViewerRouteWrapper> {
  Map<int, BaqyatSoundItem> _soundsByChapterId = const {};

  @override
  void initState() {
    super.initState();
    _loadBaqyatSounds();
  }

  Future<void> _loadBaqyatSounds() async {
    final response = await BaqyatSoundHelper().getBaqyatSounds();
    if (!mounted) return;

    final mapped = <int, BaqyatSoundItem>{};
    for (final item in response.data) {
      mapped[item.id] = item;
    }

    setState(() {
      _soundsByChapterId = mapped;
    });
  }

  int? _extractChapterIdFromFileName(String? fileName) {
    if (fileName == null || fileName.trim().isEmpty) return null;
    final base = fileName.split('/').last;
    final stem = base.split('.').first;
    return int.tryParse(stem);
  }

  bool _hasAudioForSection(String? sectionFileName) {
    final chapterId = _extractChapterIdFromFileName(sectionFileName);
    if (chapterId == null) return false;
    return _soundsByChapterId.containsKey(chapterId);
  }

  void _openAudioForSection(BuildContext context, String? sectionFileName) {
    final chapterId = _extractChapterIdFromFileName(sectionFileName);
    if (chapterId == null) return;

    final soundItem = _soundsByChapterId[chapterId];
    if (soundItem == null) return;

    final tracks = soundItem.files
        .map((file) {
          final sourceUrl = file.pathM4a ?? file.path;
          if (sourceUrl == null || sourceUrl.isEmpty) return null;

          final seconds = double.tryParse(file.duration) ?? 0;
          return AudioHelper.createTrack(
            id: '${soundItem.id}_${file.readerId}',
            title: soundItem.title,
            url: sourceUrl,
            artist: file.readerName,
            artworkUrl: file.picPath,
            duration: Duration(milliseconds: (seconds * 1000).round()),
          );
        })
        .whereType<AudioTrack>()
        .toList();

    if (tracks.isEmpty) return;
    AudioHelper.playPlaylist(context, tracks);
  }

  @override
  Widget build(BuildContext context) {
    return epub_viewer.EpubViewerScreenV2(
      entryData: widget.entryData,
      enableContentCache: widget.enableContentCache,
      customStyle: widget.customStyle,
      customStyleBuilder: widget.customStyleBuilder,
      onBookmarksChanged: () async {
        try {
          final bookmarkCubit = context.read<BookmarkCubit>();
          bookmarkCubit.loadAllBookmarks();
        } catch (_) {
          // BookmarkCubit not available in ancestor tree – ignore.
        }
      },
      onAnchorIdTap: (ctx, anchorId) async {
        if (!ctx.mounted) return;
        showModalBottomSheet(
          context: ctx,
          isScrollControlled: true,
          builder: (_) => Container(
            padding: const EdgeInsets.all(20),
            height: 600,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(anchorId)],
            ),
          ),
        );
      },
      showBottomBar: true,
      showAppBarSearchButton: true,
      showAppBarTocButton: true,
      extraActionIcon:
          Platform.isIOS ? CupertinoIcons.music_note_2 : Icons.audiotrack_rounded,
      isExtraActionVisible: ({
        required pageNumber,
        required sectionName,
        required bookName,
        required bookPath,
      }) {
        return _hasAudioForSection(sectionName);
      },
      onExtraActionPressed: (
        ctx, {
        required pageNumber,
        required sectionName,
        required bookName,
        required bookPath,
      }) {
        _openAudioForSection(ctx, sectionName);
      },
    );
  }
}
