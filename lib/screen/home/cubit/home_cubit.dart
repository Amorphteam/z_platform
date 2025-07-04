import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zahra/model/item_model.dart';
import 'package:zahra/model/occasion.dart';
import 'package:zahra/model/onscreen.dart';
import 'package:zahra/model/mobile_app_model.dart';
import 'package:zahra/repository/database_repository.dart';
import 'package:zahra/util/date_helper.dart';
import 'package:zahra/util/image_cache_helper.dart';
import '../../../repository/json_repository.dart';
import '../../../api/api_client.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

class HomeCubit extends Cubit<HomeState> {
  final DatabaseRepository _databaseRepository = DatabaseRepository();
  final ApiClient _apiClient = ApiClient();
  final ImageCacheHelper _imageCacheHelper = ImageCacheHelper();
  final List<String> items = [
    'مقدمة الشريف الرضي',
    'الخُـــطَــــب والأوامــر',
    'الـكُــتُــب والـرَّســـائِل',
    'الـحِــــكَم والـمــواعـظ',
    'غَـــــريبُ الـكـــلـمـات',
  ];

  HomeCubit() : super(const HomeState.initial());

  Future<void> fetchItems() async {
    try {
      emit(const HomeState.loading());


      // First, get occasions
      final occasions = await DateHelper.getOccasionsForCurrentDate();

      // Fetch mobile apps with caching support
      List<MobileApp>? mobileApps;
      try {
        // Try to fetch from API first
        final mobileAppsResponse = await _apiClient.getMobileApps();
        mobileApps = mobileAppsResponse.data;
        
        // Cache the data and images if successful
        if (mobileApps.isNotEmpty) {
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

      // Then fetch the text separately
      final randomText = await _databaseRepository.getRandomOnscreenText();
      
      // Update state with the text and mobile apps (null if fetch failed)
      if (randomText != null) {
        emit(HomeState.loaded(items, hekamText: randomText.textAr, occasions: occasions, mobileApps: mobileApps));
      } else {
        emit(HomeState.loaded(items, occasions: occasions, mobileApps: mobileApps));
      }
    } catch (e) {
      emit(HomeState.error(e.toString()));
    }
  }
}
