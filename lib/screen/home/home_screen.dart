import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/screen/home/cubit/home_cubit.dart';
import 'package:zahra/screen/home/widgets/about_sheet_widget.dart';
import 'package:zahra/screen/home/widgets/home_item_widget.dart';
import 'package:zahra/screen/home/widgets/mobile_apps/mobile_apps_widget.dart';
import 'package:zahra/screen/home/widgets/mobile_apps/cubit/mobile_apps_cubit.dart';
import 'package:zahra/util/navigation_helper.dart';
import 'package:zahra/util/date_helper.dart';
import 'package:zahra/model/occasion.dart';

import '../../model/book_model.dart';
import '../../repository/database_repository.dart';
import '../../util/epub_helper.dart';
import '../hekam/hekam_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final String randomImagePath = _getRandomImagePath();

  static String _getRandomImagePath() {
    final random = Random();
    final imageNumber = random.nextInt(7) + 1; // Random number between 1 and 7
    return 'assets/image/$imageNumber.jpg';
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(0.0);
  final String defaultImagePath = 'assets/image/7.jpg';


  @override
  Widget build(BuildContext context) {
    final halfMediaHeight = MediaQuery.of(context).size.height / 2.7;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Stack(
        children: [
          _buildUnifiedLayout(context, isLandscape, halfMediaHeight),
          // Top icons overlay - always on top and accessible
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left icon (empty function)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showAboutUsSheet(context);
                        },
                        icon: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    // Right icon (settings)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/settingScreen',
                          );
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedLayout(BuildContext context, bool isLandscape, double halfMediaHeight) {
    if (isLandscape) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 100, // Full height minus top padding
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 100.0, bottom: 40, right: 40, left: 40),
                      child: _buildBackgroundImage(context, context.read<HomeCubit>().state, isLandscape: true),
                    ),
                  ),
                  Expanded(
                    child: _buildScrollableContent(context, false),
                  ),
                ],
              ),
            ),
            // Mobile Apps Section for landscape - placed underneath
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: MobileAppsWidget(),
            ),
          ],
        ),
      );
    } else {
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
              height: MediaQuery.of(context).size.height / 2,
              child: _buildBackgroundImage(context, context.read<HomeCubit>().state, isLandscape: false),
            ),
          ),
          _buildScrollableContent(context, true, halfMediaHeight),
        ],
      );
    }
  }

  Widget _buildScrollableContent(BuildContext context, bool isPortrait, [double? halfMediaHeight]) => Stack(
      children: [
        AnimatedBuilder(
          animation: _opacityNotifier,
          builder: (_, __) => Container(
            color: isPortrait
                ? Theme.of(context).colorScheme.surface.withOpacity(_opacityNotifier.value)
                : Theme.of(context).colorScheme.surface,
          ),
        ),
        NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Only handle vertical scroll notifications from the main CustomScrollView
            if (scrollNotification is ScrollUpdateNotification && 
                scrollNotification.metrics.axis == Axis.vertical) {
              final pixels = scrollNotification.metrics.pixels;
              _opacityNotifier.value = (pixels / 560).clamp(0.0, 1.0);
            }
            return true;
          },
          child: Padding(
            padding: (isPortrait) ? EdgeInsets.only(top: 40): const EdgeInsets.only(top: 100, right: 40, left: 40, bottom: 40),
            child: CustomScrollView(
              physics: isPortrait ? const ClampingScrollPhysics(): const NeverScrollableScrollPhysics(),
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
                _buildContentList(isPortrait),
              ],
            ),
          ),
        ),
      ],
    );

  Widget _buildContentList(bool isPortrait) => BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => state.when(
        initial: () => const SliverFillRemaining(
          child: Center(child: Text('Tap to start fetching...')),
        ),
        loading: () => _buildContentContainer(isPortrait, _getDefaultItems(), null, !isPortrait),
        loaded: (items, hekamText, occasions) => _buildContentContainer(isPortrait, items, hekamText, !isPortrait),
        error: (message) => SliverFillRemaining(
          child: Center(child: Text(message)),
        ),
      ),
    );

  List<String> _getDefaultItems() {
    return [
      'مقدمة الشريف الرضي',
      'الخُـــطَــــب والأوامــر',
      'الـكُــتُــب والـرَّســـائِل',
      'الـحِــــكَم والـمــواعـظ',
      'غَـــــريبُ الـكـــلـمـات',
    ];
  }

  Widget _buildContentContainer(bool isPortrait, List<String> items, String? hekamText, bool isLandscape) {
    return SliverToBoxAdapter(
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        ),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: AutoSizeText(
                  key: ValueKey(hekamText ?? 'قيمة كل امرئ ما يحسنه'),
                  hekamText ?? 'قيمة كل امرئ ما يحسنه',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'almarai',
                  ),
                  maxLines: 1,
                  minFontSize: 12,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: isPortrait ? null: MediaQuery.of(context).size.height,
              decoration: isPortrait ? BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ):BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  ...List.generate(
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
                                arguments: {'scrollToIndex': 12-1},
                              );
                            } else if (itemIndex == 4){
                              openEpub(context: context, book: Book(epub: 'ghareeb.epub'));
                            }
                          },
                          isPortrait: isPortrait,
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.black,
                          ),
                        );
                      }
                    },
                  ),
                  // Mobile Apps Section - only for portrait mode
                  if (!isLandscape) MobileAppsWidget(),
                ],
              )
            )
          ],
        ),
      ),
    );
  }

  String _getDarkImagePath(String basePath) => basePath.replaceAll('.jpg', '_dark.jpg');

  @override
  void initState() {
    super.initState();
  }

  Widget _buildBackgroundImage(BuildContext context, HomeState state, {bool isLandscape = false}) => BlocBuilder<HomeCubit, HomeState>(
    builder: (context, state) => AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: state.maybeWhen(
        loaded: (_, __, occasions) {
          final occasion = occasions != null && occasions.isNotEmpty ? occasions.first : null;
          final imagePath = Theme.of(context).brightness == Brightness.dark
              ? (occasion != null) ? 'assets/image/${occasion.occasion}_dark.jpg': _getDarkImagePath(HomeScreen.randomImagePath)
              : (occasion != null) ? 'assets/image/${occasion.occasion}.jpg': HomeScreen.randomImagePath;
          
          return Container(
            key: ValueKey(imagePath), // Important: This ensures the AnimatedSwitcher detects changes
            height: isLandscape ? MediaQuery.of(context).size.height : null,
            decoration: BoxDecoration(
              borderRadius: isLandscape ? const BorderRadius.all(Radius.circular(16)) : null,
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        orElse: () {
          final imagePath = Theme.of(context).brightness == Brightness.dark
              ? _getDarkImagePath(defaultImagePath)
              : defaultImagePath;
          
          return Container(
            key: ValueKey(imagePath), // Important: This ensures the AnimatedSwitcher detects changes
            height: isLandscape ? MediaQuery.of(context).size.height : null,
            decoration: BoxDecoration(
              borderRadius: isLandscape ? const BorderRadius.all(Radius.circular(16)) : null,
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    ),
  );


  void _showAboutUsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AboutUsSheetWidget(),
    );
  }

  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }
}

