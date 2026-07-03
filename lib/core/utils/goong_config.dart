import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoongConfig {
  static String get mapTilesKey =>
      dotenv.env['GOONG_MAPTILES_KEY'] ??
      const String.fromEnvironment('GOONG_MAPTILES_KEY', defaultValue: '');

  static String get apiKey =>
      dotenv.env['GOONG_API_KEY'] ??
      const String.fromEnvironment('GOONG_API_KEY', defaultValue: '');

  static bool get hasMapTilesKey => mapTilesKey.trim().isNotEmpty;

  static String get styleUrl =>
      'https://tiles.goong.io/assets/goong_map_web.json?api_key=$mapTilesKey';
}
