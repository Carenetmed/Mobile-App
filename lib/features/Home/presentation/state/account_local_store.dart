import 'package:flutter/foundation.dart';

@immutable
class AccountProfileSnapshot {
  const AccountProfileSnapshot({
    required this.authenticationLabel,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.bio,
    required this.location,
    required this.phoneNumber,
    required this.passwordHint,
    required this.helpLabel,
    required this.isDeactivated,
    required this.deactivationNotice,
  });

  final String authenticationLabel;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String bio;
  final String location;
  final String phoneNumber;
  final String passwordHint;
  final String helpLabel;
  final bool isDeactivated;
  final String? deactivationNotice;
}

class AccountLocalStore {
  AccountLocalStore._();

  static const String _expectedEmail = 'doctor@carenet.app';
  static const String _expectedPhone = '+234 801 234 5678';
  static const String _expectedPassword = 'CareNet@123';

  static final ValueNotifier<AccountProfileSnapshot> snapshot =
      ValueNotifier<AccountProfileSnapshot>(
        const AccountProfileSnapshot(
          authenticationLabel: 'Email + phone login is active',
          firstName: 'Lagbaja',
          lastName: 'Tamedu',
          username: 'lagbaja_carenet',
          email: _expectedEmail,
          bio: 'Husband | Father | Anonymous | Needs help constantly',
          location: 'Epe, Lagos',
          phoneNumber: _expectedPhone,
          passwordHint: 'Last changed locally 14 days ago',
          helpLabel: 'Support and recovery help',
          isDeactivated: false,
          deactivationNotice: null,
        ),
      );

  static bool matchesDeleteConfirmation({
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return email.trim().toLowerCase() == _expectedEmail &&
        phoneNumber.trim() == _expectedPhone &&
        password == _expectedPassword;
  }

  static void deactivateAccount() {
    snapshot.value = AccountProfileSnapshot(
      authenticationLabel: snapshot.value.authenticationLabel,
      firstName: snapshot.value.firstName,
      lastName: snapshot.value.lastName,
      username: snapshot.value.username,
      email: snapshot.value.email,
      bio: snapshot.value.bio,
      location: snapshot.value.location,
      phoneNumber: snapshot.value.phoneNumber,
      passwordHint: snapshot.value.passwordHint,
      helpLabel: snapshot.value.helpLabel,
      isDeactivated: true,
      deactivationNotice:
          'Your account is now deactivated. It will not be visible in search, but you can reactivate it locally from this flow.',
    );
  }

  static void reactivateAccount() {
    snapshot.value = AccountProfileSnapshot(
      authenticationLabel: snapshot.value.authenticationLabel,
      firstName: snapshot.value.firstName,
      lastName: snapshot.value.lastName,
      username: snapshot.value.username,
      email: snapshot.value.email,
      bio: snapshot.value.bio,
      location: snapshot.value.location,
      phoneNumber: snapshot.value.phoneNumber,
      passwordHint: snapshot.value.passwordHint,
      helpLabel: snapshot.value.helpLabel,
      isDeactivated: false,
      deactivationNotice: null,
    );
  }

  static bool isUsernameAvailable(String username) {
    return username.trim().toLowerCase() != 'lagbajatamedu';
  }

  static void updateSettingsProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String bio,
  }) {
    snapshot.value = AccountProfileSnapshot(
      authenticationLabel: snapshot.value.authenticationLabel,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      username: username.trim(),
      email: email.trim(),
      bio: bio.trim(),
      location: snapshot.value.location,
      phoneNumber: snapshot.value.phoneNumber,
      passwordHint: snapshot.value.passwordHint,
      helpLabel: snapshot.value.helpLabel,
      isDeactivated: snapshot.value.isDeactivated,
      deactivationNotice: snapshot.value.deactivationNotice,
    );
  }

  static void reset() {
    snapshot.value = const AccountProfileSnapshot(
      authenticationLabel: 'Email + phone login is active',
      firstName: 'Lagbaja',
      lastName: 'Tamedu',
      username: 'lagbaja_carenet',
      email: _expectedEmail,
      bio: 'Husband | Father | Anonymous | Needs help constantly',
      location: 'Epe, Lagos',
      phoneNumber: _expectedPhone,
      passwordHint: 'Last changed locally 14 days ago',
      helpLabel: 'Support and recovery help',
      isDeactivated: false,
      deactivationNotice: null,
    );
  }
}
