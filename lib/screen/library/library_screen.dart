import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
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
            ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: BlocBuilder<LibraryCubit, LibraryState>(
            builder: (context, state) => state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (books) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: books.length,
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
                      child: Column(
                        children: [
                          Card(
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0,), // Spacing between items
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Book Image (Right Side)
                                SizedBox(
                                  width: 140,
                                  height: 190,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: book.image != null
                                        ? Image.asset(
                                      'assets/image/${book.image!}',
                                      fit: BoxFit.cover,
                                      width: 100, // Adjusted width
                                      height: 120, // Adjusted height
                                    )
                                        : Container(
                                      width: 100,
                                      height: 120,
                                      color: Colors.grey,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.book,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10), // Space between image and text
                                // Text Content (Left Side)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          book.title ?? 'Unknown Title',
                                          style: Theme.of(context).textTheme.titleLarge,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'المؤلف: ${book.author}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider()
                        ],
                      ),
                    );
                  },
                ),
              ),
              error: (message) => Center(child: Text(message)),
            ),
          ),
        ),
      ),
    );
  }
}
