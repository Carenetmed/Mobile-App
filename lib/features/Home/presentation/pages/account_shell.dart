import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/config/carenet_public_links.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/repositories/account_repository.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_user.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/storage/booking_intent_store.dart';
import 'package:app_t/features/Home/data/storage/payment_checkout_intent_store.dart';
import 'package:app_t/features/Home/domain/entities/patient_profile.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountShellPage extends StatefulWidget {
  const AccountShellPage({
    super.key,
    this.authRepository,
    this.accountRepository,
    this.googleIdTokenProvider,
    this.bookingIntentStore,
    this.paymentCheckoutIntentStore,
    this.publicLinkLauncher,
  });

  final AuthRepository? authRepository;
  final AccountRepository? accountRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;
  final BookingIntentStore? bookingIntentStore;
  final PaymentCheckoutIntentStore? paymentCheckoutIntentStore;
  final PublicLinkLauncher? publicLinkLauncher;

  @override
  State<AccountShellPage> createState() => _AccountShellPageState();
}

class _AccountShellPageState extends State<AccountShellPage> {
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  bool _isLoadingCurrentAccount = true;
  bool _accountLoadInFlight = false;
  bool _isLinkingGoogle = false;
  String? _logoutError;
  String? _currentAccountError;
  String? _googleLinkMessage;
  String? _googleLinkError;
  String? _accountDeletionError;
  AuthUser? _currentAccount;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();
  AccountRepository get _accountRepository =>
      widget.accountRepository ?? sl<AccountRepository>();
  GoogleIdTokenProvider? get _googleIdTokenProvider {
    if (widget.googleIdTokenProvider != null) {
      return widget.googleIdTokenProvider;
    }
    if (!sl.isRegistered<GoogleIdTokenProvider>()) {
      return null;
    }
    return sl<GoogleIdTokenProvider>();
  }

  BookingIntentStore? get _bookingIntentStore {
    if (widget.bookingIntentStore != null) {
      return widget.bookingIntentStore;
    }
    return sl.isRegistered<BookingIntentStore>()
        ? sl<BookingIntentStore>()
        : null;
  }

  PaymentCheckoutIntentStore? get _paymentCheckoutIntentStore {
    if (widget.paymentCheckoutIntentStore != null) {
      return widget.paymentCheckoutIntentStore;
    }
    return sl.isRegistered<PaymentCheckoutIntentStore>()
        ? sl<PaymentCheckoutIntentStore>()
        : null;
  }

  Future<void> _openPublicLink(Uri uri) async {
    final launcher = widget.publicLinkLauncher ?? CareNetPublicLinks.launch;
    final opened = await launcher(uri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open this page. Please try again.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentAccount();
  }

  Future<void> _loadCurrentAccount() async {
    if (_accountLoadInFlight) {
      return;
    }
    _accountLoadInFlight = true;
    if (mounted && !_isLoadingCurrentAccount) {
      setState(() {
        _isLoadingCurrentAccount = true;
        _currentAccountError = null;
      });
    }
    if (widget.accountRepository == null &&
        !sl.isRegistered<AccountRepository>()) {
      if (mounted) {
        setState(() {
          _isLoadingCurrentAccount = false;
        });
      }
      _accountLoadInFlight = false;
      return;
    }

    try {
      final account = await _accountRepository.currentAccount();
      if (!mounted) return;
      setState(() {
        _currentAccount = account;
        _currentAccountError = null;
        _isLoadingCurrentAccount = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _currentAccountError = failure.message;
        _isLoadingCurrentAccount = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentAccountError = 'Could not load account details.';
        _isLoadingCurrentAccount = false;
      });
    } finally {
      _accountLoadInFlight = false;
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
      _logoutError = null;
    });

    try {
      await _bookingIntentStore?.clear();
      await _paymentCheckoutIntentStore?.clear();
      await _authRepository.logout();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteName.onboarding, (route) => false);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _logoutError = failure.message;
        _isLoggingOut = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _logoutError = 'Could not log out. Please try again.';
        _isLoggingOut = false;
      });
    }
  }

  Future<void> _linkGoogleAccount() async {
    final provider = _googleIdTokenProvider;
    if (provider == null || !provider.isConfigured) {
      setState(() {
        _googleLinkMessage = null;
        _googleLinkError = 'Google account linking is not configured yet.';
      });
      return;
    }
    if (_isLoadingCurrentAccount || _isLinkingGoogle) {
      return;
    }

    setState(() {
      _isLinkingGoogle = true;
      _googleLinkMessage = null;
      _googleLinkError = null;
    });

    String idToken;
    try {
      idToken = await provider.signInIdToken();
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _googleLinkError = _safeGoogleProviderError(failure);
        _isLinkingGoogle = false;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _googleLinkError = 'Google account linking failed. Please try again.';
        _isLinkingGoogle = false;
      });
      return;
    }

    try {
      await _authRepository.googleLink(idToken: idToken);
      if (!mounted) return;
      setState(() {
        _googleLinkMessage = 'Google account linked.';
        _googleLinkError = null;
        _isLinkingGoogle = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _googleLinkMessage = null;
        _googleLinkError = _safeGoogleBackendLinkError(failure);
        _isLinkingGoogle = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _googleLinkMessage = null;
        _googleLinkError = 'Google account linking failed. Please try again.';
        _isLinkingGoogle = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount || _isLoadingCurrentAccount) return;
    final choice = await showDialog<_AccountDeletionChoice>(
      context: context,
      builder: (_) => _AccountDeletionDialog(
        googleAvailable: _googleIdTokenProvider?.isConfigured ?? false,
      ),
    );
    if (choice == null || !mounted) return;

    setState(() {
      _isDeletingAccount = true;
      _accountDeletionError = null;
    });

    try {
      String? googleIdToken;
      if (choice.useGoogle) {
        googleIdToken = await _googleIdTokenProvider!.signInIdToken();
      }
      final receipt = await _accountRepository.requestAccountDeletion(
        password: choice.password,
        googleIdToken: googleIdToken,
      );
      await _bookingIntentStore?.clear();
      await _paymentCheckoutIntentStore?.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Account deletion requested'),
          content: Text(
            'Your CareNet account is no longer active and all sessions were '
            'signed out. Records that CareNet must retain remain protected '
            'under the applicable retention policy.\n\n'
            'Request recorded ${receipt.deletionRequestedAt.toLocal()}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteName.onboarding, (route) => false);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _accountDeletionError = switch (failure.type) {
          AuthFailureType.unauthorized || AuthFailureType.invalidCredentials =>
            'Your recent authentication was not accepted. Try again.',
          AuthFailureType.validation =>
            'Check the confirmation details and try again.',
          AuthFailureType.forbidden =>
            'This account cannot perform that action.',
          AuthFailureType.missingConfiguration =>
            'Account deletion is not available right now.',
          AuthFailureType.network ||
          AuthFailureType.server ||
          AuthFailureType.unknown =>
            'Account deletion could not be completed. Please try again.',
        };
        _isDeletingAccount = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountDeletionError =
            'Account deletion could not be completed. Please try again.';
        _isDeletingAccount = false;
      });
    }
  }

  String _safeGoogleProviderError(AuthFailure failure) {
    switch (failure.type) {
      case AuthFailureType.forbidden:
        return 'This account cannot link Google identity.';
      case AuthFailureType.missingConfiguration:
        return 'Google account linking is not configured yet.';
      case AuthFailureType.unauthorized:
        return 'Please sign in again.';
      case AuthFailureType.validation:
      case AuthFailureType.invalidCredentials:
      case AuthFailureType.network:
      case AuthFailureType.server:
      case AuthFailureType.unknown:
        return failure.message;
    }
  }

  String _safeGoogleBackendLinkError(AuthFailure failure) {
    switch (failure.type) {
      case AuthFailureType.forbidden:
        return 'This account cannot link Google identity.';
      case AuthFailureType.missingConfiguration:
        return 'Google account linking is not configured yet.';
      case AuthFailureType.unauthorized:
        return 'Please sign in again.';
      case AuthFailureType.validation:
      case AuthFailureType.invalidCredentials:
        return 'This Google account cannot be linked here.';
      case AuthFailureType.network:
      case AuthFailureType.server:
      case AuthFailureType.unknown:
        return 'Google account linking failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            final accountEmail = _currentAccount?.email;
            final authenticationLabel = _isLoadingCurrentAccount
                ? 'Loading account session...'
                : _currentAccount == null
                ? 'Account details unavailable'
                : '${_currentAccount!.role} account - ${_currentAccount!.status.toLowerCase()}';
            final googleProvider = _googleIdTokenProvider;
            final isGoogleConfigured = googleProvider?.isConfigured ?? false;
            final isGoogleLinkStatusLive =
                _isLinkingGoogle ||
                _googleLinkMessage != null ||
                _googleLinkError != null;
            final googleLinkSubtitle = _isLinkingGoogle
                ? 'Linking Google account...'
                : _googleLinkMessage ??
                      _googleLinkError ??
                      (_isLoadingCurrentAccount
                          ? 'Load account before linking Google'
                          : !isGoogleConfigured
                          ? 'Google account linking is not configured yet.'
                          : 'Link Google account');
            final canLinkGoogle =
                !_isLoadingCurrentAccount &&
                !_isLinkingGoogle &&
                isGoogleConfigured;
            final isProfessionalAccount =
                _currentAccount?.role.toUpperCase() == 'PROFESSIONAL';
            final isPatientAccount =
                _currentAccount?.role.toUpperCase() == 'PATIENT';
            return ListView(
              padding: REdgeInsets.all(16.r),
              children: [
                if (_currentAccountError != null) ...[
                  Container(
                    margin: REdgeInsets.only(bottom: 16.h),
                    padding: REdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.blue02,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.white04),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _currentAccountError!,
                            style: TextStyle(
                              fontSize: FontSizes.footer3,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryBlue5,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        OutlinedButton.icon(
                          onPressed:
                              _isLoadingCurrentAccount
                                  ? null
                                  : _loadCurrentAccount,
                          icon:
                              _isLoadingCurrentAccount
                                  ? SizedBox.square(
                                      dimension: 16.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                          label: const Text('Retry account details'),
                        ),
                      ],
                    ),
                  ),
                ],
                _AccountTile(
                  icon: Icons.lock_outline,
                  title: 'Account security',
                  subtitle: authenticationLabel,
                  subtitleLiveRegion: true,
                  onTap: null,
                ),
                _AccountTile(
                  icon: Icons.link_outlined,
                  title: 'Google account',
                  subtitle: googleLinkSubtitle,
                  subtitleLiveRegion: isGoogleLinkStatusLive,
                  onTap: canLinkGoogle ? _linkGoogleAccount : null,
                ),
                if (isProfessionalAccount)
                  _AccountTile(
                    icon: Icons.badge_outlined,
                    title: 'Manage Profile',
                    subtitle: 'Professional profile and verification documents',
                    onTap: () {
                      Navigator.pushNamed(context, RouteName.manageProfile);
                    },
                  ),
                if (isPatientAccount)
                  _AccountTile(
                    icon: Icons.person_outline,
                    title: 'View or edit profile',
                    subtitle: 'Patient profile details used by CareNet',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteName.patientOnboardingSetup,
                      );
                    },
                  ),
                if (isProfessionalAccount)
                  _AccountTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payments & payouts',
                    subtitle:
                        'Consultation price, held earnings and payout account',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteName.professionalFinance,
                      );
                    },
                  ),
                if (isProfessionalAccount)
                  _AccountTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Verification documents',
                    subtitle: 'Upload and review professional documents',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteName.professionalVerificationDocuments,
                      );
                    },
                  ),
                _AccountTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification preferences',
                  subtitle: 'Choose push and email updates by category',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteName.notificationPreferences,
                    );
                  },
                ),
                _AccountTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Support',
                  subtitle: 'Help, safety guidance and contact information',
                  onTap: () => _openPublicLink(CareNetPublicLinks.support),
                ),
                _AccountTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy and legal',
                  subtitle: 'Privacy Policy and Terms of Service',
                  onTap: () => _openPublicLink(CareNetPublicLinks.privacy),
                ),
                _AccountTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Account deletion information',
                  subtitle:
                      'What deletion does and how retained records are handled',
                  onTap: () =>
                      _openPublicLink(CareNetPublicLinks.accountDeletion),
                ),
                _AccountTile(
                  icon: Icons.mail_outline,
                  title: 'Email address',
                  subtitle: accountEmail ?? 'Unavailable',
                  onTap: null,
                ),
                _AccountTile(
                  icon: Icons.logout,
                  title: _isLoggingOut ? 'Logging out...' : 'Log out',
                  subtitle: 'Clear this device session',
                  onTap: _isLoggingOut ? null : _logout,
                ),
                if (_logoutError != null) ...[
                  SizedBox(height: 2.h),
                  Padding(
                    padding: REdgeInsets.only(bottom: 14.h),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _logoutError!,
                        style: TextStyle(
                          fontSize: FontSizes.footer4,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
                _AccountTile(
                  icon: Icons.delete_outline,
                  title: _isDeletingAccount
                      ? 'Requesting account deletion...'
                      : 'Delete account',
                  subtitle:
                      'Requires recent authentication and signs out every session',
                  onTap: _isDeletingAccount ? null : _deleteAccount,
                ),
                if (_accountDeletionError != null)
                  Padding(
                    padding: REdgeInsets.only(bottom: 14.h),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _accountDeletionError!,
                        style: TextStyle(
                          fontSize: FontSizes.footer4,
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountDeletionChoice {
  const _AccountDeletionChoice.password(this.password) : useGoogle = false;
  const _AccountDeletionChoice.google() : password = null, useGoogle = true;

  final String? password;
  final bool useGoogle;
}

class _AccountDeletionDialog extends StatefulWidget {
  const _AccountDeletionDialog({required this.googleAvailable});

  final bool googleAvailable;

  @override
  State<_AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<_AccountDeletionDialog> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool get _confirmed => _confirmationController.text.trim() == 'DELETE';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Delete your CareNet account?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This deactivates your account, revokes every session, and stops '
              'account access. Records CareNet must retain remain protected '
              'under the applicable retention policy.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmationController,
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Type DELETE to confirm',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(labelText: 'Current password'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep account'),
        ),
        if (widget.googleAvailable)
          TextButton(
            onPressed: _confirmed
                ? () => Navigator.of(
                    context,
                  ).pop(const _AccountDeletionChoice.google())
                : null,
            child: const Text('Verify with Google'),
          ),
        FilledButton(
          onPressed: _confirmed && _passwordController.text.isNotEmpty
              ? () => Navigator.of(
                  context,
                ).pop(_AccountDeletionChoice.password(_passwordController.text))
              : null,
          child: const Text('Delete account'),
        ),
      ],
    );
  }
}

class SettingsProfilePage extends StatefulWidget {
  const SettingsProfilePage({super.key, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  State<SettingsProfilePage> createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;

  String? _firstNameError;
  String? _lastNameError;
  String? _usernameError;
  String? _emailError;
  String? _bioError;
  bool _isLoadingPatientProfile = true;
  bool _isSavingPatientName = false;
  String? _patientProfileError;
  String? _patientProfileSaveMessage;
  PatientProfile? _patientProfile;

  ProfileRepository get _profileRepository =>
      widget.profileRepository ?? sl<ProfileRepository>();

  bool get _hasProfileRepository =>
      widget.profileRepository != null || sl.isRegistered<ProfileRepository>();

  @override
  void initState() {
    super.initState();
    final snapshot = AccountLocalStore.snapshot.value;
    _firstNameController = TextEditingController(text: snapshot.firstName);
    _lastNameController = TextEditingController(text: snapshot.lastName);
    _usernameController = TextEditingController(text: snapshot.username);
    _emailController = TextEditingController(text: snapshot.email);
    _bioController = TextEditingController(text: snapshot.bio);
    _loadPatientProfile();
  }

  Future<void> _loadPatientProfile() async {
    if (widget.profileRepository == null &&
        !sl.isRegistered<ProfileRepository>()) {
      setState(() {
        _isLoadingPatientProfile = false;
      });
      return;
    }

    try {
      final profile = await _profileRepository.patientMe();
      if (!mounted) return;
      final nameParts = _splitPatientName(profile?.name);
      setState(() {
        _patientProfile = profile;
        _patientProfileError = null;
        _isLoadingPatientProfile = false;
        if (nameParts != null) {
          _firstNameController.text = nameParts.$1;
          _lastNameController.text = nameParts.$2;
        }
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _patientProfileError = failure.message;
        _isLoadingPatientProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _patientProfileError = 'Could not load patient profile.';
        _isLoadingPatientProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _firstNameError == null &&
      _lastNameError == null &&
      _usernameError == null &&
      _emailError == null &&
      _bioError == null &&
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _bioController.text.trim().isNotEmpty;

  void _validate() {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    setState(() {
      _firstNameError = _firstNameController.text.trim().isEmpty
          ? 'First name is required'
          : null;
      _lastNameError = _lastNameController.text.trim().isEmpty
          ? 'Last name is required'
          : null;
      _usernameError = username.isEmpty
          ? 'Username is required'
          : (!AccountLocalStore.isUsernameAvailable(username)
                ? 'Username taken'
                : null);
      _emailError = email.isEmpty
          ? 'Enter your email address'
          : (!email.contains('@') ? 'Enter a valid email address' : null);
      _bioError = _bioController.text.trim().isEmpty ? 'Bio is required' : null;
    });
  }

  Future<void> _save() async {
    _validate();
    if (!_canSave) {
      return;
    }

    final backendName = [
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');

    setState(() {
      _isSavingPatientName = true;
      _patientProfileError = null;
      _patientProfileSaveMessage = null;
    });

    if (!_hasProfileRepository) {
      _saveLocalProfile();
      return;
    }

    try {
      final updated = await _profileRepository.updatePatientMe(
        name: backendName,
      );
      if (!mounted) return;
      setState(() {
        _patientProfile = updated;
        _isSavingPatientName = false;
        _patientProfileSaveMessage = 'Patient profile name saved.';
      });
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _patientProfileError = failure.message;
        _isSavingPatientName = false;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _patientProfileError = 'Could not save patient profile name.';
        _isSavingPatientName = false;
      });
      return;
    }

    _saveLocalProfile();
  }

  void _saveLocalProfile() {
    AccountLocalStore.updateSettingsProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      bio: _bioController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Patient profile name saved. Username, email, and bio stayed local.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AccountLocalStore.snapshot.value;
    final displayName = _patientProfile?.name.trim().isNotEmpty == true
        ? _patientProfile!.name.trim()
        : '${snapshot.firstName} ${snapshot.lastName}';
    final avatarLetter = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().characters.first;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Settings & Profile',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.all(16.r),
          children: [
            Container(
              padding: REdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.kWhite,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.white04),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 44.r,
                    backgroundColor: AppColors.blue02,
                    child: Text(
                      avatarLetter,
                      style: TextStyle(
                        fontSize: FontSizes.body2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue5,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: FontSizes.body2,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kBlack,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          snapshot.bio,
                          style: TextStyle(
                            fontSize: FontSizes.footer3,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryBlue11,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          snapshot.location,
                          style: TextStyle(
                            fontSize: FontSizes.footer4,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlue5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _PatientProfileReadPanel(
              isLoading: _isLoadingPatientProfile,
              isSaving: _isSavingPatientName,
              error: _patientProfileError,
              successMessage: _patientProfileSaveMessage,
              profile: _patientProfile,
            ),
            SizedBox(height: 20.h),
            CarenetTextField(
              label: 'First Name',
              controller: _firstNameController,
              onChanged: (_) => _validate(),
              validationState: _firstNameError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _firstNameError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Last Name',
              controller: _lastNameController,
              onChanged: (_) => _validate(),
              validationState: _lastNameError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _lastNameError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Username',
              controller: _usernameController,
              onChanged: (_) => _validate(),
              validationState: _usernameError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _usernameError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Email',
              controller: _emailController,
              onChanged: (_) => _validate(),
              validationState: _emailError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _emailError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Bio',
              controller: _bioController,
              onChanged: (_) => _validate(),
              validationState: _bioError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _bioError,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: FontSizes.footer2,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CarenetButton(
                    label: _isSavingPatientName
                        ? 'Saving name...'
                        : 'Save Changes',
                    onPressed: _canSave && !_isSavingPatientName ? _save : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            CarenetButton(
              label: 'Deactivate account',
              onPressed: () {
                AccountLocalStore.deactivateAccount();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account deactivated locally from settings. Backend account state can replace this later.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

(String, String)? _splitPatientName(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return null;
  }
  return (parts.first, parts.skip(1).join(' '));
}

class _PatientProfileReadPanel extends StatelessWidget {
  const _PatientProfileReadPanel({
    required this.isLoading,
    required this.isSaving,
    required this.error,
    required this.successMessage,
    required this.profile,
  });

  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;
  final PatientProfile? profile;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    final rows = <String>[
      if (profile?.name.trim().isNotEmpty == true)
        'Name: ${profile!.name.trim()}',
      if (profile?.age != null) 'Age: ${profile!.age}',
      if (profile?.location?.trim().isNotEmpty == true)
        'Location: ${profile!.location!.trim()}',
    ];
    final message = isLoading
        ? 'Loading patient profile...'
        : isSaving
        ? 'Saving patient profile name...'
        : error != null
        ? error!
        : successMessage != null
        ? successMessage!
        : profile == null
        ? 'Patient profile details are not available yet. You can still manage the account options shown here.'
        : rows.isEmpty
        ? 'No patient profile details are available to show.'
        : rows.join('\n');

    return Container(
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient profile',
            style: TextStyle(
              fontSize: FontSizes.footer2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.35,
            ),
          ),
          if (!isLoading && profile != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Username, email, bio, and security changes still save locally or through their own account routes.',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue5,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _deactivateInstead() {
    AccountLocalStore.deactivateAccount();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.kWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Your account is now deactivated',
          style: TextStyle(
            fontSize: FontSizes.body2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w700,
            color: AppColors.kBlack,
          ),
        ),
        content: Text(
          'Your account will not be visible in search, but you can still reactivate it locally from this slice.',
          style: TextStyle(
            fontSize: FontSizes.footer3,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryBlue11,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              AccountLocalStore.reactivateAccount();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Activate account'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty ? 'Email is required' : null;
      _phoneError = phone.isEmpty ? 'Phone number is required' : null;
      _passwordError = password.isEmpty ? 'Password is required' : null;
    });

    if (_emailError != null || _phoneError != null || _passwordError != null) {
      return;
    }

    if (!AccountLocalStore.matchesDeleteConfirmation(
      email: email,
      phoneNumber: phone,
      password: password,
    )) {
      setState(() {
        _passwordError = 'Entered credentials do not match this local account';
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Delete account is intentionally blocked until backend-backed account removal exists.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Delete this account',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: REdgeInsets.all(16.r),
          children: [
            _WarningPanel(
              title: 'If you delete this account',
              lines: const [
                'The account will be deleted from CareNet and all your devices',
                'Your message history and media will be erased',
                'You will be removed from all your CareNet circles',
                'Your connections and schedules will be erased',
              ],
            ),
            SizedBox(height: 16.h),
            CarenetButton(
              label: 'Deactivate your instead?',
              onPressed: _deactivateInstead,
            ),
            SizedBox(height: 16.h),
            _WarningPanel(
              title: 'To delete your account, confirm your',
              lines: const ['Phone number', 'Email address', 'Password'],
            ),
            SizedBox(height: 16.h),
            CarenetTextField(
              label: 'Enter your email address',
              hintText: 'Enter email',
              controller: _emailController,
              onChanged: (_) => setState(() => _emailError = null),
              validationState: _emailError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _emailError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Enter your phone number',
              hintText: 'Enter phone number',
              controller: _phoneController,
              onChanged: (_) => setState(() => _phoneError = null),
              validationState: _phoneError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _phoneError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Confirm password',
              hintText: 'Enter password',
              controller: _passwordController,
              obscureText: true,
              onChanged: (_) => setState(() => _passwordError = null),
              validationState: _passwordError == null
                  ? CarenetTextFieldValidationState.none
                  : CarenetTextFieldValidationState.invalid,
              errorText: _passwordError,
            ),
            SizedBox(height: 20.h),
            CarenetButton(label: 'Delete account', onPressed: _deleteAccount),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleLiveRegion = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool subtitleLiveRegion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: REdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.kBlack),
        title: Text(
          title,
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w500,
            color: AppColors.kBlack,
          ),
        ),
        subtitle: Semantics(
          liveRegion: subtitleLiveRegion,
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
            ),
          ),
        ),
        trailing: onTap == null
            ? const Icon(Icons.lock_outline, size: 18)
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  const _WarningPanel({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...lines.map(
            (line) => Padding(
              padding: REdgeInsets.only(left: 28.w, bottom: 8.h),
              child: Text(
                '- $line',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.kBlack,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
