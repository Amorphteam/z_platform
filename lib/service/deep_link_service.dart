import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
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
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (Object err) {
        debugPrint('Deep link error: $err');
      },
    );

    // Handle initial link if app was opened from a link
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
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
    final path = uri.path.isEmpty && uri.host.isNotEmpty ? '/${uri.host}' : uri.path;
    final queryParams = uri.queryParameters;

    debugPrint('Parsing URI: host=${uri.host}, path=$path, queryParams=$queryParams');

    switch (path) {
      case '/epub':
        return DeepLinkData(
          route: '/epubViewer',
          arguments: {
            'reference': ReferenceModel(bookPath: queryParams['book'] ?? '', title: '', bookName: '', navIndex: queryParams['page']?? ''),
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
