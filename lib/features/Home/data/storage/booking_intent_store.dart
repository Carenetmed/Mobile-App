import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/booking_intent.dart';

abstract class BookingIntentStore {
  Future<void> save(BookingIntent intent);

  Future<BookingIntent?> read({DateTime? now});

  Future<void> clear();
}

class SecureBookingIntentStore implements BookingIntentStore {
  const SecureBookingIntentStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _key = 'carenet.booking.intent.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<void> save(BookingIntent intent) {
    return _storage.write(key: _key, value: jsonEncode(intent.toJson()));
  }

  @override
  Future<BookingIntent?> read({DateTime? now}) async {
    final encoded = await _storage.read(key: _key);
    if (encoded == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }
      final intent = BookingIntent.fromJson(decoded);
      if (intent.isExpired(now ?? DateTime.now().toUtc())) {
        await clear();
        return null;
      }
      return intent;
    } catch (_) {
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class InMemoryBookingIntentStore implements BookingIntentStore {
  BookingIntent? _intent;

  @override
  Future<void> save(BookingIntent intent) async {
    _intent = intent;
  }

  @override
  Future<BookingIntent?> read({DateTime? now}) async {
    final intent = _intent;
    if (intent != null && intent.isExpired(now ?? DateTime.now().toUtc())) {
      _intent = null;
      return null;
    }
    return intent;
  }

  @override
  Future<void> clear() async {
    _intent = null;
  }
}
