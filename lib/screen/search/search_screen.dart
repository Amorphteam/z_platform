import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/screen/search/widget/book_selection_sheet_widget.dart';
import 'package:zahra/screen/search/widget/search_results_widget.dart';
import 'package:zahra/widget/search_bar_widget.dart';

import '../../model/book_model.dart';
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

  @override
  void initState() {
    context.read<SearchCubit>().fetchBooksList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.primary,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  openBookSelectionSheet(allBooks);
                  context.read<SearchCubit>().resetState();
                },
                icon: const Icon(Icons.tune_rounded),
                color: Theme.of(context).colorScheme.secondary,
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(' $_selectedBooksCount کتاب ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
          Expanded(
            child: SearchBarWiget(
              onClicked: (query) async {
                await context.read<SearchCubit>().storeEpubBooks(_globalSelectedBooks);
                await context.read<SearchCubit>().search(query);
              },
            ),
          ),
        ],
      ),
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
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onSecondary,
              )),
          loaded: (searchResults) =>
              SearchResultsWidget(searchResults: searchResults),
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
                _selectedBooksCount = _globalSelectedBooks.entries.where((entry) => entry.value && entry.key.length > 1).length;
              }

            });
            return const SizedBox.shrink(); // Use this to return an empty widget
          },
          error: (error) => Center(child: Text('Error: $error')),
        ),
      ),
    ),
  );

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
        _selectedBooksCount = selectedBooks.entries.where((entry) => entry.value && entry.key.length > 1).length;
      });
      print('Selected books in SearchScreen: ${selectedBooks.keys.where((key) => selectedBooks[key] == true).join(", ")}');
    }
  }
}
