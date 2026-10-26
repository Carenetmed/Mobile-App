import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_t/core/config/messaging_realtime_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/messaging_realtime_session.dart';
import 'messaging_realtime_session_provider.dart';

export '../../domain/entities/messaging_realtime_session.dart';

class MessagingRealtimeHint {
  const MessagingRealtimeHint({
    required this.type,
    required this.conversationId,
    this.sequence,
  });
  final String type;
  final String conversationId;
  final BigInt? sequence;
}

abstract class MessagingRealtimeConnection {
  Stream<MessagingRealtimeHint> get hints;
  Stream<bool> get connectionState;
  Future<void> start(MessagingRealtimeIdentity identity);
  Future<void> suspend();
  Future<void> resume();
  Future<void> dispose();
}

class MessagingRealtimeClient implements MessagingRealtimeConnection {
  MessagingRealtimeClient({
    required MessagingRealtimeConfig config,
    required MessagingRealtimeSessionProvider sessions,
    WebSocketChannel Function(Uri uri)? channelFactory,
    Duration initialReconnectDelay = const Duration(seconds: 1),
    Duration maximumReconnectDelay = const Duration(seconds: 30),
    Duration connectionTimeout = const Duration(seconds: 10),
    Duration acknowledgementTimeout = const Duration(seconds: 10),
    Duration sessionTimeout = const Duration(seconds: 5),
    Duration closeTimeout = const Duration(seconds: 2),
    Duration sessionCheckInterval = const Duration(seconds: 10),
    Random? random,
  }) : _config = config,
       _sessions = sessions,
       _channelFactory = channelFactory ?? WebSocketChannel.connect,
       _initialReconnectDelay = initialReconnectDelay,
       _maximumReconnectDelay = maximumReconnectDelay,
       _connectionTimeout = connectionTimeout,
       _acknowledgementTimeout = acknowledgementTimeout,
       _sessionTimeout = sessionTimeout,
       _closeTimeout = closeTimeout,
       _sessionCheckInterval = sessionCheckInterval,
       _random = random ?? Random() {
    for (final value in <Duration>[
      initialReconnectDelay,
      maximumReconnectDelay,
      connectionTimeout,
      acknowledgementTimeout,
      sessionTimeout,
      closeTimeout,
      sessionCheckInterval,
    ]) {
      if (value <= Duration.zero) {
        throw ArgumentError('Realtime deadlines must be positive.');
      }
    }
  }

  final MessagingRealtimeConfig _config;
  final MessagingRealtimeSessionProvider _sessions;
  final WebSocketChannel Function(Uri uri) _channelFactory;
  final Duration _initialReconnectDelay, _maximumReconnectDelay;
  final Duration _connectionTimeout, _acknowledgementTimeout, _sessionTimeout;
  final Duration _closeTimeout, _sessionCheckInterval;
  final Random _random;
  final _hints = StreamController<MessagingRealtimeHint>.broadcast();
  final _states = StreamController<bool>.broadcast();
  MessagingRealtimeIdentity? _owner;
  _RealtimeAttempt? _attempt;
  Future<void>? _connecting, _closing, _refreshing;
  Timer? _reconnectTimer;
  bool _disposed = false, _suspended = false;
  bool? _lastState;
  int _ownerVersion = 0, _retries = 0;

  @override
  Stream<MessagingRealtimeHint> get hints => _hints.stream;
  @override
  Stream<bool> get connectionState => _states.stream;
  Uri? get endpoint => _config.endpoint;

  @override
  Future<void> start(MessagingRealtimeIdentity identity) {
    if (_disposed) return Future<void>.value();
    if (_owner?.matches(identity) != true) {
      _ownerVersion++;
      _owner = identity.isSupported ? identity : null;
      _retries = 0;
      _cancelReconnect();
      final old = _attempt;
      if (old != null) _retire(old);
      _emit(false);
    }
    return _connect();
  }

  bool _owns(_RealtimeAttempt attempt) =>
      !_disposed &&
      !_suspended &&
      !attempt.retired &&
      identical(_attempt, attempt) &&
      attempt.version == _ownerVersion &&
      _owner?.matches(attempt.owner) == true;

  void _emit(bool state) {
    if (!_disposed && !_states.isClosed && _lastState != state) {
      _lastState = state;
      _states.add(state);
    }
  }

  Future<void> _connect() {
    final active = _connecting;
    if (active != null) return active;
    if (_disposed ||
        _suspended ||
        _refreshing != null ||
        _owner == null ||
        _attempt != null ||
        endpoint == null) {
      if (endpoint == null) _emit(false);
      return Future<void>.value();
    }
    final owner = _owner!;
    final version = _ownerVersion;
    final task = _performConnect(owner, version);
    _connecting = task;
    return task.whenComplete(() {
      if (identical(_connecting, task)) _connecting = null;
      if (_attempt == null) _scheduleReconnect();
    });
  }

  Future<void> _performConnect(
    MessagingRealtimeIdentity owner,
    int version,
  ) async {
    final closing = _closing;
    if (closing != null) await closing;
    if (_disposed ||
        _suspended ||
        version != _ownerVersion ||
        _owner?.matches(owner) != true) {
      return;
    }
    final attempt = _RealtimeAttempt(owner, version);
    _attempt = attempt;
    _emit(false);
    try {
      final credentials = await _readCurrent(attempt);
      if (!_owns(attempt) || credentials == null) return;
      final channel = _channelFactory(endpoint!);
      attempt.channel = channel;
      await _wait(attempt, channel.ready, _connectionTimeout);
      final latest = await _readCurrent(attempt);
      if (!_owns(attempt) || latest == null) {
        return;
      }
      attempt.credentials = latest;
      attempt.subscription = channel.stream.listen(
        (dynamic frame) => unawaited(_onFrame(attempt, frame)),
        onError: (Object _) => _disconnect(attempt),
        onDone: () => _disconnect(attempt),
        cancelOnError: true,
      );
      attempt.acknowledgement = Timer(
        _acknowledgementTimeout,
        () => _disconnect(attempt),
      );
      channel.sink.add(
        jsonEncode(<String, Object>{
          'type': 'auth',
          'accessToken': latest.accessToken,
          'protocolVersion': 1,
        }),
      );
    } catch (_) {
      if (_owns(attempt)) _disconnect(attempt);
    }
  }

  Future<MessagingRealtimeCredentials?> _readCurrent(_RealtimeAttempt attempt) {
    final active = attempt.reading;
    if (active != null) return active;
    final task = _readOwned(attempt);
    attempt.reading = task;
    unawaited(
      task.then<void>(
        (_) {
          if (identical(attempt.reading, task)) attempt.reading = null;
        },
        onError: (Object _, StackTrace __) {
          if (identical(attempt.reading, task)) attempt.reading = null;
        },
      ),
    );
    return task;
  }

  Future<MessagingRealtimeCredentials?> _readOwned(
    _RealtimeAttempt attempt,
  ) async {
    final current = await _wait(attempt, _sessions.read(), _sessionTimeout);
    if (!_owns(attempt)) return null;
    if (current == null ||
        !current.isUsable ||
        !current.identity.matches(attempt.owner)) {
      _owner = null;
      _ownerVersion++;
      _cancelReconnect();
      _disconnect(attempt);
      return null;
    }
    return current;
  }

  Future<void> _onFrame(_RealtimeAttempt attempt, Object? frame) async {
    if (!_owns(attempt) ||
        attempt.renewing ||
        frame is! String ||
        utf8.encode(frame).length > 8192) {
      return;
    }
    Map<String, dynamic> decoded;
    try {
      final value = jsonDecode(frame);
      if (value is! Map<String, dynamic> || value['protocolVersion'] != 1) {
        return;
      }
      decoded = value;
    } catch (_) {
      return;
    }
    if (++attempt.pendingFrames > 32) {
      attempt.pendingFrames--;
      _disconnect(attempt);
      return;
    }
    try {
      if (decoded['eventType'] == 'auth.expiring') {
        attempt.renewing = true;
        _emit(false);
        await _renew(attempt);
        return;
      }
      final current = await _readCurrent(attempt);
      if (current == null || !_owns(attempt) || attempt.renewing) return;
      final type = decoded['eventType'];
      if (type == 'auth.accepted') {
        if (!attempt.authenticated) {
          attempt.authenticated = true;
          attempt.acknowledgement?.cancel();
          _retries = 0;
          attempt.ownerCheck = Timer.periodic(_sessionCheckInterval, (_) {
            unawaited(_checkOwner(attempt));
          });
          _emit(true);
        }
        return;
      }
      if (!attempt.authenticated ||
          type is! String ||
          !const <String>{
            'message.created',
            'conversation.read_advanced',
            'conversation.state_changed',
          }.contains(type)) {
        return;
      }
      final conversationId = decoded['conversationId'];
      if (conversationId is! String || conversationId.trim().isEmpty) return;
      _hints.add(
        MessagingRealtimeHint(
          type: type,
          conversationId: conversationId,
          sequence:
              decoded['sequence'] is String
                  ? BigInt.tryParse(decoded['sequence'] as String)
                  : null,
        ),
      );
    } catch (_) {
      if (_owns(attempt)) _disconnect(attempt);
    } finally {
      attempt.pendingFrames--;
    }
  }

  Future<void> _checkOwner(_RealtimeAttempt attempt) async {
    if (!_owns(attempt)) return;
    try {
      await _readCurrent(attempt);
    } catch (_) {
      if (_owns(attempt)) _disconnect(attempt);
    }
  }

  Future<void> _renew(_RealtimeAttempt attempt) async {
    if (_refreshing != null || !_owns(attempt)) return;
    final task = _performRenew(attempt);
    _refreshing = task;
    try {
      await task;
    } finally {
      if (identical(_refreshing, task)) _refreshing = null;
      _scheduleReconnect();
    }
  }

  Future<void> _performRenew(_RealtimeAttempt attempt) async {
    try {
      final current = await _readCurrent(attempt);
      if (current == null || !_owns(attempt)) return;
      final expected = attempt.credentials ?? current;
      final version = _ownerVersion;
      await _retire(attempt);
      if (_disposed ||
          _suspended ||
          version != _ownerVersion ||
          _owner?.matches(expected.identity) != true) {
        return;
      }
      // Bound this socket's wait without cancelling shared session persistence.
      final refreshed = await _sessions
          .refresh(expected)
          .timeout(_sessionTimeout);
      if (_disposed || _suspended || version != _ownerVersion) return;
      if (refreshed == null ||
          !refreshed.isUsable ||
          _owner?.matches(refreshed.identity) != true) {
        _owner = null;
        _ownerVersion++;
      }
    } catch (_) {
      if (_owns(attempt)) _disconnect(attempt);
    }
  }

  Future<T> _wait<T>(
    _RealtimeAttempt attempt,
    Future<T> operation,
    Duration duration,
  ) {
    final result = Completer<T>();
    late final Timer timer;
    late final void Function() cancel;
    void finish(void Function() complete) {
      timer.cancel();
      attempt.waiters.remove(cancel);
      if (!result.isCompleted) complete();
    }

    cancel = () => finish(() => result.completeError(const _RetiredAttempt()));
    timer = Timer(
      duration,
      () => finish(
        () => result.completeError(TimeoutException('Realtime deadline')),
      ),
    );
    attempt.waiters.add(cancel);
    operation.then<void>(
      (value) => finish(() => result.complete(value)),
      onError:
          (Object error, StackTrace stack) =>
              finish(() => result.completeError(error, stack)),
    );
    if (attempt.retired) cancel();
    return result.future;
  }

  void _disconnect(_RealtimeAttempt attempt) {
    if (!identical(_attempt, attempt) || attempt.retired) return;
    _retire(attempt);
    _emit(false);
    _scheduleReconnect();
  }

  Future<void> _retire(_RealtimeAttempt attempt) {
    final active = attempt.closing;
    if (active != null) return active;
    attempt.retired = true;
    if (identical(_attempt, attempt)) _attempt = null;
    attempt.acknowledgement?.cancel();
    attempt.ownerCheck?.cancel();
    for (final cancel in attempt.waiters.toList()) {
      cancel();
    }
    Future<void> cancelSubscription() async {
      try {
        await attempt.subscription?.cancel().timeout(_closeTimeout);
      } catch (_) {}
    }

    Future<void> closeChannel() async {
      try {
        await attempt.channel?.sink.close().timeout(_closeTimeout);
      } catch (_) {}
    }

    final task = Future.wait<void>(<Future<void>>[
      cancelSubscription(),
      closeChannel(),
    ]).then<void>((_) {});
    attempt.closing = task;
    final combined = Future.wait<void>(<Future<void>>[
      if (_closing != null) _closing!,
      task,
    ]).then<void>((_) {});
    _closing = combined;
    unawaited(
      combined.whenComplete(() {
        if (identical(_closing, combined)) _closing = null;
      }),
    );
    return task;
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _scheduleReconnect() {
    if (_disposed ||
        _suspended ||
        _owner == null ||
        _refreshing != null ||
        endpoint == null ||
        _attempt != null ||
        _reconnectTimer != null) {
      return;
    }
    final exponent = min(_retries++, 6);
    final ms = min(
      _initialReconnectDelay.inMilliseconds * (1 << exponent),
      _maximumReconnectDelay.inMilliseconds,
    );
    final jitter = (ms * .2 * _random.nextDouble()).round();
    _reconnectTimer = Timer(Duration(milliseconds: ms + jitter), () {
      _reconnectTimer = null;
      unawaited(_connect());
    });
  }

  @override
  Future<void> suspend() async {
    if (_disposed || _suspended) return;
    _suspended = true;
    _ownerVersion++;
    _cancelReconnect();
    final attempt = _attempt;
    _emit(false);
    if (attempt != null) await _retire(attempt);
  }

  @override
  Future<void> resume() {
    if (_disposed) return Future<void>.value();
    _suspended = false;
    return _connect();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _owner = null;
    _ownerVersion++;
    _cancelReconnect();
    final attempt = _attempt;
    if (attempt != null) await _retire(attempt);
    await _closing;
    await Future.wait<void>(<Future<void>>[
      _hints.close(),
      _states.close(),
    ]).timeout(_closeTimeout, onTimeout: () => <void>[]);
  }
}

class _RealtimeAttempt {
  _RealtimeAttempt(this.owner, this.version);
  final MessagingRealtimeIdentity owner;
  final int version;
  final Set<void Function()> waiters = <void Function()>{};
  MessagingRealtimeCredentials? credentials;
  Future<MessagingRealtimeCredentials?>? reading;
  WebSocketChannel? channel;
  StreamSubscription<dynamic>? subscription;
  Future<void>? closing;
  Timer? acknowledgement, ownerCheck;
  bool retired = false, authenticated = false, renewing = false;
  int pendingFrames = 0;
}

class _RetiredAttempt implements Exception {
  const _RetiredAttempt();
}
