import '../repository/database_repository.dart';
import 'image_cache_helper.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final DatabaseRepository _databaseRepository = DatabaseRepository();
  final ImageCacheHelper _imageCacheHelper = ImageCacheHelper();

  /// Clear all cached data (mobile apps and images)
  Future<void> clearAllCache() async {
    try {
      await Future.wait([
        _databaseRepository.clearMobileAppsCache(),
        _imageCacheHelper.clearImageCache(),
      ]);
    } catch (e) {
      print('Error clearing cache: $e');
      rethrow;
    }
  }

  /// Get total cache size in bytes
  Future<int> getTotalCacheSize() async {
    try {
      final imageCacheSize = await _imageCacheHelper.getImageCacheSize();
      // Note: SQLite cache size is typically small, so we'll just return image cache size
      // In a more sophisticated implementation, you could query SQLite cache size too
      return imageCacheSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  /// Get cache size in human readable format
  Future<String> getCacheSizeFormatted() async {
    final sizeInBytes = await getTotalCacheSize();
    return _formatBytes(sizeInBytes);
  }

  /// Check if mobile apps cache exists
  Future<bool> hasMobileAppsCache() async {
    try {
      return await _databaseRepository.hasCachedMobileApps();
    } catch (e) {
      return false;
    }
  }

  /// Get cached mobile apps count
  Future<int> getCachedMobileAppsCount() async {
    try {
      final apps = await _databaseRepository.getCachedMobileApps();
      return apps.length;
    } catch (e) {
      return 0;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
} 