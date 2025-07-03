import 'dart:math';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zahra/screen/home/cubit/home_cubit.dart';
import 'package:zahra/screen/home/widgets/about_sheet_widget.dart';
import 'package:zahra/screen/home/widgets/home_item_widget.dart';
import 'package:zahra/util/navigation_helper.dart';
import 'package:zahra/util/date_helper.dart';
import 'package:zahra/model/occasion.dart';
import 'package:zahra/model/mobile_app_model.dart';
import 'package:zahra/widget/cached_image_widget.dart';

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
  late AnimationController _imageAnimationController;
  late Animation<double> _imageFadeAnimation;

  String _getDarkImagePath(String basePath) => basePath.replaceAll('.jpg', '_dark.jpg');

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );
    _imageFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Widget _buildBackgroundImage(BuildContext context, HomeState state, {bool isLandscape = false}) => BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Start animation when data is loaded
        if (state.maybeWhen(loaded: (_, __, ___, ____) => true, orElse: () => false)) {
          _imageAnimationController.forward();
        }
        
        return state.maybeWhen(
          loaded: (_, __, occasions, ___) {
            final occasion = occasions?.first;
            return AnimatedBuilder(
              animation: _imageFadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _imageFadeAnimation,
                  child: Container(
                    height: isLandscape ? MediaQuery.of(context).size.height : null,
                    decoration: BoxDecoration(
                      borderRadius: isLandscape ? const BorderRadius.all(Radius.circular(16)) : null,
                      image: DecorationImage(
                        image: AssetImage(
                          Theme.of(context).brightness == Brightness.dark
                              ? (occasions != null && occasions.isNotEmpty) ? 'assets/image/${occasion?.occasion}_dark.jpg': _getDarkImagePath(HomeScreen.randomImagePath)
                              : (occasions != null && occasions.isNotEmpty) ? 'assets/image/${occasion?.occasion}.jpg': HomeScreen.randomImagePath,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          orElse: () =>
             Container(
                height: isLandscape ? MediaQuery.of(context).size.height : null,
                decoration: BoxDecoration(
                  borderRadius: isLandscape ? const BorderRadius.all(Radius.circular(16)) : null,
                  image: DecorationImage(
                    image: AssetImage(
                      Theme.of(context).brightness == Brightness.dark
                          ? _getDarkImagePath(HomeScreen.randomImagePath)
                          : HomeScreen.randomImagePath,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),


        );
      },
    );

  Future<void> _openAppStore(MobileApp app) async {
    try {
      String url;
      
      if (Platform.isIOS) {
        // For iOS, use the iOS App Store link
        url = 'https://apps.apple.com/app/id${app.iosID}';
      } else if (Platform.isAndroid) {
        // For Android, construct Google Play Store URL from package name
        url = 'https://play.google.com/store/apps/details?id=${app.androidLink}';
      } else {
        // For other platforms, default to Android link
        url = 'https://play.google.com/store/apps/details?id=${app.androidLink}';
      }
      
      print('Opening URL: $url'); // Debug print
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to open the URL anyway
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening app store: $e');
      // Show a snackbar or dialog to inform the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح متجر التطبيقات'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

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
      return Row(
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
        loading: () => const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
        loaded: (items, hekamText, _, __) => SliverToBoxAdapter(
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
              borderRadius:  const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              )
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: state.maybeWhen(
                    loaded: (_, onScreenText, __, ___) => AutoSizeText(
                      onScreenText ?? 'قيمة كل امرئ ما يحسنه',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'almarai',
                      ),
                      maxLines: 1,
                      minFontSize: 12,
                    ),
                    orElse: () => const AutoSizeText(
                      'قيمة كل امرئ ما يحسنه',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                      // Mobile Apps Section
                      if (state.maybeWhen(
                        loaded: (_, __, ___, mobileApps) => mobileApps != null && mobileApps.isNotEmpty,
                        orElse: () => false,
                      ))
                        _buildMobileAppsSection(context, state, isPortrait),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        error: (message) => SliverFillRemaining(
          child: Center(child: Text(message)),
        ),
      ),
    );

  Widget _buildMobileAppsSection(BuildContext context, HomeState state, bool isPortrait) => state.maybeWhen(
      loaded: (_, __, ___, mobileApps) {
        if (mobileApps == null || mobileApps.isEmpty) return const SizedBox.shrink();

        // Filter apps: remove current app and apps without images
        final filteredApps = mobileApps.where((app) {
          // Skip if no image
          if (app.picPath.isEmpty) return false;

          // Skip if it's the current app (check package name in android link)
          if (app.androidLink.contains('org.masaha.nahj')) {
            return false;
          }

          return true;
        }).toList();
        filteredApps.shuffle();
        // Don't show section if no valid apps
        if (filteredApps.isEmpty) return const SizedBox.shrink();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'تطبيقات مختارة',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = filteredApps[index];
                      return GestureDetector(
                        onTap: () => _openAppStore(app),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 200,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CachedImageWidget(
                                  imageUrl: app.picPath,
                                  width: 200,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  errorWidget: const SizedBox.shrink(), // Don't show anything if image fails
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  app.appName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'almarai',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
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
    _imageAnimationController.dispose();
    super.dispose();
  }
}

