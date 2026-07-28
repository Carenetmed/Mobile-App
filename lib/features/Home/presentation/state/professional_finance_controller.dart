import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/financial_repository.dart';
import '../../domain/entities/consultation_price.dart';
import '../../domain/entities/financial_entities.dart';

class ProfessionalFinanceController extends ChangeNotifier {
  ProfessionalFinanceController({required FinancialRepository repository})
    : _repository = repository;

  final FinancialRepository _repository;

  ConsultationPrice? consultationPrice;
  ProfessionalFinanceSummary? summary;
  ProfessionalPayoutProfile? payoutProfile;
  List<FinanceBank> banks = const <FinanceBank>[];
  BankAccountResolution? pendingResolution;
  bool isLoading = false;
  bool isSavingPrice = false;
  bool isLoadingBanks = false;
  bool isResolving = false;
  bool isConfirming = false;
  bool isDeactivating = false;
  String? errorMessage;
  String? actionMessage;

  Future<void>? _activeLoad;
  Future<void>? _activeMutation;
  int _generation = 0;
  bool _disposed = false;

  Future<void> load() {
    if (_disposed) {
      return Future<void>.value();
    }
    final active = _activeLoad;
    if (active != null) {
      return active;
    }
    final future = _load();
    _activeLoad = future;
    return future.whenComplete(() {
      if (identical(_activeLoad, future)) {
        _activeLoad = null;
      }
    });
  }

  Future<void> _load() async {
    final generation = ++_generation;
    isLoading = summary == null;
    errorMessage = null;
    _notify();
    try {
      final values = await Future.wait<Object?>(<Future<Object?>>[
        _repository.consultationPrice(),
        _repository.financeSummary(),
        _repository.payoutProfile(),
      ]);
      if (!_accept(generation)) {
        return;
      }
      consultationPrice = values[0] as ConsultationPrice?;
      summary = values[1] as ProfessionalFinanceSummary;
      payoutProfile = values[2] as ProfessionalPayoutProfile?;
    } catch (error) {
      if (_accept(generation)) {
        errorMessage = _safeFinanceError(error);
      }
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        _notify();
      }
    }
  }

  Future<void> savePrice(int amountMinor) {
    return _serialize(() async {
      isSavingPrice = true;
      final price = await _repository.updateConsultationPrice(amountMinor);
      if (_disposed) {
        return;
      }
      consultationPrice = price;
      actionMessage = 'Consultation price updated.';
      isSavingPrice = false;
    });
  }

  Future<void> loadBanks() async {
    if (_disposed || isLoadingBanks || banks.isNotEmpty) {
      return;
    }
    isLoadingBanks = true;
    errorMessage = null;
    _notify();
    try {
      final loaded = await _repository.banks();
      if (_disposed) {
        return;
      }
      banks = loaded;
    } catch (error) {
      if (!_disposed) {
        errorMessage = _safeFinanceError(error);
      }
    } finally {
      if (!_disposed) {
        isLoadingBanks = false;
        _notify();
      }
    }
  }

  Future<void> resolveBank({
    required String bankCode,
    required String accountNumber,
  }) {
    return _serialize(() async {
      isResolving = true;
      final resolution = await _repository.resolveBankAccount(
        bankCode: bankCode,
        accountNumber: accountNumber,
      );
      if (_disposed) {
        return;
      }
      pendingResolution = resolution;
      isResolving = false;
    });
  }

  Future<void> confirmBank() {
    final resolution = pendingResolution;
    if (resolution == null) {
      errorMessage = 'Resolve the bank account before confirming it.';
      _notify();
      return Future<void>.value();
    }
    return _serialize(() async {
      isConfirming = true;
      final profile = await _repository.confirmBankAccount(
        resolution.resolutionId,
      );
      if (_disposed) {
        return;
      }
      payoutProfile = profile;
      pendingResolution = null;
      actionMessage = 'Payout account saved for review and cooling.';
      isConfirming = false;
      final loadedSummary = await _repository.financeSummary();
      if (_disposed) {
        return;
      }
      summary = loadedSummary;
    });
  }

  Future<void> deactivatePayoutProfile() {
    return _serialize(() async {
      isDeactivating = true;
      await _repository.deactivatePayoutProfile();
      if (_disposed) {
        return;
      }
      payoutProfile = null;
      pendingResolution = null;
      isDeactivating = false;
      actionMessage = 'Payout account deactivated.';
    });
  }

  void cancelResolution() {
    pendingResolution = null;
    actionMessage = null;
    errorMessage = null;
    _notify();
  }

  Future<void> _serialize(Future<void> Function() action) {
    if (_disposed) {
      return Future<void>.value();
    }
    final active = _activeMutation;
    if (active != null) {
      return active;
    }
    final future = _runMutation(action);
    _activeMutation = future;
    return future.whenComplete(() {
      if (identical(_activeMutation, future)) {
        _activeMutation = null;
      }
    });
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    errorMessage = null;
    actionMessage = null;
    _notify();
    try {
      await action();
    } catch (error) {
      if (!_disposed) {
        errorMessage = _safeFinanceError(error);
        isSavingPrice = false;
        isResolving = false;
        isConfirming = false;
        isDeactivating = false;
      }
    } finally {
      _notify();
    }
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

String _safeFinanceError(Object error) {
  if (error is AuthFailure) {
    return switch (error.statusCode) {
      401 => 'Your session has expired. Please sign in again.',
      403 => 'This account cannot manage professional finances.',
      404 => 'The requested financial record is no longer available.',
      409 => 'The financial state changed. Refresh and try again.',
      _ => error.message,
    };
  }
  return 'Financial information could not be updated. Please try again.';
}
