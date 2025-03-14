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
  Future<void> loadMoreResults(String? bookTitle) async {
    if (bookTitle == null) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('نتائج البحث في $bookTitle'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: FutureBuilder<List<SearchModel>>(
                    future: _fetchAllResultsForBook(bookTitle),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('جاري تحميل النتائج...'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('حدث خطأ: ${snapshot.error}'),
                        );
                      }

                      final results = snapshot.data ?? [];
                      if (results.isEmpty) {
                        return const Center(
                          child: Text('لا توجد نتائج إضافية'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return Column(
                            children: [
                              ListTile(
                                title: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context); // Close dialog
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
                              Divider(
                                thickness: 0.3,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل المزيد من النتائج: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<SearchModel>> _fetchAllResultsForBook(String bookTitle) async {
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

      // Perform a new search in this book without limit using searchHtmlContents
      final results = await SearchHelper().searchHtmlContents(
        spineHtmlContent,
        widget.searchQuery,
        bookResult.bookTitle,
        bookResult.bookAddress,
        null, // null means no limit
      );

      return results;
    } catch (e) {
      print('Error searching book: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16, top: 8, bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('كل النتائج: ${widget.searchResults.length}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.secondary),),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: widget.searchResults.length,
          itemBuilder: (context, index) {
            // Separate results by book
            if (index == 0 || widget.searchResults[index].bookTitle != widget.searchResults[index - 1].bookTitle) {
              // Calculate count of results for the current book
              final currentBookResults = widget.searchResults.where((result) => result.bookTitle == widget.searchResults[index].bookTitle).toList();

              // Display a header for each book with result count
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      color: Theme.of(context).colorScheme.onPrimary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tooltip(
                              message: 'تحميل المزيد',
                              child: IconButton(
                                icon: const Icon(Icons.sync),
                                onPressed: () => loadMoreResults(widget.searchResults[index].bookTitle),
                              ),
                            ),
                            Text(
                              'load more',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Expanded(
                              child: Text(
                                textAlign: TextAlign.right,
                                '${widget.searchResults[index].bookTitle}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(

                    title: GestureDetector(
                      onTap: () {
                        openEpub(context: context, search: widget.searchResults[index]);
                      },
                      child: Row(
                        children: [
                          Text(
                            '${widget.searchResults[index].pageIndex}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Expanded(
                            child: Html(
                              data: widget.searchResults[index].spanna ?? '',
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
                ],
              );
            } else {
              // Display subsequent results for the same book
              return Column(
                children: [
                  ListTile(
                    title: GestureDetector(
                      onTap: () {
                        openEpub(context: context, search: widget.searchResults[index]);
                      },
                      child: Row(
                        children: [
                          Text(
                            '${widget.searchResults[index].pageIndex}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Expanded(
                            child: Html(
                              data: widget.searchResults[index].spanna ?? '',
                              style: {
                                'html': Style(
                                  fontSize: FontSize.large,
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
                ],
              );
            }
          },
        ),
      ),

    ],
  );
}


