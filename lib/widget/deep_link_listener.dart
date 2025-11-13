import 'package:flutter/material.dart';
import 'package:masaha/service/deep_link_service.dart';

class DeepLinkListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  
  const DeepLinkListener({
    super.key, 
    required this.child,
    this.navigatorKey,
  });

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _deepLinkService.initDeepLinks();
    _listenToDeepLinks();
  }

  void _listenToDeepLinks() {
    _deepLinkService.deepLinkStream.listen((DeepLinkData data) {
      debugPrint('DeepLinkListener: Deep link received - route: ${data.route}, arguments: ${data.arguments}');
      
      // Use a delay to ensure the widget tree is fully built
      Future.delayed(const Duration(milliseconds: 300), () {
        final navigator = widget.navigatorKey?.currentState;
        if (navigator != null) {
          debugPrint('DeepLinkListener: Navigating to ${data.route}');
          navigator.pushNamed(
            data.route,
            arguments: data.arguments,
          );
        } else {
          debugPrint('DeepLinkListener: ERROR - Navigator key is null! Cannot navigate to ${data.route}');
        }
      });
    }, onError: (error) {
      debugPrint('DeepLinkListener: Error listening to deep links: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }
}
