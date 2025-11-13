import 'dart:io';
import 'package:flutter/foundation.dart';
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
  final TextEditingController _bookIdController = TextEditingController();

  @override
  void initState() {
    context.read<LibraryCubit>().fetchBooks();
    super.initState();
  }

  @override
  void dispose() {
    _bookIdController.dispose();
    super.dispose();
  }

  void _showBookIdDialog(BuildContext context) {
    _bookIdController.clear();
    
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('إدخال رقم الكتاب'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CupertinoTextField(
              controller: _bookIdController,
              placeholder: 'أدخل رقم الكتاب',
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              padding: const EdgeInsets.all(12.0),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('فتح'),
              onPressed: () {
                final bookIdText = _bookIdController.text.trim();
                if (bookIdText.isNotEmpty) {
                  final bookId = int.tryParse(bookIdText);
                  if (bookId != null && bookId > 0) {
                    Navigator.pop(context);
                    openEpub(context: context, onlineBookId: bookId);
                  } else {
                    // Show error
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('خطأ'),
                        content: const Text('يرجى إدخال رقم كتاب صحيح'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('حسناً'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إدخال رقم الكتاب'),
          content: TextField(
            controller: _bookIdController,
            decoration: const InputDecoration(
              hintText: 'أدخل رقم الكتاب',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final bookIdText = _bookIdController.text.trim();
                if (bookIdText.isNotEmpty) {
                  final bookId = int.tryParse(bookIdText);
                  if (bookId != null && bookId > 0) {
                    Navigator.pop(context);
                    openEpub(context: context, onlineBookId: bookId);
                  } else {
                    // Show error
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('خطأ'),
                        content: const Text('يرجى إدخال رقم كتاب صحيح'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('حسناً'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: const Text('فتح'),
            ),
          ],
        ),
      );
    }
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

  Widget _buildOnlineBookTestCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: theme.colorScheme.primaryContainer.withOpacity(0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          _showBookIdDialog(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.cloud_download_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تجربة الكتاب عبر الإنترنت',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'اضغط هنا لإدخال رقم الكتاب وقراءته مباشرة من الخادم.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Icon(
                Platform.isIOS ? CupertinoIcons.chevron_forward : Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        showSearchBar: false,
        title: _hijriDate,
        backgroundImage: 'assets/image/back_tazhib_light.jpg',
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
              itemCount: books.length + 1 + (kDebugMode ? 1 : 0),
              separatorBuilder: (context, index) {
                final hasOnlineTestTile = kDebugMode;
                final mobileAppsIndex = books.length + (hasOnlineTestTile ? 1 : 0);
                if (index == mobileAppsIndex) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(height: 12.0);
              },
              itemBuilder: (context, index) {
                final hasOnlineTestTile = kDebugMode;
                final mobileAppsIndex = books.length + (hasOnlineTestTile ? 1 : 0);

                if (hasOnlineTestTile && index == 0) {
                  return _buildOnlineBookTestCard(context);
                }

                // Add MobileAppsWidget as the last item
                if (index == mobileAppsIndex) {
                  return MobileAppsWidget();
                }

                final bookIndex = index - (hasOnlineTestTile ? 1 : 0);
                final book = books[bookIndex];
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
