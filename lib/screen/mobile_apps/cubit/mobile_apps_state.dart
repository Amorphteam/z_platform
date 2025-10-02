part of 'mobile_apps_cubit.dart';

@freezed
class MobileAppsState with _$MobileAppsState {
  const factory MobileAppsState.initial() = _Initial;
  const factory MobileAppsState.loading() = _Loading;
  const factory MobileAppsState.loaded(List<MobileApp> mobileApps) = _Loaded;
  const factory MobileAppsState.empty() = _Empty;
  const factory MobileAppsState.error(String message) = _Error;
} 