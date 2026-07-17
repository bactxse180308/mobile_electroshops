import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  DeepLinkService._privateConstructor();

  static final DeepLinkService instance = DeepLinkService._privateConstructor();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Stream for widgets to listen to (warm start)
  final StreamController<Uri> _linkStreamController = StreamController<Uri>.broadcast();
  Stream<Uri> get linkStream => _linkStreamController.stream;

  // Store pending link for cold start
  Uri? _pendingLink;

  Future<void> init() async {
    // 1. Check for initial link (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('[DeepLinkService] Cold start link found: $initialUri');
        _pendingLink = initialUri;
      }
    } catch (e) {
      debugPrint('[DeepLinkService] Error getting initial app link: $e');
    }

    // 2. Listen for incoming links (warm start)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('[DeepLinkService] Warm start link received: $uri');
        _linkStreamController.add(uri);
      },
      onError: (err) {
        debugPrint('[DeepLinkService] Stream error: $err');
      },
    );
  }

  /// Consumes the pending link if it matches payment-result.
  /// This prevents processing the same cold-start link multiple times.
  Future<Uri?> consumePendingLink() async {
    final link = _pendingLink;
    if (link != null && link.scheme == 'electroshop' && link.host == 'payment-result') {
      _pendingLink = null;
      return link;
    }
    return null;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkStreamController.close();
  }
}
