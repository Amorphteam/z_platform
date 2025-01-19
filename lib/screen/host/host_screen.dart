import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/screen/bookmark/bookmark_screen.dart';
import 'package:zahra/screen/bookmark/cubit/bookmark_cubit.dart';
import 'package:zahra/screen/search/cubit/search_cubit.dart';
import 'package:zahra/screen/search/search_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HostScreen(),
      );
}

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  _HostScreenState createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Container(color: Colors.red),
    Container(color: Colors.red),
    Container(color: Colors.red),
    const SearchScreen(),
    const BookmarkScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: NavigationBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.recommend_rounded),
                label: 'اخترنا لكم',
              ),
              NavigationDestination(
                icon: Icon(Icons.toc_rounded),
                label: 'الفهرست',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books_rounded),
                label: 'الكتب',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'البحث ',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_rounded),
                label: 'العلامات',
              ),
            ],
          ),
        ),
      );
}
