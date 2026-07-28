import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/payment_checkout_intent.dart';

abstract class PaymentCheckoutIntentStore {
  Future<void> save(PaymentCheckoutIntent intent);

  Future<PaymentCheckoutIntent?> read({
    required String appointmentId,
    required String accountUserId,
    DateTime? now,
  });

  Future<void> clear();
}

class SecurePaymentCheckoutIntentStore implements PaymentCheckoutIntentStore {
  const SecurePaymentCheckoutIntentStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _key = 'carenet.paymentCheckoutIntent.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<void> save(PaymentCheckoutIntent intent) {
    return _storage.write(key: _key, value: jsonEncode(intent.toJson()));
  }

  @override
  Future<PaymentCheckoutIntent?> read({
    required String appointmentId,
    required String accountUserId,
    DateTime? now,
  }) async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) {
        return null;
      }
      final decoded = jsonDecode(raw);
      final intent = PaymentCheckoutIntent.fromJson(
        decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded as Map),
      );
      if (intent.appointmentId != appointmentId ||
          intent.accountUserId != accountUserId ||
          intent.isExpired(now ?? DateTime.now())) {
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

class InMemoryPaymentCheckoutIntentStore implements PaymentCheckoutIntentStore {
  PaymentCheckoutIntent? value;

  @override
  Future<void> save(PaymentCheckoutIntent intent) async {
    value = intent;
  }

  @override
  Future<PaymentCheckoutIntent?> read({
    required String appointmentId,
    required String accountUserId,
    DateTime? now,
  }) async {
    final current = value;
    if (current == null) {
      return null;
    }
    if (current.appointmentId != appointmentId ||
        current.accountUserId != accountUserId ||
        current.isExpired(now ?? DateTime.now())) {
      value = null;
      return null;
    }
    return current;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}
