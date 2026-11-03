import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';

enum VerificationStorageFailureReason { expiredCapability, other }

class VerificationStorageFailure extends AuthFailure {
  const VerificationStorageFailure({required this.reason, super.statusCode})
    : super(
        type: AuthFailureType.network,
        message: 'Could not upload the document. Please try again.',
      );

  final VerificationStorageFailureReason reason;
}
