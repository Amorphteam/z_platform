import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masaha/screen/search/widget/book_selection_sheet_widget.dart';
import 'package:masaha/screen/search/widget/search_results_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/book_model.dart';
import '../../util/search_helper.dart';
import '../../widget/custom_appbar.dart';
import '../../widget/search_bar_widget.dart';
import 'cubit/search_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _recentSearchesPrefsKey = 'search_recent_terms';
  static const int _maxRecentSearches = 10;

  int _selectedBooksCount = 0; // To track the number of selected books
  Map<String, bool> _globalSelectedBooks = {}; // Tracks global selection state
  List<Book> allBooks = [];
  String _currentSearchQuery = ''; // Add this
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().fetchBooksList();
    _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          showSearchBar: true,
          title: "البحث العام",
          leftWidget: buildLeftWidget(context),
          recentSearches: _recentSearches,
          onRecentSelected: _onRecentSearchSelected,
          onRecentDelete: _onRecentSearchDeleted,
          onLeftTap: () {
            openBookSelectionSheet(allBooks);
            context.read<SearchCubit>().resetState();
          },
          onSubmitted: (query) async {
            _currentSearchQuery = query; // Store the search query
            await _upsertRecentSearch(query);
            await context.read<SearchCubit>().search(query, maxResultsPerBook: MAX_RESULTS_PER_BOOK);
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => state.when(
                initial: () => Center(
                    child: Text('ابدأ البحث',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface))),
                loading: () => Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
                loaded: (searchResults, isRunningSearch) {
                  if (searchResults.isEmpty && !isRunningSearch) {
                    final displayQuery =
                        _currentSearchQuery.isEmpty ? '...' : _currentSearchQuery;
                    return Center(
                      child: Text(
                        'لم يتم العثور على'
                            '\n "$displayQuery'
                            '"\n في مجال البحث المحدد',

                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (searchResults.isEmpty && isRunningSearch) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SearchResultsWidget(
                    searchResults: searchResults,
                    searchQuery: _currentSearchQuery,
                  );
                },
                loadedList: (books) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_globalSelectedBooks.isEmpty) {
                      for (var book in books) {
                        _globalSelectedBooks[book.epub] = true;
                        for (var series in book.series ?? []) {
                          _globalSelectedBooks[series.epub] = true;
                        }
                      }
                      allBooks = books;
                      setState(() {
                        _selectedBooksCount = _globalSelectedBooks.entries
                            .where((entry) => entry.value && entry.key.length > 1)
                            .length;
                      });
                      // Store EPUB files when books are first loaded
                      context.read<SearchCubit>().storeEpubBooks(_globalSelectedBooks);
                    }
                  });
                  return const SizedBox.shrink();
                },
                error: (error) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ),
      );

  Future<void> _onRecentSearchSelected(String term) async {
    await _upsertRecentSearch(term);
    setState(() {
      _currentSearchQuery = term;
    });

    await context.read<SearchCubit>().search(term, maxResultsPerBook: MAX_RESULTS_PER_BOOK);
  }

  void _onRecentSearchDeleted(String term) {
    _removeRecentSearch(term);
  }

  Widget buildLeftWidget(BuildContext context) {
    return IconButton(
      onPressed: () async {
        openBookSelectionSheet(allBooks);
        context.read<SearchCubit>().resetState();
      },
      icon: const Icon(Icons.tune_rounded),
    );
  }

  void openBookSelectionSheet(List<Book> books) async {
    final selectedBooks = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      isScrollControlled: true, // Enables resizing behavior
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.25,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return BookSelectionSheetWidget(
                scrollController: scrollController,
                books: books,
                initialSelectedBooks: _globalSelectedBooks,
              );
            },
          ),
        );
      },
    );

    if (selectedBooks != null) {
      setState(() {
        _globalSelectedBooks = selectedBooks;
        _selectedBooksCount = selectedBooks.entries
            .where((entry) => entry.value && entry.key.length > 1)
            .length;
      });
      print(
          'Selected books in SearchScreen: ${selectedBooks.keys.where((key) => selectedBooks[key] == true).join(", ")}');
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_recentSearchesPrefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      _recentSearches = stored.take(_maxRecentSearches).toList();
    });
  }

  Future<void> _upsertRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final updated = <String>[trimmed, ..._recentSearches.where((item) => item != trimmed)];
    final limited = updated.take(_maxRecentSearches).toList();

    setState(() {
      _recentSearches = limited;
    });

    await _saveRecentSearches(limited);
  }

  Future<void> _removeRecentSearch(String term) async {
    final updated = _recentSearches.where((item) => item != term).toList();
    setState(() {
      _recentSearches = updated;
    });
    await _saveRecentSearches(updated);
  }

  Future<void> _saveRecentSearches(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesPrefsKey, values);
  }
}
