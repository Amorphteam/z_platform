import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


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

  final List<Widget> _screens = [
    BlocProvider(
      create: (context) => RecommandedTocCubit(),
      child:  RecommandedTocScreen(title: 'اخترنا لکم',),
    ),
    BlocProvider(
      create: (context) => TocCubit(),
      child:  TocScreen(title: 'الفهرست',),
    ),
    BlocProvider(
      create: (context) => LibraryCubit(),
      child: const LibraryScreen(),
    ),
    BlocProvider(
      create: (context) => SearchCubit(),
      child: const SearchScreen(),
    ),
    BlocProvider(
      create: (context) => BookmarkCubit(),
      child: const BookmarkScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.check_mark_circled), label: 'اخترنا لكم'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_number_rtl), label: 'الفهرست'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: 'الكتب'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'البحث'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.bookmark), label: 'العلامات'),
          ],
        ),
      ),
    );

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
}
