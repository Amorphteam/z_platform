import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/services.dart';

import '../../../model/search_model.dart';
import '../../../util/epub_helper.dart';
import '../../../util/search_helper.dart';

// Assuming you have a StatefulWidget for managing expand/collapse state
class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({
    super.key, 
    required this.searchResults,
    required this.searchQuery,
  });
  final List<SearchModel> searchResults;
  final String searchQuery;

  @override
  _SearchResultsWidgetState createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  final Map<String, List<SearchModel>> _expandedResults = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, int> _totalResultsCount = {};
  final Map<String, int> _lastResultIndex = {}; // Track the last result index for each book
  final Map<String, bool> _isExpanded = {}; // Track which books are expanded

  Future<void> loadMoreResults(String bookTitle) async {
    if (bookTitle == null) return;

    setState(() {
      _loadingStates[bookTitle] = true;
    });

    try {
      // Check if this is the first time loading more results for this book
      final isFirstLoad = _lastResultIndex[bookTitle] == null;
      
      // If it's the first load, reset everything
      if (isFirstLoad) {
        setState(() {
          _expandedResults[bookTitle] = [];
          _lastResultIndex[bookTitle] = 0;
          _totalResultsCount[bookTitle] = 0;
        });

      }


      // Get the last result index for this book
      final lastIndex = _lastResultIndex[bookTitle] ?? 0;
      
      // Fetch next batch of results
      final newResults = await _fetchAllResultsForBook(bookTitle, lastIndex);
      
      if (newResults.isNotEmpty) {
        setState(() {
          if (_expandedResults[bookTitle] == null) {
            _expandedResults[bookTitle] = [];
          }

          // Combine all results: initial + expanded + new
          final allResults = [ ..._expandedResults[bookTitle]!, ...newResults];
          
          // Remove duplicates based on pageIndex
          final uniqueResults = <SearchModel>[];
          final seenPageNumbers = <int>{};
          
          for (final result in allResults) {
            if (!seenPageNumbers.contains(result.pageIndex)) {
              seenPageNumbers.add(result.pageIndex);
              uniqueResults.add(result);
            }
          }
          
          // Sort all results numerically
          uniqueResults.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
          
          // Update expanded results with the complete sorted list
          _expandedResults[bookTitle] = uniqueResults;
          
          _loadingStates[bookTitle] = false;
          _lastResultIndex[bookTitle] = lastIndex + newResults.length;
          
          // Update total results count
          _totalResultsCount[bookTitle] = uniqueResults.length;
        });
      } else {
        setState(() {
          _loadingStates[bookTitle] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحميل جميع النتائج'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loadingStates[bookTitle] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل المزيد من النتائج: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<SearchModel>> _fetchAllResultsForBook(String bookTitle, int startIndex) async {
    try {
      // Find the book path from the existing results
      final bookResult = widget.searchResults.firstWhere(
        (result) => result.bookTitle == bookTitle,
        orElse: () => throw Exception('Book not found'),
      );

      // Load the book
      final epubData = await rootBundle.load('assets/epub/${bookResult.bookAddress}');
      final epubBook = await EpubReader.readBook(epubData.buffer.asUint8List());

      // Extract HTML content
      final List<HtmlFileInfo> spine = await extractHtmlContentWithEmbeddedImages(epubBook);
      
      // Extract spine items from EPUB
      final spineItems = epubBook.Schema?.Package?.Spine?.Items;
      final List<String> idRefs = [];

      if (spineItems != null) {
        for (final item in spineItems) {
          if (item.IdRef != null) {
            idRefs.add(item.IdRef!);
          }
        }
      }

      // Reorder HTML files based on spine
      final epubNewContent = reorderHtmlFilesBasedOnSpine(spine, idRefs);
      final spineHtmlContent = epubNewContent.map((info) => info.modifiedHtmlContent).toList();

      // Get all existing results for this book
      final existingResults = [
        ...widget.searchResults.where((r) => r.bookTitle == bookTitle),
        ...(_expandedResults[bookTitle] ?? [])
      ];

      // Create a set of unique page numbers for existing results
      final existingPageNumbers = <int>{};
      for (final result in existingResults) {
        existingPageNumbers.add(result.pageIndex);
      }

      // Perform a new search in this book
      final allResults = await SearchHelper().searchHtmlContents(
        spineHtmlContent,
        widget.searchQuery,
        bookResult.bookTitle,
        bookResult.bookAddress,
        null, // Get all results
      );

      // Filter out duplicates based on page number only
      final uniqueResults = <SearchModel>[];
      final seenPageNumbers = <int>{};
      
      for (final result in allResults) {
        // Skip if we've seen this page number before
        if (!existingPageNumbers.contains(result.pageIndex) && !seenPageNumbers.contains(result.pageIndex)) {
          seenPageNumbers.add(result.pageIndex);
          uniqueResults.add(result);
        }
      }

      // Sort results by page index
      uniqueResults.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));

      // Get the next 10 results starting from startIndex
      final nextResults = uniqueResults.skip(startIndex).take(10).toList();
      
      return nextResults;
    } catch (e) {
      print('Error searching book: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
    children: [
      // Padding(
      //   padding: const EdgeInsets.only(right: 16.0, left: 16, top: 8, bottom: 8),
      //   child: Align(
      //     alignment: Alignment.centerLeft,
      //     child: Text('كل النتائج: ${widget.searchResults.length}',
      //       style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),),
      //   ),
      // ),
      Expanded(
        child: ListView.builder(
          itemCount: widget.searchResults.length,
          itemBuilder: (context, index) {
            final currentBookTitle = widget.searchResults[index].bookTitle;
            final isFirstResultOfBook = index == 0 || widget.searchResults[index].bookTitle != widget.searchResults[index - 1].bookTitle;
            final isLastResultOfBook = index == widget.searchResults.length - 1 || widget.searchResults[index].bookTitle != widget.searchResults[index + 1].bookTitle;
            final expandedResults = _expandedResults[currentBookTitle] ?? [];
            final isLoading = _loadingStates[currentBookTitle] ?? false;
            final initialResultsCount = widget.searchResults.where((result) => result.bookTitle == currentBookTitle).length;
            final totalResultsCount = _totalResultsCount[currentBookTitle] ?? initialResultsCount;
            final isExpanded = _isExpanded[currentBookTitle] ?? false;

            if (isFirstResultOfBook) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded[currentBookTitle] = !isExpanded;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isExpanded ? Icons.expand_less : Icons.expand_more,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isExpanded[currentBookTitle!] = !isExpanded;
                                      });
                                    },
                                  ),
                                  // Text(
                                  //   '$totalResultsCount',
                                  //   style: Theme.of(context).textTheme.titleSmall,
                                  // ),
                                ],
                              ),
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.right,
                                  currentBookTitle!,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isExpanded) ...[
                    ...widget.searchResults
                        .where((result) => result.bookTitle == currentBookTitle)
                        .map((result) => _buildResultList(result))
                        .expand((x) => x),
                    if (expandedResults.isNotEmpty) ...[
                      ...expandedResults.map((result) => _buildResultList(result)).expand((x) => x),
                    ],
                    if (isLastResultOfBook) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Tooltip(
                                            message: 'تحميل المزيد',
                                            child: IconButton(
                                              icon: const Icon(Icons.sync),
                                              onPressed: () => loadMoreResults(currentBookTitle!),
                                            ),
                                          ),
                                    Text(
                                      '($totalResultsCount)',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                                Text(
                                  'المزيد من النتائج',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              );
            } else if (isExpanded) {
              // Show all results for the current book only if expanded
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isLastResultOfBook) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Tooltip(
                                        message: 'تحميل المزيد',
                                        child: GestureDetector(
                                          onTap: () => loadMoreResults(currentBookTitle!),
                                          child: Row(
                                            children: [

                                             Padding(
                                               padding: const EdgeInsets.all(8.0),
                                               child: Icon(Icons.sync, color: Theme.of(context).colorScheme.secondary),
                                             ),

                                              Text(
                                                'المزيد من النتائج',
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                // Text(
                                //   ' ($totalResultsCount)    ',
                                //   style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                // ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            } else {
              return const SizedBox.shrink(); // Hide results when collapsed
            }
          },
        ),
      ),
    ],
  );
  }

  List<Widget> _buildResultList(SearchModel result) {
    return [
      ListTile(
        title: GestureDetector(
          onTap: () {
            openEpub(context: context, search: result);
          },
          child: Row(
            children: [
              Text(
                '${result.pageIndex}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: Html(
                  data: result.spanna ?? '',
                  style: {
                    'html': Style(
                      fontSize: FontSize.medium,
                      lineHeight: LineHeight(1.2),
                      textAlign: TextAlign.right,
                    ),
                    'mark': Style(
                      backgroundColor: Colors.yellow,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
        child: Divider(
          thickness: 0.3,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ];
  }
}


