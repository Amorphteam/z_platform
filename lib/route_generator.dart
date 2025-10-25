import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masaha/screen/bookmark/bookmark_screen.dart';
import 'package:masaha/screen/bookmark/cubit/bookmark_cubit.dart';
import 'package:masaha/screen/chat/chat_screen.dart';
import 'package:masaha/screen/chat/cubit/chat_cubit.dart';
import 'package:masaha/screen/epub_viewer/cubit/epub_viewer_cubit.dart';
import 'package:masaha/screen/epub_viewer/epub_viewer_screen.dart';
import 'package:masaha/screen/host/cubit/host_cubit.dart';
import 'package:masaha/screen/host/host_screen.dart';
import 'package:masaha/screen/library/cubit/library_cubit.dart';
import 'package:masaha/screen/library/library_screen.dart';
import 'package:masaha/screen/search/cubit/search_cubit.dart';
import 'package:masaha/screen/search/search_screen.dart';
import 'package:masaha/screen/toc/cubit/toc_cubit.dart';
import 'package:masaha/screen/toc/toc_screen.dart';
import 'package:masaha/screen/color_palette/color_palette_screen.dart';
import 'package:masaha/screen/liquid_glass_test/liquid_glass_test_screen.dart';
import 'model/book_model.dart';
import 'model/reference_model.dart';
import 'model/search_model.dart';
import 'model/tree_toc_model.dart';
import 'util/constants.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => HostCubit(),
            child: HostScreen(),
          ),
        );
      case '/searchScreen':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
              create: (context) => SearchCubit(),
              child: SearchScreen(),
            ),
        );
      case '/epubViewer':
        if (args != null) {
          final Book? cat = args['cat'];
          final ReferenceModel? reference = args['reference'];
          final EpubChaptersWithBookPath? toc = args['toc'];
          final SearchModel? search = args['search'];

          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => EpubViewerCubit(),
              child: EpubViewerScreen(
                book: cat,
                referenceModel: reference,
                searchModel: search,
                tocModel: toc,
              ),
            ),
          );
        }
        return _errorRoute();
      case '/colorPalette':
        return MaterialPageRoute(
          builder: (context) => const ColorPaletteScreen(),
        );
      case '/chat':
        return MaterialPageRoute(
          builder: (context) {
            final chatCubit = ChatCubit();
            // Initialize AI service with API key
            chatCubit.apiKey = Constants.openAIApiKey;
            return BlocProvider(
              create: (context) => chatCubit,
              child: const ChatScreen(),
            );
          },
        );
      case '/liquidGlassTest':
        return MaterialPageRoute(
          builder: (context) => const LiquidGlassTestScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() => MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Error: Page not found')),
      ),
    );
}