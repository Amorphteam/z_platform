import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masaha/screen/mobile_apps/mobile_apps_widget.dart';
import '../../model/book_model.dart';
import '../../util/epub_helper.dart';
import 'cubit/library_cubit.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    context.read<LibraryCubit>().fetchBooks();
    super.initState();
  }

  void _showSeriesBottomSheet(BuildContext context, List<Series> series) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: series.length,
          itemBuilder: (context, index) {
            final item = series[index];
            return ListTile(
              title: Text(item.title ?? 'Unknown Title',
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(item.description ?? '',
                  style: Theme.of(context).textTheme.bodySmall),
              onTap: () {
                Navigator.pop(context);
                openEpub(context: context, book: Book(epub: item.epub));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) => state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (books, hijriDate) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(hijriDate, style: Theme.of(context).textTheme.titleLarge),
                Expanded(
                  child: ListView.separated(
                    itemCount: books.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: () {
                          if (book.series != null && book.series!.isNotEmpty) {
                            _showSeriesBottomSheet(context, book.series!);
                          } else {
                            final bookPath = '${book.epub}.epub';
                            openEpub(context: context, book: Book(epub: bookPath));
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Text and description on the left
                                Expanded(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 18.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title ?? 'Unknown Title',
                                            style: Theme.of(context).textTheme.titleLarge,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            book.author ?? 'Unknown Author',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (book.description != null && book.description!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              book.description!,
                                              style: Theme.of(context).textTheme.bodySmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Image on the right
                                Container(
                                  width: 140,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: book.image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            book.image!,
                                            fit: BoxFit.cover,
                                            width: 140,
                                            height: 180,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.book,
                                            size: 40,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(

                  child: MobileAppsWidget(),
                )
              ],
            ),
          ),
          error: (message) => Center(child: Text(message)),
        ),
      ),
    );
  }
}
