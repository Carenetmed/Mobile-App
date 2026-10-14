import 'package:intl/date_symbol_data_local.dart';

/// Presentation only; never converts currencies, dates or timezones.
class CareNetPresentation {
  CareNetPresentation._();

  // intl 0.20.2 does not bundle en_NG dates. Use bundled day-first English data.
  static const dateLocale = 'en_GB';
  static const numberLocale = 'en_NG';
  static Future<void>? _initialization;
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> initialize() => _initialization ??= _initialize();

  static Future<void> _initialize() async {
    await initializeDateFormatting(dateLocale);
    _initialized = true;
  }
}
