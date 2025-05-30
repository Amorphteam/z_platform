import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/model/history_model.dart';
import '../../../util/epub_helper.dart';
import '../cubit/bookmark_cubit.dart';

class HistoryListWidget extends StatelessWidget {
  const HistoryListWidget(
      {super.key,
        required this.historyList,
        required this.onHistoryBookmarks});

  final List<HistoryModel> historyList;
  final Function onHistoryBookmarks;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<HistoryModel>> groupedHistorty = {};
    for (final history in historyList) {
      groupedHistorty
          .putIfAbsent(history.bookName, () => [])
          .add(history);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
      itemCount: groupedHistorty.length,
      itemBuilder: (context, bookIndex) {
        final bookName = groupedHistorty.keys.elementAt(bookIndex);
        final bookHistory = groupedHistorty[bookName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 0,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    textAlign: TextAlign.right,
                    bookName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
            ...bookHistory.map((history) {
              final String stringValue = history.navIndex;
              final double doubleValue = double.parse(stringValue);
              final int intValue = doubleValue.toInt();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await openEpub(context: context, history: history);
                        onHistoryBookmarks();
                      },
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<BookmarkCubit>(context)
                                  .deleteHistory(history.id!);
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.close_rounded,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                history.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                ,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Text(
                            (intValue + 1).toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall?.copyWith(color: const Color(0xFFFFffff))
                            ,
                          ),
                        ],
                      ),
                    ),
                    if (bookHistory.indexOf(history) <
                        bookHistory.length - 1)
                      Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.4),
                        height: 0.5,
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
