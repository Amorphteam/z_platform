import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/model/item_model.dart';
import 'package:zahra/screen/toc_with_number/cubit/toc_with_number_cubit.dart';
import 'package:zahra/util/navigation_helper.dart';
import 'package:zahra/widget/custom_appbar.dart';

import '../../model/toc_item.dart';
import 'cubit/toc_with_number_state.dart';

class TocWithNumberScreen extends StatefulWidget {
  TocWithNumberScreen({
    super.key,
    this.id,
    this.title,
    required this.jsonPath
  });

  int? id;
  String? title;
  String jsonPath;
  @override
  State<TocWithNumberScreen> createState() => _TocWithNumberScreenState();
}

class _TocWithNumberScreenState extends State<TocWithNumberScreen> {
  List<TocItem> _allItems = [];
  List<TocItem> _filteredItems = [];
  String searchedWord = '';

  @override
  void initState() {
    super.initState();
    context.read<TocWithNumberCubit>().fetchItems(jsonPath: widget.jsonPath);
  }

  void _filterItems(String query) {
    setState(() {
      searchedWord = query;
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems
            .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _toArabicNumber(String number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    for (int i = 0; i < english.length; i++) {
      number = number.replaceAll(english[i], arabic[i]);
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (widget.title != null && widget.title!.contains('\n')) {
      widget.title = widget.title!.replaceAll('\n', ' ');
    }
    return Scaffold(
      appBar: CustomAppBar(
        backgroundImage: 'assets/image/back_tazhib_light.jpg',
        title: widget.title ?? '',
        showSearchBar: true,
        onSearch: _filterItems,
      ),
      body: isLandscape
          ? Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 48.0, left: 48, bottom: 0),
              child: BlocBuilder<TocWithNumberCubit, TocWithNumberState>(
                builder: (context, state) => state.when(
                  initial: () => const Center(
                      child: Text('Tap to start fetching...')),
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  loaded: (items) {
                    if (_allItems.isEmpty) {
                      _allItems = List.from(items);
                      _filteredItems = List.from(items);
                    }
                    return _buildTocTree(_filteredItems, context);
                  },
                  error: (message) =>
                      Center(child: SelectionArea(child: Text(message))),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.only(right: 48.0, left: 48, bottom: 40),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/image/landimage_dark.jpg'
                          : 'assets/image/landimage_light.jpg',
                    ),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : Stack(
        children: [
          !isLandscape ? Container(
          ):
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/image/main_dark.jpg'
                        : 'assets/image/main_light.jpg',
                  ),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          BlocBuilder<TocWithNumberCubit, TocWithNumberState>(
            builder: (context, state) => state.when(
              initial: () =>
              const Center(child: Text('Tap to start fetching...')),
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              loaded: (items) {
                if (_allItems.isEmpty) {
                  _allItems = List.from(items);
                  _filteredItems = List.from(items);
                }
                return _buildTocTree(_filteredItems, context);
              },
              error: (message) =>
                  Center(child: SelectionArea(child: Text(message))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTocTree(List<TocItem> items, BuildContext context) {
    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) => _buildCardView(_filteredItems[index], context),
    );
  }

  Widget _buildTocItem(TocItem item, BuildContext context, {bool isNestedParent = false}) {
    if (item.childs == null || item.childs!.isEmpty) {
      return _buildCardView(item, context);
    } else {
      return Container(
        margin: EdgeInsets.only(
          right: 16.0,
          left: isNestedParent ? 0.0 : 16.0,
          bottom: 6,
        ),
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0,
          child: ExpansionTile(
            title: _buildCardTitle(item, context),
            iconColor: const Color(0xFFCFA355),
            collapsedIconColor: const Color(0xFFCFA355),
            children: item.childs!
                .where((child) => child.parentId == item.id) // Ensure only direct children are added
                .map((child) => _buildTocItem(child, context, isNestedParent: true))
                .toList(),
          ),
        ),
      );
    }
  }

  Widget _buildCardView(TocItem item, BuildContext context) => Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
    child: GestureDetector(
      onTap: () => _navigateTo(context, item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 0,
                child: SizedBox(
                  height: 60,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textSpan = TextSpan(
                        text: item.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                      )..layout(maxWidth: constraints.maxWidth - 16); // Account for padding

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: textPainter.didExceedMaxLines 
                              ? Alignment.topRight 
                              : Alignment.centerRight,
                          child: Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            item.title,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Container(
              height: 60,
              width: 60,
              child: Center(
                child: Text(
                  _toArabicNumber(item.key?.split('_').last ?? ''),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCardTitle(TocItem item, BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              item.title,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _toArabicNumber(item.key?.split('_').last ?? ''),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFCFA355),
            ),
          ),
        ),
      ],
    ),
  );

  void _navigateTo(BuildContext context, TocItem item) {
    final String bookPath = item.key?.split('_').first??'';
    final String sectionName = item.key?.split('_').last??'0';
    final int sectionNumber = int.parse(sectionName);
    final String sectionNumberString = (sectionNumber - 1).toString();
    NavigationHelper.openBook(context, bookPath, sectionNumberString);
  }
} 