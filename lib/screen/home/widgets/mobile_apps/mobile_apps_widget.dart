import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zahra/model/mobile_app_model.dart';
import 'package:zahra/widget/cached_image_widget.dart';
import 'cubit/mobile_apps_cubit.dart';

class MobileAppsWidget extends StatefulWidget {

  const MobileAppsWidget({
    super.key,
  });

  @override
  State<MobileAppsWidget> createState() => _MobileAppsWidgetState();
}

class _MobileAppsWidgetState extends State<MobileAppsWidget> {
  late final MobileAppsCubit _mobileAppsCubit;

  @override
  void initState() {
    super.initState();
    _mobileAppsCubit = MobileAppsCubit();
    // Fetch mobile apps when widget is initialized
    _mobileAppsCubit.fetchMobileApps();
  }

  @override
  void dispose() {
    _mobileAppsCubit.close();
    super.dispose();
  }

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
    return BlocProvider.value(
      value: _mobileAppsCubit,
      child: BlocBuilder<MobileAppsCubit, MobileAppsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(), // Don't show loading indicator
            loaded: (mobileApps) => _buildMobileAppsSection(mobileApps),
            empty: () => const SizedBox.shrink(),
            error: (message) => const SizedBox.shrink(), // Don't show error
          );
        },
      ),
    );
  }

  Widget _buildMobileAppsSection(List<MobileApp> mobileApps) {
    if (mobileApps.isEmpty) return const SizedBox.shrink();

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
                itemCount: mobileApps.length,
                itemBuilder: (context, index) {
                  final app = mobileApps[index];
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
  }
} 