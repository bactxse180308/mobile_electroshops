import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoongConfig {
  static String get mapTilesKey {
    final value = _dotenvValue('GOONG_MAPTILES_KEY');
    return value.isNotEmpty
        ? value
        : const String.fromEnvironment('GOONG_MAPTILES_KEY', defaultValue: '');
  }

  static String get apiKey {
    final value = _dotenvValue('GOONG_API_KEY');
    return value.isNotEmpty
        ? value
        : const String.fromEnvironment('GOONG_API_KEY', defaultValue: '');
  }

  static bool get hasMapTilesKey => mapTilesKey.trim().isNotEmpty;

  static String get styleUrl =>
      'https://tiles.goong.io/assets/goong_map_web.json?api_key=$mapTilesKey';

  static String _dotenvValue(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
