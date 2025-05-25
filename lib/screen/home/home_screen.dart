import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/screen/home/cubit/home_cubit.dart';
import 'package:zahra/screen/home/widgets/home_item_widget.dart';
import 'package:zahra/util/navigation_helper.dart';
import 'package:zahra/util/date_helper.dart';
import 'package:zahra/model/occasion.dart';

import '../../model/book_model.dart';
import '../../repository/database_repository.dart';
import '../../util/epub_helper.dart';
import '../hekam/hekam_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final halfMediaHeight = MediaQuery.of(context).size.height / 2.4;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: isLandscape ? _buildLandscapeLayout(context) : _buildPortraitLayout(context, halfMediaHeight),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildScrollableContent(context, false),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.only(top: 40.0, bottom: 40),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (_, __, occasions) {
                    if (occasions != null && occasions.isNotEmpty) {
                      final occasion = occasions.first;
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 'assets/image/${occasion.occasion}_dark.jpg'
                                  : 'assets/image/${occasion.occasion}.jpg',
                            ),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      );
                    }
                    return Container(
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
                    );
                  },
                  orElse: () => Container(
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context, double halfMediaHeight) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loaded: (_, __, occasions) {
                    if (occasions != null && occasions.isNotEmpty) {
                      final occasion = occasions.first;
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 'assets/image/${occasion.occasion}_dark.jpg'
                                  : 'assets/image/${occasion.occasion}.jpg',
                            ),
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'assets/image/landimage_dark.jpg'
                                : 'assets/image/landimage_light.jpg',
                          ),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    );
                  },
                  orElse: () => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/image/landimage_dark.jpg'
                              : 'assets/image/landimage_light.jpg',
                        ),
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _buildScrollableContent(context, true, halfMediaHeight),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context, bool isPortrait, [double? halfMediaHeight]) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _opacityNotifier,
          builder: (_, __) => Container(
            color: isPortrait
                ? Theme.of(context).colorScheme.primary.withOpacity(_opacityNotifier.value)
                : Theme.of(context).colorScheme.primary,
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
            padding: (isPortrait) ? EdgeInsets.only(top: 40): const EdgeInsets.only(top: 40, right: 40, left: 40),
            child: CustomScrollView(
              slivers: <Widget>[
                if (isPortrait && halfMediaHeight != null)
                  SliverAppBar(
                    expandedHeight: halfMediaHeight,
                    floating: false,
                    pinned: false,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: const FlexibleSpaceBar(),
                  ),
                _buildContentList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentList() => BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => state.when(
        initial: () => const SliverFillRemaining(
          child: Center(child: Text('Tap to start fetching...')),
        ),
        loading: () => const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
        loaded: (items, hekamText, _) => SliverToBoxAdapter(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/image/back_tazhib_dark.jpg'
                      : 'assets/image/back_tazhib_light.jpg',
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: state.maybeWhen(
                    loaded: (_, onScreenText, __) => Html(
                      data: onScreenText ?? 'قيمة كل امرئ ما يحسنه',
                      style: {
                        "body": Style(
                          textAlign: TextAlign.center,
                          color: Colors.white,
                          fontSize: FontSize(20),
                            fontFamily: 'almarai'
                        ),
                      },
                    ),
                    orElse: () => const Text(
                      'قيمة كل امرئ ما يحسنه',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'almarai',
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Color(0xFFdad7d1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: List.generate(
                      items.length * 2 - 1,
                      (index) {
                        if (index.isEven) {
                          final itemIndex = index ~/ 2;
                          return HomeItemWidget(
                            text: items[itemIndex],
                            isLast: itemIndex == items.length - 1,
                            isFirst: itemIndex == 0,
                            onTap: () {
                              if (itemIndex == 0){
                                openEpub(context: context, book: Book(epub: 'moqadameh.epub'));
                              } else if (itemIndex == 1){
                                NavigationHelper.navigateToTocWithNumber(context, 'الخطب والأوامر', 'assets/json/khotab_index.json');
                              } else if (itemIndex == 2) {
                                NavigationHelper.navigateToTocWithNumber(context, 'الكتب والرسائل', 'assets/json/letters_index.json');
                              } else if (itemIndex == 3) {
                                Navigator.of(context).pushNamed(
                                  '/hekam',
                                );
                              } else if (itemIndex == 4){
                                openEpub(context: context, book: Book(epub: 'ghareeb.epub'));
                              }
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: const Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (message) => SliverFillRemaining(
          child: Center(child: Text(message)),
        ),
      ),
    );

  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }
}
