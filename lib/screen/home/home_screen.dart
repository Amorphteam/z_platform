import 'package:flutter/material.dart';

import '../../util/snap_scroll_physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../util/navigation_helper.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final halfMediaHeight = mediaQuery.size.height / 1.7;
    final snapExtent = mediaQuery.size.height * 0.65;
    context.read<HomeCubit>().fetchItems();
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: isLandscape
          ? Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _opacityNotifier,
                  builder: (_, __) => Container(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      final pixels = scrollNotification.metrics.pixels;
                      _opacityNotifier.value = (pixels / 560).clamp(0.0, 1.0);
                    }
                    return true;
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 48.0, left: 48, top: 40),
                    child: CustomScrollView(
                      physics: SnapScrollPhysics(
                        snapExtent: snapExtent,
                        parent: const BouncingScrollPhysics(),
                      ),
                      cacheExtent: 500,
                      slivers: <Widget>[
                        if (!isLandscape)
                          SliverAppBar(
                            expandedHeight: halfMediaHeight,
                            floating: false,
                            pinned: false,
                            backgroundColor: Colors.transparent,
                            flexibleSpace: const FlexibleSpaceBar(),
                          ),
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, state) => state.when(
                            initial: () => const SliverFillRemaining(
                              child: Center(child: Text('Tap to start fetching...')),
                            ),
                            loading: () => const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            loaded: (items) => SliverMainAxisGroup(
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (index > 0)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            child: Divider(
                                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                              thickness: 1,
                                              indent: 24,
                                              endIndent: 24,
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 12, left: 12),
                                          child: NavigationHelper.buildItem(context, items[index]),
                                        ),
                                      ],
                                    ),
                                    childCount: items.length,
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                    addSemanticIndexes: false,
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 80)),
                              ],
                            ),
                            error: (message) => SliverFillRemaining(
                              child: Center(child: Text(message)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              padding: const EdgeInsets.only(top: 40.0, bottom: 40),
            ),
          ),


        ],
      )
          : Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          AnimatedBuilder(
            animation: _opacityNotifier,
            builder: (_, __) => Container(
              color: Colors.transparent,
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                final pixels = scrollNotification.metrics.pixels;
                _opacityNotifier.value = (pixels / 560).clamp(0.0, 1.0);
              }
              return true;
            },
            child: CustomScrollView(
              physics: SnapScrollPhysics(
                snapExtent: snapExtent,
                parent: const BouncingScrollPhysics(),
              ),
              cacheExtent: 500,
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: halfMediaHeight,
                  floating: false,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: const FlexibleSpaceBar(),
                ),
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) => state.when(
                    initial: () => const SliverFillRemaining(
                      child: Center(child: Text('Tap to start fetching...')),
                    ),
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    loaded: (items) => SliverMainAxisGroup(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (index > 0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                            thickness: 1,
                                            indent: 16,
                                            endIndent: 12,
                                          ),
                                        ),
                                        SvgPicture.asset('assets/image/zakhrafa.svg', width: 24, height: 24, color: Theme.of(context).colorScheme.outline,),
                                        Expanded(
                                          child: Divider(
                                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                            thickness: 1,
                                            indent: 12,
                                            endIndent: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 12, left: 12),
                                  child: NavigationHelper.buildItem(context, items[index]),
                                ),
                              ],
                            ),
                            childCount: items.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            addSemanticIndexes: false,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                    error: (message) => SliverFillRemaining(
                      child: Center(child: Text(message)),
                    ),
                  ),
                ),
              ],
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
