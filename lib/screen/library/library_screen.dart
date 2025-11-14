import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:masaha/screen/mobile_apps/mobile_apps_widget.dart';
import '../../model/book_model.dart';
import '../../util/epub_helper.dart';
import '../../widget/custom_appbar.dart';
import 'cubit/library_cubit.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _hijriDate = '';

  @override
  void initState() {
    context.read<LibraryCubit>().fetchBooks();
    super.initState();
  }

  void _showSeriesBottomSheet(BuildContext context, List<Series> series) {
    if (Platform.isIOS) {
      // Use showCupertinoModalBottomSheet for iOS with full screen and blurred background
      showCupertinoModalBottomSheet(
        context: context,
        expand: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CupertinoPageScaffold(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'الأجزاء',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: series.length,
                        itemBuilder: (context, index) {
                          final item = series[index];
                          return CupertinoListTile(
                            title: Text(item.title ?? 'Unknown Title',
                                style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(item.description ?? '',
                                style: Theme.of(context).textTheme.bodySmall),
                            onTap: () {
                              Navigator.pop(context);
                              openEpub(
                                  context: context,
                                  book: Book(epub: item.epub));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      showMaterialModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        builder: (context) => SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Text(
                  'الأجزاء',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Expanded(
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
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        showSearchBar: false,
        title: _hijriDate,
        leftWidget: IconButton(
          icon: Icon(
              Platform.isIOS ? CupertinoIcons.chat_bubble : Icons.chat_rounded),
          onPressed: _openChatScreen,
        ),
        rightWidget: IconButton(
          icon: Icon(Platform.isIOS
              ? CupertinoIcons.settings
              : Icons.settings_rounded),
          onPressed: _openStyleScreen,
        ),
      ),
      body: BlocConsumer<LibraryCubit, LibraryState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (books, hijriDate) {
              if (_hijriDate != hijriDate) {
                setState(() {
                  _hijriDate = hijriDate;
                });
              }
            },
            orElse: () {},
          );
        },
        builder: (context, state) => state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (books, hijriDate) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: books.length + 1,
              separatorBuilder: (context, index) {
                // Add spacing after mobile apps section
                if (index == books.length) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(height: 12.0);
              },
              itemBuilder: (context, index) {
                // Add MobileAppsWidget as the last item
                if (index == books.length) {
                  return MobileAppsWidget();
                }

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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      book.author ?? 'Unknown Author',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (book.description != null &&
                                        book.description!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        book.description!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
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
          error: (message) => Center(child: Text(message)),
        ),
      ),
    );
  }

  void _openChatScreen() {
    Navigator.pushNamed(context, '/chat');
  }

  void _openStyleScreen() {
    Navigator.pushNamed(context, '/colorPicker');
  }
}
