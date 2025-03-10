import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../bookmark/bookmark_screen.dart';
import '../bookmark/cubit/bookmark_cubit.dart';
import '../library/cubit/library_cubit.dart';
import '../library/library_screen.dart';
import '../recommanded_toc/cubit/recommanded_toc_cubit.dart';
import '../recommanded_toc/recommanded_toc_screen.dart';
import '../search/cubit/search_cubit.dart';
import '../search/search_screen.dart';
import '../toc/cubit/toc_cubit.dart';
import '../toc/toc_screen.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  _HostScreenState createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.primary,
          selectedItemColor: Theme.of(context).colorScheme.secondaryContainer,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.check_mark_circled),
              label: 'اخترنا لكم',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _currentIndex == 1 ? 'assets/icon/filled_toc.svg' : 'assets/icon/outline_toc.svg',
                width: 24,
                height: 24,
              ),
              label: 'الفهرست',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2 ? CupertinoIcons.book_solid : CupertinoIcons.book),
              label: 'الكتب',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? CupertinoIcons.search_circle_fill : CupertinoIcons.search),
              label: 'البحث',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 4 ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark),
              label: 'الإشارات',
            ),
          ],
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
      case 3:
        return 'البحث';
      case 4:
        return 'العلامات';
      default:
        return '';
    }
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return BlocProvider(
          create: (context) => RecommandedTocCubit(),
          child: RecommandedTocScreen(),
        );
      case 1:
        return BlocProvider(
          create: (context) => TocCubit(),
          child: TocScreen(),
        );
      case 2:
        return BlocProvider(
          create: (context) => LibraryCubit(),
          child: const LibraryScreen(),
        );
      case 3:
        return BlocProvider(
          create: (context) => SearchCubit(),
          child: const SearchScreen(),
        );
      case 4:
        return BlocProvider(
          create: (context) => BookmarkCubit(),
          child: const BookmarkScreen(),
        );
      default:
        return Container();
    }
  }

}
