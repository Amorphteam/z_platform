import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith/screen/search/widget/book_selection_sheet_widget.dart';
import 'package:hadith/screen/search/widget/search_results_widget.dart';

import '../../model/book_model.dart';
import '../../widget/custom_appbar.dart';
import '../../widget/search_bar_widget.dart';
import 'cubit/search_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedBooksCount = 0; // To track the number of selected books
  Map<String, bool> _globalSelectedBooks = {}; // Tracks global selection state
  List<Book> allBooks = [];
  String _currentSearchQuery = ''; // Add this

  @override
  void initState() {
    context.read<SearchCubit>().fetchBooksList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: CustomAppBar(
          showSearchBar: true,
          title: "الحديث الشريف",
          leftWidget: buildLeftWidget(context),
          onLeftTap: () {
            openBookSelectionSheet(allBooks);
            context.read<SearchCubit>().resetState();
          },
          onSubmitted: (query) async {
            _currentSearchQuery = query; // Store the search query
            await context
                .read<SearchCubit>()
                .storeEpubBooks(_globalSelectedBooks);
            await context.read<SearchCubit>().search(query, maxResultsPerBook: 10);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) => state.when(
              initial: () => Center(
                  child: Text('ابدأ البحث',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary))),
              loading: () => Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('جاری البحث'),
                  ),
                ],
              )),
              loaded: (searchResults) =>
                  SearchResultsWidget(
                    searchResults: searchResults,
                    searchQuery: _currentSearchQuery,
                  ),
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
                  }
                });
                return const SizedBox
                    .shrink(); // Use this to return an empty widget
              },
              error: (error) => Center(child: Text('Error: $error')),
            ),
          ),
        ),
      );

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
}
