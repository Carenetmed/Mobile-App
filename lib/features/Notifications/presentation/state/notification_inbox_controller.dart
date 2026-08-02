import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/notification_models.dart';
import 'notification_coordinator.dart';

String safeNotificationFailure(Object error) {
  if (error is! AuthFailure) {
    return 'Notifications are unavailable. Please try again.';
  }
  return switch (error.statusCode) {
    401 => 'Your session has expired. Please sign in again.',
    403 => 'This account cannot perform that notification action.',
    404 => 'This notification is no longer available.',
    _ => error.message,
  };
}

class NotificationInboxController extends ChangeNotifier {
  NotificationInboxController({
    required NotificationRepository repository,
    required NotificationCoordinator coordinator,
  }) : _repository = repository,
       _coordinator = coordinator;

  final NotificationRepository _repository;
  final NotificationCoordinator _coordinator;

  List<CareNotification> items = const <CareNotification>[];
  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isMutating = false;
  String? errorMessage;
  String? _nextCursor;
  bool hasMore = false;
  Future<void>? _activeLoad;
  Future<void>? _activePage;
  bool _disposed = false;
  int _generation = 0;

  Future<void> load({bool refresh = false}) {
    final active = _activeLoad;
    if (active != null) return active;
    final future = _load(refresh: refresh);
    _activeLoad = future;
    return future.whenComplete(() {
      if (identical(_activeLoad, future)) _activeLoad = null;
    });
  }

  Future<void> _load({required bool refresh}) async {
    final generation = ++_generation;
    final hadData = items.isNotEmpty;
    isLoading = !hadData;
    isRefreshing = hadData;
    errorMessage = null;
    _notify();
    try {
      final page = await _repository.notifications();
      if (!_accept(generation)) return;
      items = List<CareNotification>.unmodifiable(page.items);
      _nextCursor = page.nextCursor;
      hasMore = page.hasMore && page.nextCursor != null;
      await _coordinator.refreshUnreadCount();
    } catch (error) {
      if (_accept(generation)) errorMessage = safeNotificationFailure(error);
    } finally {
      if (_accept(generation)) {
        isLoading = false;
        isRefreshing = false;
        _notify();
      }
    }
  }

  Future<void> loadMore() {
    final active = _activePage;
    if (active != null) return active;
    final cursor = _nextCursor;
    if (!hasMore || cursor == null) return Future<void>.value();
    final future = _loadMore(cursor);
    _activePage = future;
    return future.whenComplete(() {
      if (identical(_activePage, future)) _activePage = null;
    });
  }

  Future<void> _loadMore(String cursor) async {
    isLoadingMore = true;
    errorMessage = null;
    _notify();
    try {
      final page = await _repository.notifications(cursor: cursor);
      if (_disposed || cursor != _nextCursor) return;
      final byId = <String, CareNotification>{
        for (final item in items) item.id: item,
        for (final item in page.items) item.id: item,
      };
      items = List<CareNotification>.unmodifiable(byId.values);
      _nextCursor = page.nextCursor;
      hasMore = page.hasMore && page.nextCursor != null;
    } catch (error) {
      if (!_disposed) errorMessage = safeNotificationFailure(error);
    } finally {
      if (!_disposed) {
        isLoadingMore = false;
        _notify();
      }
    }
  }

  Future<void> open(CareNotification notification) async {
    if (isMutating) return;
    isMutating = true;
    errorMessage = null;
    _notify();
    try {
      if (!notification.isRead) {
        final readAt = await _repository.markRead(notification.id);
        items = List<CareNotification>.unmodifiable(
          items
              .map(
                (item) =>
                    item.id == notification.id ? item.markRead(readAt) : item,
              )
              .toList(growable: false),
        );
      }
      await _coordinator.refreshUnreadCount();
      await _coordinator.handleTap(notification.id);
    } catch (error) {
      errorMessage = safeNotificationFailure(error);
    } finally {
      if (!_disposed) {
        isMutating = false;
        _notify();
      }
    }
  }

  Future<void> markAllRead() async {
    if (isMutating || items.every((item) => item.isRead)) return;
    isMutating = true;
    errorMessage = null;
    _notify();
    try {
      await _repository.markAllRead();
      final readAt = DateTime.now().toUtc();
      items = List<CareNotification>.unmodifiable(
        items.map((item) => item.isRead ? item : item.markRead(readAt)),
      );
      await _coordinator.refreshUnreadCount();
    } catch (error) {
      errorMessage = safeNotificationFailure(error);
    } finally {
      if (!_disposed) {
        isMutating = false;
        _notify();
      }
    }
  }

  bool _accept(int generation) => !_disposed && generation == _generation;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

class NotificationPreferencesController extends ChangeNotifier {
  NotificationPreferencesController({
    required NotificationRepository repository,
  }) : _repository = repository;

  final NotificationRepository _repository;
  List<NotificationPreference> preferences = const <NotificationPreference>[];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  bool _disposed = false;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      preferences = List<NotificationPreference>.unmodifiable(
        await _repository.preferences(),
      );
    } catch (error) {
      errorMessage = safeNotificationFailure(error);
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> update(
    NotificationCategory category, {
    bool? pushEnabled,
    bool? emailEnabled,
  }) async {
    if (isSaving) return;
    final previous = preferences;
    final changed = previous
        .map(
          (item) =>
              item.category == category
                  ? item.copyWith(
                    pushEnabled: pushEnabled,
                    emailEnabled: emailEnabled,
                  )
                  : item,
        )
        .toList(growable: false);
    preferences = List<NotificationPreference>.unmodifiable(changed);
    isSaving = true;
    errorMessage = null;
    _notify();
    try {
      preferences = List<NotificationPreference>.unmodifiable(
        await _repository.updatePreferences(changed),
      );
    } catch (error) {
      preferences = previous;
      errorMessage = safeNotificationFailure(error);
    } finally {
      isSaving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
