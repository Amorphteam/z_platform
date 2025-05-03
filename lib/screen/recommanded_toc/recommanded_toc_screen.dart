import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/selected_toc_item.dart';
import '../../util/navigation_helper.dart';
import '../../widget/custom_appbar.dart';
import 'cubit/recommanded_toc_cubit.dart';

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
          rightIcon: Icons.dark_mode_outlined, // Example: Search icon
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocBuilder<RecommandedTocCubit, RecommandedTocState>(
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
