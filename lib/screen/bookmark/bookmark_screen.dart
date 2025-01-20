import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/bookmark_cubit.dart';
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
    _loadAllBookmarks();
    _loadAllHistory();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 58.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Bookmark',
                  label: Text('العلامات'),
                  icon: Icon(Icons.bookmark),
                ),
                ButtonSegment(
                  value: 'History',
                  label: Text('السجل'),
                  icon: Icon(Icons.history),
                ),
              ],
              selected: {_selectedSegment},
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).colorScheme.primary;
                  } else {
                    return Colors.white70;
                  }
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.onSecondary;
                  } else {
                    return Theme.of(context).colorScheme.primary;
                  }
                }),
              ),
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedSegment = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedSegment == 'Bookmark'
                ? BlocBuilder<BookmarkCubit, BookmarkState>(
              builder: (context, state) => _buildBookmarkBody(state),
            )
                : BlocBuilder<BookmarkCubit, BookmarkState>(
              builder: (context, state) => _buildHistoryBody(state),
            ),
          ),
        ],
      ),
    );

  void _loadAllBookmarks() {
    BlocProvider.of<BookmarkCubit>(context).loadAllBookmarks();
  }

  void _loadAllHistory() {
    BlocProvider.of<BookmarkCubit>(context).loadAllHistory(); // Implement this in your cubit
  }

  Widget _buildBookmarkBody(BookmarkState state) {
    if (state is BookmarkLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is AllBookmarksLoadedState) {
      if (state.bookmarks.isEmpty) {
        return _buildEmptyMessage(
          title: 'قائمة الإشارات المرجعية فارغة',
          subtitle: 'يمكنك إضافة إشارات مرجعية من الكتب التي تقرأها.',
        );
      }
      return _buildList(state);
    } else if (state is BookmarkErrorState) {
      return Center(
        child: Text(state.error.toString()),
      );
    } else {
      return Container();
    }
  }

  Widget _buildHistoryBody(BookmarkState state) {
    if (state is BookmarkLoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is AllHistoryLoadedState) {
      if (state.history.isEmpty) {
        return _buildEmptyMessage(
          title: 'قائمة السجل فارغة',
          subtitle: 'يمكنك مراجعة السجل هنا.',
        );
      }
      return _buildHistoryList(state);
    } else if (state is BookmarkErrorState) {
      return Center(
        child: Text(state.error.toString()),
      );
    } else {
      return Container();
    }
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
                textAlign: TextAlign.center,
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFFffffff)),
              ),
              const SizedBox(height: 8),
              Text(
                textAlign: TextAlign.center,
                subtitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFFffffff)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(AllBookmarksLoadedState state) => ReferenceListWidget(
    referenceList: state.bookmarks,
    onRefreshBookmarks: () {
      _loadAllBookmarks();
    },
  );

  Widget _buildHistoryList(AllHistoryLoadedState state) => ReferenceListWidget(
    referenceList: state.history,
    onRefreshBookmarks: () {
      _loadAllHistory();
    },
  );
}
