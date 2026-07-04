import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double lat, double lng, String label) async {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '$lat,$lng',
  });
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

Future<void> openDialer(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri);
}

double calculateDistanceKm(
  double fromLat,
  double fromLng,
  double toLat,
  double toLng,
) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(toLat - fromLat);
  final dLng = _degToRad(toLng - fromLng);
  final lat1 = _degToRad(fromLat);
  final lat2 = _degToRad(toLat);

  final a =
      pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLng / 2), 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double degree) => degree * pi / 180;
