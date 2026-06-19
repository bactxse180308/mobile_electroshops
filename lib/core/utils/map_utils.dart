import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double lat, double lng, String label) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
  );
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // fallback: platformDefault
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

Future<void> openDialer(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri);
}
