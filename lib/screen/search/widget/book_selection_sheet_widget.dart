import 'package:flutter/material.dart';

import '../../../model/book_model.dart';

class BookSelectionSheetWidget extends StatefulWidget {
  final ScrollController scrollController;
  final List<Book> books;
  final Map<String, bool> initialSelectedBooks;

  const BookSelectionSheetWidget({
    Key? key,
    required this.scrollController,
    required this.books,
    required this.initialSelectedBooks,
  }) : super(key: key);

  @override
  _BookSelectionSheetWidgetState createState() =>
      _BookSelectionSheetWidgetState();
}

class _BookSelectionSheetWidgetState extends State<BookSelectionSheetWidget> {
  late Map<String, bool> selectedBooks; // Tracks selected books and series
  int _selectedCount = 0; // Track selected book count

  String _getBookCountText(int count) {
    if (count == 1) {
      return 'سيكون البحث في كتاب واحد';
    } else if (count == 2) {
      return 'سيكون البحث في كتابين';
    } else if (count >= 3 && count <= 10) {
      return 'سيكون البحث في $_selectedCount كتب';
    } else if (count >= 11 && count <= 99) {
      return 'سيكون البحث في $_selectedCount كتاباً';
    } else if (count >= 100 && count <= 9999) {
      return 'سيكون البحث في $_selectedCount كتاب';
    } else {
      return 'سيكون البحث في $_selectedCount كتاب';
    }
  }

  @override
  void initState() {
    super.initState();
    selectedBooks = Map.from(widget.initialSelectedBooks); // Use initial selected state
    _updateSelectedCount(); // Initialize count
  }

  void _updateSelectedCount() {
    setState(() {
      _selectedCount = selectedBooks.entries
          .where((entry) => entry.value && entry.key.length > 1)
          .length;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "مجال البحث",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Check if all books are already selected
                    final allSelected = selectedBooks.values.every((value) => value);

                    // Toggle selection
                    selectedBooks.updateAll((key, value) => !allSelected);
                    _updateSelectedCount();
                  });
                },
                child: Text(
                  selectedBooks.values.every((value) => value)
                      ? "إلغاء الكل"
                      : "تحديد الكل",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: widget.books.length,
              itemBuilder: (context, index) {
                final book = widget.books[index];
                return _buildBookTile(book);
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    _getBookCountText(_selectedCount),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedBooks);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                child: const Text("موافق"),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildBookTile(Book book) {
    if (book.series == null || book.series!.isEmpty) {
      return ListTile(
        leading: Checkbox(
          activeColor: Theme.of(context).colorScheme.secondary,
          checkColor: Theme.of(context).colorScheme.surface,
          value: selectedBooks[book.epub],
          onChanged: (value) {
            setState(() {
              selectedBooks[book.epub] = value!;
              _updateSelectedCount();
            });
          },
        ),
        title: Text(book.title ?? "Untitled Book"),
      );
    } else {
      return ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              activeColor: Theme.of(context).colorScheme.secondary,
              checkColor: Theme.of(context).colorScheme.surface,
              value: selectedBooks[book.epub],
              onChanged: (value) {
                setState(() {
                  // Update the parent book's selection
                  selectedBooks[book.epub] = value!;

                  // Update all related series based on parent selection
                  for (var series in book.series ?? []) {
                    selectedBooks[series.epub] = value;
                  }
                  _updateSelectedCount();
                });
              },
            ),
            Text(book.title ?? "Untitled Book"),
          ],
        ),
        children: (book.series ?? [])
            .map(
              (series) => Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: Row(
              children: [
                Checkbox(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  checkColor: Theme.of(context).colorScheme.surface,
                  value: selectedBooks[series.epub],
                  onChanged: (value) {
                    setState(() {
                      selectedBooks[series.epub] = value!;

                      // Check if all series under this parent are selected
                      final allSelected = book.series!
                          .every((s) => selectedBooks[s.epub] == true);

                      // Update the parent book selection based on its series
                      selectedBooks[book.epub] = allSelected;
                      _updateSelectedCount();
                    });
                  },
                ),
                Text(series.title ?? "Untitled Series"),
              ],
            ),
          ),
        )
            .toList(),
      );
    }
  }
}