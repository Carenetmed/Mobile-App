import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_failure.dart';

class GoogleSignInConfig {
  const GoogleSignInConfig({required this.serverClientId});

  static const String serverClientIdEnvironmentKey =
      'GOOGLE_SIGN_IN_SERVER_CLIENT_ID';

  factory GoogleSignInConfig.fromEnvironment() {
    return const GoogleSignInConfig(
      serverClientId: String.fromEnvironment(serverClientIdEnvironmentKey),
    );
  }

  final String serverClientId;

  bool get isConfigured => serverClientId.trim().isNotEmpty;
}

abstract class GoogleIdTokenProvider {
  bool get isConfigured;

  Future<String> signInIdToken();
}

class GoogleSignInIdTokenProvider implements GoogleIdTokenProvider {
  GoogleSignInIdTokenProvider({
    required GoogleSignInConfig config,
    GoogleSignIn? googleSignIn,
    Duration initializationTimeout = const Duration(seconds: 30),
  }) : _config = config,
       _initializationTimeout = initializationTimeout,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignInConfig _config;
  final GoogleSignIn _googleSignIn;
  final Duration _initializationTimeout;
  Future<void>? _initializeFuture;
  Future<String>? _signInFuture;

  @override
  bool get isConfigured => _config.isConfigured;

  @override
  Future<String> signInIdToken() {
    return _signInFuture ??= _signIn().whenComplete(() => _signInFuture = null);
  }

  Future<String> _signIn() async {
    if (!_config.isConfigured) {
      throw const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'Google sign-in is not configured yet.',
      );
    }

    try {
      await _initialize().timeout(_initializationTimeout);
      if (!_googleSignIn.supportsAuthenticate()) {
        throw const AuthFailure(
          type: AuthFailureType.validation,
          message: 'Google sign-in is not available on this platform yet.',
        );
      }

      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.trim().isEmpty) {
        throw const AuthFailure(
          type: AuthFailureType.validation,
          message: 'Google sign-in did not return a usable token.',
        );
      }
      return idToken;
    } on AuthFailure {
      rethrow;
    } on TimeoutException {
      throw const AuthFailure(
        type: AuthFailureType.network,
        message: 'Google sign-in is taking too long. Please try again.',
      );
    } on GoogleSignInException catch (error) {
      throw _mapGoogleFailure(error);
    } catch (_) {
      throw const AuthFailure(
        type: AuthFailureType.unknown,
        message: 'Google sign-in failed. Please try again.',
      );
    }
  }

  Future<void> _initialize() {
    // Keep timed-out initialization in flight, but allow retry after rejection.
    return _initializeFuture ??= _googleSignIn
        .initialize(serverClientId: _config.serverClientId.trim())
        .then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            _initializeFuture = null;
            Error.throwWithStackTrace(error, stackTrace);
          },
        );
  }

  AuthFailure _mapGoogleFailure(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return const AuthFailure(
          type: AuthFailureType.validation,
          message: 'Google sign-in was cancelled.',
        );
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return const AuthFailure(
          type: AuthFailureType.missingConfiguration,
          message: 'Google sign-in is not configured yet.',
        );
      case GoogleSignInExceptionCode.uiUnavailable:
        return const AuthFailure(
          type: AuthFailureType.validation,
          message: 'Google sign-in is not available right now.',
        );
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.userMismatch:
      case GoogleSignInExceptionCode.unknownError:
        return const AuthFailure(
          type: AuthFailureType.unknown,
          message: 'Google sign-in failed. Please try again.',
        );
    }
  }
}
