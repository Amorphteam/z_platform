import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:masaha/screen/bookmark/widgets/history_list_widget.dart';
import '../../widget/custom_appbar.dart';
import 'cubit/bookmark_cubit.dart';
import 'cubit/bookmark_state.dart';
import 'widgets/reference_list_widget.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  String _selectedSegment = 'Bookmark';
  int _selectedIndex = 0; // For CNSegmentedControl


  @override
  void initState() {
    super.initState();
    _loadBookmarksOrHistory(); // Load initial data
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:  CustomAppBar(
      backgroundImage: 'assets/image/back_tazhib_light.jpg',
      showSearchBar: false,
      title: "منصة مساحة",
      leftIcon: Icons.delete, // Example: Search icon
      onLeftTap: _clearAll,
    ),
    body: Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Platform.isIOS
                ? CNSegmentedControl(
                    labels: const ['الإشارات', 'السجل'],
                    selectedIndex: _selectedIndex,
                    onValueChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                        _selectedSegment = index == 0 ? 'Bookmark' : 'History';
                        _loadBookmarksOrHistory();
                      });
                    },
                  )
                : SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'Bookmark',
                        label: const Text('الإشارات'),
                        icon: const Icon(Icons.bookmark),
                      ),
                      ButtonSegment(
                        value: 'History',
                        label: const Text('السجل'),
                        icon: const Icon(Icons.history),
                      ),
                    ],
                    selected: {_selectedSegment},
                    showSelectedIcon: false,
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedSegment = newSelection.first;
                        _selectedIndex = _selectedSegment == 'Bookmark' ? 0 : 1;
                        _loadBookmarksOrHistory();
                      });
                    },
                  ),
          ),
          Expanded(
            child: BlocBuilder<BookmarkCubit, BookmarkState>(
              builder: (context, state) {
                return _selectedSegment == 'Bookmark'
                    ? _buildBookmarkBody(state)
                    : _buildHistoryBody(state);
              },
            ),
          ),
        ],
      ),
    ),
  );

  void _loadBookmarksOrHistory() {
    if (_selectedSegment == 'Bookmark') {
      BlocProvider.of<BookmarkCubit>(context).loadAllBookmarks();
    } else {
      BlocProvider.of<BookmarkCubit>(context).loadAllHistory();
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد أنك تريد حذف جميع البيانات؟'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text('إلغاء'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  if (_selectedSegment == 'Bookmark') {
                    await BlocProvider.of<BookmarkCubit>(context).clearAllBookmarks();
                  } else {
                    await BlocProvider.of<BookmarkCubit>(context).clearAllHistory();
                  }
                  // Force reload the current view
                  _loadBookmarksOrHistory();
                },
                child: Text('حذف')),
            ],
          ),
        );
      },
    );
  }


  Widget _buildBookmarkBody(BookmarkState state) {
    return state.when(
      initial: () => const Center(child: Text('Initializing...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      bookmarksLoaded: (bookmarks) {
        if (bookmarks.isEmpty) {
          return _buildEmptyMessage(
            title: 'قائمة الإشارات المرجعية فارغة',
            subtitle: 'يمكنك إضافة إشارات مرجعية من الكتب التي تقرأها.',
          );
        }
        return ReferenceListWidget(
          referenceList: bookmarks,
          onRefreshBookmarks: _loadBookmarksOrHistory,
        );
      },
      historyLoaded: (_) => Container(), // Not applicable here
      bookmarkTapped: (_) => Container(), // Not applicable here
      historyTapped: (_) => Container(), // Not applicable here
      error: (message) => Center(child: Text(message)),
    );
  }

  Widget _buildHistoryBody(BookmarkState state) {
    return state.when(
      initial: () => const Center(child: Text('Initializing...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      historyLoaded: (history) {
        if (history.isEmpty) {
          return _buildEmptyMessage(
            title: 'قائمة السجل فارغة',
            subtitle: 'يمكنك مراجعة السجل هنا.',
          );
        }
        return HistoryListWidget(
          historyList: history,
          onHistoryBookmarks: _loadBookmarksOrHistory,
        );
      },
      bookmarksLoaded: (_) => Container(), // Not applicable here
      bookmarkTapped: (_) => Container(), // Not applicable here
      historyTapped: (_) => Container(), // Not applicable here
      error: (message) => Center(child: Text(message)),
    );
  }

  Widget _buildEmptyMessage({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 120),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
