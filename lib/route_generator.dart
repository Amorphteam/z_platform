import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/repository/json_repository.dart';
import 'package:zahra/screen/epub_viewer/cubit/epub_viewer_cubit.dart';
import 'package:zahra/screen/epub_viewer/epub_viewer_screen.dart';
import 'package:zahra/screen/search/cubit/search_cubit.dart';
import 'package:zahra/screen/search/search_screen.dart';
import 'model/category_model.dart';
import 'model/reference_model.dart';
import 'model/search_model.dart';
import 'model/tree_toc_model.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case '/searchScreen':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
              create: (context) => SearchCubit(),
              child: const SearchScreen(),
            ),
        );
      case '/epubViewer':
        if (args != null) {
          final CategoryModel? cat = args['cat'];
          final ReferenceModel? reference = args['reference'];
          final EpubChaptersWithBookPath? toc = args['toc'];
          final SearchModel? search = args['search'];

          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => EpubViewerCubit(),
              child: EpubViewerScreen(
                catModel: cat,
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