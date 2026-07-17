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
  }) : _config = config,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignInConfig _config;
  final GoogleSignIn _googleSignIn;
  Future<void>? _initializeFuture;

  @override
  bool get isConfigured => _config.isConfigured;

  @override
  Future<String> signInIdToken() async {
    if (!_config.isConfigured) {
      throw const AuthFailure(
        type: AuthFailureType.missingConfiguration,
        message: 'Google sign-in is not configured yet.',
      );
    }

    try {
      await _initialize();
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
    return _initializeFuture ??= _googleSignIn.initialize(
      serverClientId: _config.serverClientId.trim(),
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
