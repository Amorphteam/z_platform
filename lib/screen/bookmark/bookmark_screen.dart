import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith/screen/bookmark/widgets/history_list_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _loadBookmarksOrHistory(); // Load initial data
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: Text(
              'مسح الكل',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'Bookmark',
                  label: const Text('العلامات'),
                  icon: _selectedSegment == 'Bookmark' ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark),
                ),
                ButtonSegment(
                  value: 'History',
                  label: const Text('السجل'),
                  icon: _selectedSegment == 'History' ? const Icon(Icons.history) : const Icon(Icons.history),
                ),
              ],
              selected: {_selectedSegment},
              showSelectedIcon: false,
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).colorScheme.secondary;
                  } else {
                    return Theme.of(context).colorScheme.outlineVariant;
                  }
                }),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).colorScheme.onSecondary;
                  } else {
                    return Theme.of(context).colorScheme.primary;
                  }
                }),
              ),
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedSegment = newSelection.first;
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
    if (_selectedSegment == 'Bookmark') {
      BlocProvider.of<BookmarkCubit>(context).clearAllBookmarks();
    } else {
      BlocProvider.of<BookmarkCubit>(context).clearAllHistory();
    }
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
