import 'package:app_t/features/Authentication/data/services/session_refresh_coordinator.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

import '../../domain/entities/messaging_realtime_session.dart';

abstract class MessagingRealtimeSessionProvider {
  Future<MessagingRealtimeCredentials?> read();

  Future<MessagingRealtimeCredentials?> refresh(
    MessagingRealtimeCredentials expected,
  );
}

class StoredMessagingRealtimeSessionProvider
    implements MessagingRealtimeSessionProvider {
  StoredMessagingRealtimeSessionProvider({
    required SessionRefreshCoordinator coordinator,
  }) : _coordinator = coordinator;

  final SessionRefreshCoordinator _coordinator;

  MessagingRealtimeCredentials? _credentials(SessionSnapshot snapshot) {
    final session = snapshot.session;
    if (session.user.status != 'ACTIVE') return null;
    final credentials = MessagingRealtimeCredentials(
      identity: MessagingRealtimeIdentity(
        userId: session.user.id,
        generation: snapshot.generation,
        role: session.user.role,
      ),
      accessToken: session.accessToken,
    );
    return credentials.isUsable ? credentials : null;
  }

  @override
  Future<MessagingRealtimeCredentials?> read() async {
    try {
      return _credentials(await _coordinator.requireSnapshot());
    } on AuthFailure catch (failure) {
      if (failure.statusCode == 401) return null;
      rethrow;
    }
  }

  @override
  Future<MessagingRealtimeCredentials?> refresh(
    MessagingRealtimeCredentials expected,
  ) async {
    try {
      final snapshot = await _coordinator.requireSnapshot();
      final current = _credentials(snapshot);
      if (current == null || !current.identity.matches(expected.identity)) {
        return null;
      }
      if (current.accessToken != expected.accessToken) return current;
      await _coordinator.refresh(
        expected: snapshot.session,
        expectedSnapshot: snapshot,
      );
      final latest = await read();
      return latest != null && latest.identity.matches(expected.identity)
          ? latest
          : null;
    } on AuthFailure catch (failure) {
      if (failure.statusCode == 401) return null;
      if (failure.type == AuthFailureType.network) rethrow;
      // A coordinator race can reject before returning refreshed credentials.
      final latest = await read();
      if (latest == null || !latest.identity.matches(expected.identity)) {
        return null;
      }
      rethrow;
    }
  }
}
