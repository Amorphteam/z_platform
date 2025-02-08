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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.6,
                  ),
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
                      child: Card(
                        color: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: book.image != null
                                  ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8.0),
                                ),
                                child: Image.asset(
                                  'assets/image/${book.image!}',
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                ),
                              )
                                  : Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.book,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title ?? 'Unknown Title',
                                    style: Theme.of(context).textTheme.titleLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book.author ?? 'Unknown Author',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
