import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../../model/search_model.dart';

class SearchNavigationButtons extends StatelessWidget {
  final List<SearchModel> searchResults;
  final int currentSearchIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onShowResults;

  const SearchNavigationButtons({
    super.key,
    required this.searchResults,
    required this.currentSearchIndex,
    this.onPrevious,
    this.onNext,
    this.onShowResults,
  });

  @override
  Widget build(BuildContext context) {
    if (searchResults.isEmpty) return const SizedBox.shrink();

    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "prevSearch",
            mini: true,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            child: Icon(
              isIOS ? CupertinoIcons.arrow_up : Icons.arrow_upward,
              color: Theme.of(context).colorScheme.surface,
            ),
            onPressed: onPrevious,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onShowResults,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${searchResults.length}/${currentSearchIndex + 1}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.surface),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "nextSearch",
            mini: true,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            child: Icon(
              isIOS ? CupertinoIcons.arrow_down : Icons.arrow_downward,
              color: Theme.of(context).colorScheme.surface,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

