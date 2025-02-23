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
  bool _showSearchBar = true;
  String searchedWord = '';

  @override
  void initState() {
    super.initState();
    context.read<TocCubit>().fetchItems(id: widget.id);
  }

  void _filterItems(String query) {
    setState(() {
      searchedWord = query;
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        // Show only leaf nodes (last children) in a flat list
        _filteredItems = _allItems
            .where((item) => (item.childs == null || item.childs!.isEmpty) &&
            item.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: CustomAppBar(
        title: "الحديث الشريف",
        leftIcon: Icons.info_outline_rounded,
        rightIcon: Icons.dark_mode_outlined,
        onLeftTap: () => print("Left icon tapped!"),
        onRightTap: () {
        },
        onSearch: _showSearchBar ? _filterItems : null, // Pass search function only if needed
        showSearchBar: _showSearchBar,
      ),
      body: BlocBuilder<TocCubit, TocState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Tap to start fetching...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (items) {
              _allItems = items;
              _filteredItems = _filteredItems.isNotEmpty ? _filteredItems : items;
              return _buildTocTree(_filteredItems, context);
            },
            error: (message) => Center(child: Text(message)),
          );
        },
      ),
    );
  }


  Widget _buildTocTree(List<TocItem> items, BuildContext context) {
    if (searchedWord.isNotEmpty && _filteredItems.isNotEmpty) {
      // If searching, show a normal (flat) list
      return ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) => _buildCardView(_filteredItems[index], context),
      );
    } else {
      // If not searching, show the tree structure
      final rootItems = items.where((item) => item.parentId == 0).toList();
      return ListView(
        children: rootItems.map((item) => _buildTocItem(item, context)).toList(),
      );
    }
  }


  Widget _buildTocItem(TocItem item, BuildContext context,
      {bool isNestedParent = false}) {
    if (item.childs == null || item.childs!.isEmpty) {
      return _buildCardView(item, context);
    } else {
      return Container(
        margin: EdgeInsets.only(
          right: 8.0,
          left: isNestedParent ? 0.0 : 8.0,
          bottom: 0,
        ),
        child: Column(
          children: [
            ExpansionTile(
              title: _buildCardTitle(item, context),
              shape: const RoundedRectangleBorder(
                side: BorderSide.none, // Completely removes the border
              ),
              iconColor: Theme.of(context).colorScheme.secondary,
              collapsedIconColor: Theme.of(context).colorScheme.secondary,
              children: item.childs!
                  .map((child) => _buildTocItem(child, context, isNestedParent: true))
                  .toList(),
            ),
            Divider()
          ],
        ),
      );
    }
  }

  Widget _buildCardView(TocItem item, BuildContext context) => Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
    child: Card(
      color: Theme.of(context).colorScheme.primary,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.all(8.0),
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
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 16, left: 16, top: 8),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle, // Makes it a circle
                      ),
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
      ],
    ),
  );

  void _navigateTo(BuildContext context, TocItem item) {
    final String bookPath = item.key.split('_').first;
    final String sectionName = item.key.split('_').last;
    final int sectionNumber = int.parse(sectionName);
    final String sectionNumberString = (sectionNumber - 1).toString();
    NavigationHelper.openBook(context, bookPath, sectionNumberString);
  }

  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }
}
