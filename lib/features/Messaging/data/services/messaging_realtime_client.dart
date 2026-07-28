import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_t/core/config/carenet_api_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  Future<void> start(String accessToken);
  Future<void> dispose();
}

class MessagingRealtimeClient implements MessagingRealtimeConnection {
  MessagingRealtimeClient({
    required CareNetApiConfig config,
    WebSocketChannel Function(Uri uri)? channelFactory,
    Duration initialReconnectDelay = const Duration(seconds: 1),
    Duration maximumReconnectDelay = const Duration(seconds: 30),
    Random? random,
  }) : _config = config,
       _channelFactory = channelFactory ?? WebSocketChannel.connect,
       _initialReconnectDelay = initialReconnectDelay,
       _maximumReconnectDelay = maximumReconnectDelay,
       _random = random ?? Random();

  final CareNetApiConfig _config;
  final WebSocketChannel Function(Uri uri) _channelFactory;
  final Duration _initialReconnectDelay;
  final Duration _maximumReconnectDelay;
  final Random _random;
  final StreamController<MessagingRealtimeHint> _hints =
      StreamController<MessagingRealtimeHint>.broadcast();
  final StreamController<bool> _states = StreamController<bool>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  String? _accessToken;
  bool _disposed = false;
  bool _connecting = false;
  int _attempt = 0;

  @override
  Stream<MessagingRealtimeHint> get hints => _hints.stream;

  @override
  Stream<bool> get connectionState => _states.stream;

  Uri? get endpoint {
    final base = _config.normalizedBaseUrl;
    final parsed = base == null ? null : Uri.tryParse(base);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      return null;
    }
    return parsed.replace(
      scheme: parsed.scheme == 'https' ? 'wss' : 'ws',
      path: '/messaging',
      query: null,
      fragment: null,
    );
  }

  @override
  Future<void> start(String accessToken) async {
    if (_disposed || accessToken.trim().isEmpty) {
      return;
    }
    _accessToken = accessToken;
    await _connect();
  }

  Future<void> _connect() async {
    if (_disposed || _connecting || _channel != null) {
      return;
    }
    final uri = endpoint;
    final token = _accessToken;
    if (uri == null || token == null) {
      return;
    }
    _connecting = true;
    WebSocketChannel? pendingChannel;
    try {
      final channel = _channelFactory(uri);
      pendingChannel = channel;
      await channel.ready.timeout(const Duration(seconds: 10));
      if (_disposed || token != _accessToken) {
        await channel.sink.close();
        return;
      }
      _channel = channel;
      pendingChannel = null;
      _attempt = 0;
      channel.sink.add(
        jsonEncode(<String, dynamic>{'type': 'auth', 'accessToken': token}),
      );
      _states.add(true);
      _subscription = channel.stream.listen(
        _onFrame,
        onError: (_) => _disconnectAndRetry(),
        onDone: _disconnectAndRetry,
        cancelOnError: true,
      );
    } catch (_) {
      await pendingChannel?.sink.close();
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _onFrame(Object? frame) {
    if (_disposed || frame is! String || frame.length > 8192) {
      return;
    }
    try {
      final decoded = jsonDecode(frame);
      if (decoded is! Map<String, dynamic> || decoded['protocolVersion'] != 1) {
        return;
      }
      final type = decoded['eventType'];
      final conversationId = decoded['conversationId'];
      if (type is! String ||
          conversationId is! String ||
          conversationId.trim().isEmpty) {
        return;
      }
      if (!const <String>{
        'message.created',
        'conversation.read_advanced',
        'conversation.state_changed',
      }.contains(type)) {
        return;
      }
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
      // Malformed or unknown hints are deliberately ignored.
    }
  }

  Future<void> _disconnectAndRetry() async {
    if (_disposed) {
      return;
    }
    await _subscription?.cancel();
    _subscription = null;
    final channel = _channel;
    _channel = null;
    await channel?.sink.close();
    _states.add(false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null || _accessToken == null) {
      return;
    }
    _states.add(false);
    final exponent = min(_attempt++, 6);
    final baseMs = _initialReconnectDelay.inMilliseconds * (1 << exponent);
    final bounded = min(baseMs, _maximumReconnectDelay.inMilliseconds);
    final jitter = (bounded * 0.2 * _random.nextDouble()).round();
    _reconnectTimer = Timer(Duration(milliseconds: bounded + jitter), () {
      _reconnectTimer = null;
      _connect();
    });
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _accessToken = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    final channel = _channel;
    _channel = null;
    await channel?.sink.close();
    await _hints.close();
    await _states.close();
  }
}
