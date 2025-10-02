import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../api/api_client.dart';
import '../../../model/mobile_app_model.dart';
import '../../../repository/database_repository.dart';
import '../../../util/image_cache_helper.dart';

part 'mobile_apps_state.dart';
part 'mobile_apps_cubit.freezed.dart';

class MobileAppsCubit extends Cubit<MobileAppsState> {
  final DatabaseRepository _databaseRepository = DatabaseRepository();
  final ApiClient _apiClient = ApiClient();
  final ImageCacheHelper _imageCacheHelper = ImageCacheHelper();

  MobileAppsCubit() : super(const MobileAppsState.initial());

  Future<void> fetchMobileApps() async {
    try {
      emit(const MobileAppsState.loading());

      List<MobileApp>? mobileApps;
      try {
        // Try to fetch from API first
        final mobileAppsResponse = await _apiClient.getMobileApps();
        mobileApps = mobileAppsResponse.data;
        
        // Cache the data and images if successful
        if (mobileApps != null && mobileApps.isNotEmpty) {
          await _databaseRepository.saveMobileApps(mobileApps);
          
          // Cache images in background
          final imageUrls = mobileApps
              .where((app) => app.picPath.isNotEmpty)
              .map((app) => app.picPath)
              .toList();
          _imageCacheHelper.cacheImages(imageUrls);
        }
      } catch (e) {
        // If API fails, try to get cached data
        try {
          final hasCachedData = await _databaseRepository.hasCachedMobileApps();
          if (hasCachedData) {
            mobileApps = await _databaseRepository.getCachedMobileApps();
            print('Using cached mobile apps data');
          } else {
            mobileApps = null;
          }
        } catch (cacheError) {
          mobileApps = null;
          print('Error accessing cached data: $cacheError');
        }
      }

      // Filter and process apps
      final filteredApps = _filterAndProcessApps(mobileApps ?? []);
      
      if (filteredApps.isNotEmpty) {
        emit(MobileAppsState.loaded(filteredApps));
      } else {
        emit(const MobileAppsState.empty());
      }
    } catch (e) {
      emit(MobileAppsState.error(e.toString()));
    }
  }

  List<MobileApp> _filterAndProcessApps(List<MobileApp> apps) {
    // Filter apps: remove current app and apps without images
    final filteredApps = apps.where((app) {
      // Skip if no image
      if (app.picPath.isEmpty) return false;

      // Skip if it's the current app (check package name in android link)
      // if (app.androidLink.contains('org.masaha.nahj')) {
      //   return false;
      // }

      return true;
    }).toList();
    
    // Shuffle the apps for variety
    filteredApps.shuffle();
    
    return filteredApps;
  }

  void refreshApps() {
    fetchMobileApps();
  }
} 