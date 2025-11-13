import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:masaha/model/deep_link_model.dart';
import 'package:masaha/model/reference_model.dart';
import 'package:masaha/screen/bookmark/widgets/reference_list_widget.dart';
import '../model/book_model.dart';

/// Deep Link Service to handle incoming app links and URL schemes
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Stream to listen for incoming deep links
  final StreamController<DeepLinkData> _deepLinkController = 
      StreamController<DeepLinkData>.broadcast();
  
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  /// Initialize deep link listening
  void initDeepLinks() {
    // Handle initial link if app was opened from a link (Android/iOS)
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        debugPrint('Initial deep link received: $uri');
        _handleDeepLink(uri);
      }
    }).catchError((error) {
      debugPrint('Error getting initial deep link: $error');
    });

    // Listen for subsequent deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('Subsequent deep link received: $uri');
        _handleDeepLink(uri);
      },
      onError: (Object err) {
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link received: $uri');
    
    final data = _parseUri(uri);
    _deepLinkController.add(data);
  }

  /// Parse URI to extract deep link data
  DeepLinkData _parseUri(Uri uri) {
    // For custom URL schemes like masaha://chat, uri.host contains 'chat'
    // For schemes like masaha://epub?book=1, uri.host is empty and path is empty
    // We need to check both host and path
    String path;
    if (uri.path.isNotEmpty) {
      path = uri.path;
    } else if (uri.host.isNotEmpty) {
      path = '/${uri.host}';
    } else {
      // Fallback: try to extract from authority or full path
      path = uri.hasAuthority && uri.authority.isNotEmpty 
          ? '/${uri.authority.split(':').first}' 
          : '/';
    }
    
    final queryParams = uri.queryParameters;

    debugPrint('Parsing URI: scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}, authority=${uri.authority}');
    debugPrint('Parsed path: $path, queryParams: $queryParams');

    switch (path) {
      case '/epub':
        final String? bookParam = queryParams['book'];
        final String? pageParam = queryParams['page'];
        final bool isFileName = pageParam != null && (pageParam.endsWith('.xml') || pageParam.endsWith('.xhtml') || pageParam.endsWith('.html'));
        
        // Parse pageParam to determine if it's a file name or index
        int? epubIndex;
        if (!isFileName && pageParam != null) {
          epubIndex = int.tryParse(pageParam);
        }

        // Create DeepLinkModel
        final deepLinkModel = DeepLinkModel(
          fileName: isFileName ? pageParam : null,
          epubIndex: epubIndex,
          epubName: bookParam ?? '',
        );

        return DeepLinkData(
          route: '/epubViewer',
          arguments: {
            'deepLink': deepLinkModel,
            // Keep reference for backward compatibility if needed
            'reference': ReferenceModel(
              bookPath: bookParam ?? '',
              title: '',
              bookName: '',
              navIndex: isFileName ? '0' : (pageParam ?? ''),
              fileName: isFileName ? pageParam : null,
            ),
          },
        );

      case '/search':
        return DeepLinkData(
          route: '/searchScreen',
          arguments: {
            'query': queryParams['query'],
          },
        );
      
      case '/chat':
        return DeepLinkData(
          route: '/chat',
          arguments: {},
        );
      
      default:
        return DeepLinkData(
          route: '/',
          arguments: {},
        );
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _deepLinkController.close();
  }
}

/// Data model for deep links
class DeepLinkData {
  final String route;
  final Map<String, dynamic> arguments;

  DeepLinkData({
    required this.route,
    required this.arguments,
  });
}
