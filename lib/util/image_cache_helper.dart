import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ImageCacheHelper {
  static final ImageCacheHelper _instance = ImageCacheHelper._internal();
  factory ImageCacheHelper() => _instance;
  ImageCacheHelper._internal();

  Future<String> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    final extension = path.extension(url).isEmpty ? '.jpg' : path.extension(url);
    return '${digest.toString()}$extension';
  }

  Future<String?> getCachedImagePath(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    
    try {
      final fileName = _generateFileName(imageUrl);
      final cacheDir = await _cacheDir;
      final filePath = path.join(cacheDir, fileName);
      final file = File(filePath);
      
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      print('Error getting cached image path: $e');
      return null;
    }
  }

  Future<String?> cacheImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    
    try {
      final fileName = _generateFileName(imageUrl);
      final cacheDir = await _cacheDir;
      final filePath = path.join(cacheDir, fileName);
      final file = File(filePath);
      
      // Check if already cached
      if (await file.exists()) {
        return filePath;
      }
      
      // Download and cache the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      
      return null;
    } catch (e) {
      print('Error caching image: $e');
      return null;
    }
  }

  Future<void> cacheImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      if (url.isNotEmpty) {
        await cacheImage(url);
      }
    }
  }

  Future<void> clearImageCache() async {
    try {
      final cacheDir = await _cacheDir;
      final dir = Directory(cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  Future<int> getImageCacheSize() async {
    try {
      final cacheDir = await _cacheDir;
      final dir = Directory(cacheDir);
      if (!await dir.exists()) return 0;
      
      int totalSize = 0;
      await for (final file in dir.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }
} 