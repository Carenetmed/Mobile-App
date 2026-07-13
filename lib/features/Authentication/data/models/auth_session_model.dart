import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.expiresIn,
    required super.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthSessionModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int? ?? 0,
      user: AuthUserModel.fromJson(
        userJson is Map<String, dynamic> ? userJson : <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'user': _userToJson(user),
    };
  }

  Map<String, dynamic> _userToJson(AuthUser user) {
    return <String, dynamic>{
      'id': user.id,
      'email': user.email,
      'role': user.role,
      'status': user.status,
      'emailVerified': user.emailVerified,
    };
  }
}
