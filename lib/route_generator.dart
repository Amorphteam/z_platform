import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/screen/bookmark/bookmark_screen.dart';
import 'package:zahra/screen/bookmark/cubit/bookmark_cubit.dart';
import 'package:zahra/screen/epub_viewer/cubit/epub_viewer_cubit.dart';
import 'package:zahra/screen/epub_viewer/epub_viewer_screen.dart';
import 'package:zahra/screen/host/cubit/host_cubit.dart';
import 'package:zahra/screen/host/host_screen.dart';
import 'package:zahra/screen/library/cubit/library_cubit.dart';
import 'package:zahra/screen/library/library_screen.dart';
import 'package:zahra/screen/search/cubit/search_cubit.dart';
import 'package:zahra/screen/search/search_screen.dart';
import 'package:zahra/screen/toc/cubit/toc_cubit.dart';
import 'package:zahra/screen/toc/toc_screen.dart';
import 'package:zahra/screen/toc_with_number/cubit/toc_with_number_cubit.dart';
import 'package:zahra/screen/toc_with_number/toc_with_number_screen.dart';
import 'model/book_model.dart';
import 'model/reference_model.dart';
import 'model/search_model.dart';
import 'model/tree_toc_model.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case '/toc_with_number':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => TocWithNumberCubit(),
            child: TocWithNumberScreen(),
          ),
        );
      case '/searchScreen':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => HostCubit(),
            child: const HostScreen(),
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