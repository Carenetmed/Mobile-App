import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/financial_repository.dart';
import '../../data/storage/payment_checkout_intent_store.dart';
import '../../domain/entities/appointment_summary.dart';
import '../../domain/entities/financial_entities.dart';
import '../../domain/entities/payment_checkout_intent.dart';
import '../../domain/services/booking_idempotency_key_factory.dart';
import '../../domain/services/hosted_checkout_launcher.dart';

class AppointmentPaymentController extends ChangeNotifier {
  AppointmentPaymentController({
    required this.appointmentId,
    required FinancialRepository financialRepository,
    required SessionStore sessionStore,
    required PaymentCheckoutIntentStore intentStore,
    HostedCheckoutLauncher launcher = const SystemHostedCheckoutLauncher(),
    BookingIdempotencyKeyFactory? keyFactory,
    DateTime Function()? now,
  }) : _repository = financialRepository,
       _sessionStore = sessionStore,
       _intentStore = intentStore,
       _launcher = launcher,
       _keyFactory = keyFactory ?? BookingIdempotencyKeyFactory(),
       _now = now ?? DateTime.now;

  final String appointmentId;
  final FinancialRepository _repository;
  final SessionStore _sessionStore;
  final PaymentCheckoutIntentStore _intentStore;
  final HostedCheckoutLauncher _launcher;
  final BookingIdempotencyKeyFactory _keyFactory;
  final DateTime Function() _now;

  AppointmentPaymentView? view;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isInitializing = false;
  bool awaitingBrowserReturn = false;
  String? errorMessage;
  String? actionMessage;

  Future<void>? _activeLoad;
  Future<void>? _activeInitialization;
  int _generation = 0;
  bool _disposed = false;

  bool get canPay {
    final payment = view?.payment;
    return payment?.status == AppointmentPaymentStatus.awaitingPayment &&
        payment!.dueAt.isAfter(_now().toUtc()) &&
        !isLoading &&
        !isRefreshing &&
        !isInitializing;
  }

  Future<void> load({bool refreshProvider = false}) {
    final active = _activeLoad;
    if (active != null) {
      return active;
    }
    final future = _load(refreshProvider: refreshProvider);
    _activeLoad = future;
    return future.whenComplete(() {
      if (identical(_activeLoad, future)) {
        _activeLoad = null;
      }
    });
  }

  Future<void> _load({required bool refreshProvider}) async {
    final generation = ++_generation;
    final hasData = view != null;
    isLoading = !hasData;
    isRefreshing = hasData;
    errorMessage = null;
    _notify();
    try {
      final loaded =
          refreshProvider
              ? await _repository.refreshPayment(appointmentId)
              : await _repository.appointmentPayment(appointmentId);
      if (!_accept(generation)) {
        return;
      }
      view = loaded;
      awaitingBrowserReturn = false;
      if (_isTerminal(loaded.payment?.status)) {
        await _intentStore.clear();
      }
    } catch (error) {
      if (!_accept(generation)) {
        return;
      }
      errorMessage = _safePaymentError(error);
      if (error is AuthFailure && error.statusCode == 404) {
        await _intentStore.clear();
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  Future<void> beginCheckout() {
    final active = _activeInitialization;
    if (active != null) {
      return active;
    }
    final future = _beginCheckout();
    _activeInitialization = future;
    return future.whenComplete(() {
      if (identical(_activeInitialization, future)) {
        _activeInitialization = null;
      }
    });
  }

  Future<void> _beginCheckout() async {
    if (!canPay) {
      errorMessage = 'This appointment is not currently payable.';
      _notify();
      return;
    }
    final session = await _sessionStore.read();
    if (session == null) {
      errorMessage = 'Your session has expired. Please sign in again.';
      _notify();
      return;
    }
    if (session.user.role.trim().toUpperCase() != 'PATIENT') {
      errorMessage = 'Only a patient account can pay for an appointment.';
      _notify();
      return;
    }

    isInitializing = true;
    errorMessage = null;
    actionMessage = null;
    _notify();
    try {
      final dueAt = view!.payment!.dueAt.toUtc();
      var intent = await _intentStore.read(
        appointmentId: appointmentId,
        accountUserId: session.user.id,
        now: _now(),
      );
      intent ??= PaymentCheckoutIntent(
        appointmentId: appointmentId,
        accountUserId: session.user.id,
        idempotencyKey: _keyFactory.create(),
        createdAt: _now().toUtc(),
        expiresAt: dueAt,
      );
      await _intentStore.save(intent);

      final checkout = await _repository.initializeCheckout(
        appointmentId: appointmentId,
        idempotencyKey: intent.idempotencyKey,
      );
      if (_disposed) {
        return;
      }
      if (checkout.status == AppointmentPaymentStatus.succeeded) {
        await _intentStore.clear();
        actionMessage =
            'Payment was received. Refreshing the consultation status.';
        await load(refreshProvider: true);
        return;
      }
      final uri = checkout.authorizationUrl;
      if (!isApprovedCheckoutUri(uri)) {
        errorMessage =
            'The secure payment page could not be verified. Please retry.';
        return;
      }
      final opened = await _launcher.open(uri!);
      if (!opened) {
        errorMessage = 'Could not open the secure payment page.';
        return;
      }
      awaitingBrowserReturn = true;
      actionMessage =
          'Complete payment in the secure browser, then return to CareNet.';
    } catch (error) {
      if (!_disposed) {
        errorMessage = _safePaymentError(error);
        if (error is AuthFailure && error.statusCode == 404) {
          await _intentStore.clear();
        }
        if (error is AuthFailure && error.statusCode == 409) {
          await load(refreshProvider: true);
        }
      }
    } finally {
      if (!_disposed) {
        isInitializing = false;
        _notify();
      }
    }
  }

  Future<void> onAppResumed() async {
    if (!awaitingBrowserReturn || isInitializing) {
      return;
    }
    await load(refreshProvider: true);
  }

  bool _isTerminal(AppointmentPaymentStatus? status) {
    return status == AppointmentPaymentStatus.succeeded ||
        status == AppointmentPaymentStatus.expired ||
        status == AppointmentPaymentStatus.refunded ||
        status == AppointmentPaymentStatus.reversed ||
        status == AppointmentPaymentStatus.reviewRequired;
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

String _safePaymentError(Object error) {
  if (error is! AuthFailure) {
    return 'Payment status could not be updated. Please try again.';
  }
  return switch (error.statusCode) {
    401 => 'Your session has expired. Please sign in again.',
    403 => 'This account is not allowed to make this payment.',
    404 => 'This appointment is no longer available for payment.',
    409 => 'Payment state changed. Review the refreshed appointment.',
    _ => switch (error.type) {
      AuthFailureType.network || AuthFailureType.server =>
        'The payment result is uncertain. Retry with the same payment attempt.',
      _ => error.message,
    },
  };
}
