import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zahra/model/item_model.dart';
import 'package:zahra/screen/recommanded_toc/cubit/recommanded_toc_cubit.dart';
import 'package:zahra/screen/toc/cubit/toc_cubit.dart'; // Ensure the correct import of the cubit
import 'package:zahra/util/navigation_helper.dart';

import '../../model/selected_toc_item.dart';
import '../../widget/custom_appbar.dart';

class RecommandedTocScreen extends StatefulWidget {
  RecommandedTocScreen({
    super.key,
    this.title,
  });

  String? title;

  @override
  State<RecommandedTocScreen> createState() => _RecommandedTocScreenState();
}

class _RecommandedTocScreenState extends State<RecommandedTocScreen> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    context.read<RecommandedTocCubit>().fetchItems();
    if (widget.title != null && widget.title!.contains('\n')) {
      widget.title = widget.title!.replaceAll('\n', ' ');
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(
          showSearchBar: false,
          title: "الحديث الشريف",
          leftIcon: Icons.info_outline_rounded, // Example: Menu icon
          rightIcon: Icons.settings, // Example: Search icon
          onLeftTap: () {
            print("Left icon tapped!");
          },
          onRightTap: () {
            print("Right icon tapped!");
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: isLandscape
            ? Row(
          children: [
            Expanded(
              child: BlocBuilder<RecommandedTocCubit, RecommandedTocState>(
                builder: (context, state) => state.when(
                  initial: () => const Center(
                      child: Text('Tap to start fetching...')),
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  loaded: (items) {
                    return _buildSelectedTocList(items, context);
                  },
                  error: (message) =>
                      Center(child: SelectionArea(child: Text(message))),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.only(right: 48.0, left: 48, bottom: 40),
              ),
            ),
          ],
        )
            : BlocBuilder<RecommandedTocCubit, RecommandedTocState>(
          builder: (context, state) => state.when(
            initial: () => const Center(
                child: Text('Tap to start fetching...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (items) => _buildSelectedTocList(items, context),
            error: (message) =>
                Center(child: SelectionArea(child: Text(message))),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTocList(List<SelectedTocItem> items, BuildContext context) => ListView(
    children: items.map((item) => _buildSelectedTocItem(item, context)).toList(),
  );

  Widget _buildSelectedTocItem(SelectedTocItem item, BuildContext context) => Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
    child: Column(
      children: [
        Row(
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
                      margin: const EdgeInsets.only(
                          right: 16, left: 16, top: 8),
                      width: 10,
                      height: 10,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Divider(),
        )
      ],
    ),
  );

  void _navigateTo(BuildContext context, SelectedTocItem item) {
    final String bookPath = item.epub;
    final String sectionName = item.section;
    final int sectionNumber = int.parse(sectionName);
    final String sectionNumberString = (sectionNumber - 1).toString();
    NavigationHelper.openBook(context, bookPath, sectionNumberString);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
