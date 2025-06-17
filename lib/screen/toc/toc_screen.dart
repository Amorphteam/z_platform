import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/model/item_model.dart';
import 'package:zahra/screen/toc/cubit/toc_cubit.dart';
import 'package:zahra/util/navigation_helper.dart';

import '../../model/toc_item.dart';
import '../../widget/custom_appbar.dart';

class TocScreen extends StatefulWidget {
  TocScreen({
    super.key,
    this.id,
    this.title,
  });

  int? id;
  String? title;

  @override
  State<TocScreen> createState() => _TocScreenState();
}

class _TocScreenState extends State<TocScreen> {
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(0.0);
  List<TocItem> _allItems = [];
  List<TocItem> _filteredItems = [];
  String searchedWord = '';

  @override
  void initState() {
    super.initState();
    context.read<TocCubit>().fetchItems();
  }

  void _filterItems(String query) {
    setState(() {
      searchedWord = query;
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) =>
                item.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
        title: widget.title ?? 'الفهرست الموضوعي',
        showSearchBar: true,
        onSearch: _filterItems,
        leftWidget: SizedBox(), // This will hide the back button
    
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _opacityNotifier,
                    builder: (_, __) => Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(_opacityNotifier.value),
                    ),
                  ),
                  NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        final pixels = scrollNotification.metrics.pixels;
                        _opacityNotifier.value =
                            (pixels / 560).clamp(0.0, 1.0);
                      }
                      return true;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0, left: 48, bottom: 0),
    
                      child: BlocBuilder<TocCubit, TocState>(
                        builder: (context, state) => state.when(
                          initial: () => const Center(
                              child: Text('Tap to start fetching...')),
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          loaded: (items) {
                            _allItems = items;
                            _filteredItems = searchedWord.isEmpty ? items : _filteredItems;
                            return _buildTocTree(_filteredItems, context);
                          },
                          error: (message) =>
                              Center(child: SelectionArea(child: Text(message))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.surface,
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
            AnimatedBuilder(
              animation: _opacityNotifier,
              builder: (_, __) => Container(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withOpacity(_opacityNotifier.value),
              ),
            ),
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  final pixels = scrollNotification.metrics.pixels;
                  _opacityNotifier.value =
                      (pixels / 560).clamp(0.0, 1.0);
                }
                return true;
              },
              child: BlocBuilder<TocCubit, TocState>(
                builder: (context, state) => state.when(
                  initial: () =>
                  const Center(child: Text('Tap to start fetching...')),
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  loaded: (items) {
                    _allItems = items;
                    _filteredItems = searchedWord.isEmpty ? items : _filteredItems;
                    return _buildTocTree(_filteredItems, context);
                  },
                  error: (message) =>
                      Center(child: SelectionArea(child: Text(message))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTocTree(List<TocItem> items, BuildContext context) {
    if (searchedWord.isNotEmpty) {
      return ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) =>
            _buildCardView(_filteredItems[index], context),
      );
    } else {
      final rootItems = items.where((item) => item.level == 1).toList();
      return ListView(
        children: rootItems.map((item) => _buildTocItem(item, context)).toList(),
      );
    }
  }


  Widget _buildTocItem(TocItem item, BuildContext context, {bool isNestedParent = false}) {
    if (item.childs == null || item.childs!.isEmpty) {
      return _buildCardView(item, context);
    } else {
      return Container(
        margin: EdgeInsets.only(
          right: 16.0,
          left: isNestedParent ? 0.0 : 16.0,
          bottom: 0,
        ),
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0,
          child: ExpansionTile(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: _buildCardTitle(item, context),
            iconColor: const Color(0xFFCFA355),
            collapsedIconColor: const Color(0xFFCFA355),
            children: item.childs!
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
    child: Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateTo(context, item),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          item.title,
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).textTheme.bodyLarge
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          right: 16, left: 16, top: 8),
                      width: 10,
                      height: 10,
                      color: const Color(0xFFCFA355),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCardTitle(TocItem item, BuildContext context) => Container(
    margin: EdgeInsets.zero,
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
      ],
    ),
  );

  void _navigateTo(BuildContext context, TocItem item) {
    if (item.items == null || item.items!.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        textAlign: TextAlign.center,
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // For balance
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: item.items!.length,
                itemBuilder: (context, index) {
                  final myItem = item.items![index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        if (myItem.addressNo != null) {
                          final String sectionNumberString = (myItem.addressNo! - 1).toString();
                          NavigationHelper.openBook(context, myItem.addressType ?? '', sectionNumberString);
                        }
                      },
                      title: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          myItem.text ?? '',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontFamily: 'Lotus Qazi Light',

                        ),
                      ),
                    ),
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }
}
