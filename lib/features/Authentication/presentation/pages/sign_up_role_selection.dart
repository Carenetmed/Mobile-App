import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/tokens/carenet_colors.dart';
import 'package:app_t/features/Authentication/data/repositories/auth_repository.dart';
import 'package:app_t/features/Authentication/data/services/google_sign_in_provider.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_up_arguments.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/presentation/services/booking_resume_navigator.dart';
import 'package:app_t/features/Onboarding/domain/services/onboarding_readiness_route_resolver.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpRoleSelectionPage extends StatefulWidget {
  const SignUpRoleSelectionPage({
    super.key,
    this.initialEmail,
    this.googleSignUp = false,
    this.passwordSignUp = false,
    this.authRepository,
    this.googleIdTokenProvider,
    this.onboardingRepository,
  });

  final String? initialEmail;
  final bool googleSignUp;
  final bool passwordSignUp;
  final AuthRepository? authRepository;
  final GoogleIdTokenProvider? googleIdTokenProvider;
  final OnboardingRepository? onboardingRepository;

  @override
  State<SignUpRoleSelectionPage> createState() =>
      _SignUpRoleSelectionPageState();
}

class _SignUpRoleSelectionPageState extends State<SignUpRoleSelectionPage> {
  SignUpRole? _selectedRole;
  bool _isSubmitting = false;
  bool _checkingBookingIntent = true;
  bool _bookingPatientOnly = false;
  String? _error;

  AuthRepository get _authRepository =>
      widget.authRepository ?? sl<AuthRepository>();

  GoogleIdTokenProvider get _googleIdTokenProvider =>
      widget.googleIdTokenProvider ?? sl<GoogleIdTokenProvider>();

  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();

  static const _routeResolver = OnboardingReadinessRouteResolver();

  @override
  void initState() {
    super.initState();
    _loadBookingBoundary();
  }

  Future<void> _loadBookingBoundary() async {
    final pending = await BookingResumeNavigator.hasPendingIntent();
    if (!mounted) {
      return;
    }
    setState(() {
      _bookingPatientOnly = pending;
      _checkingBookingIntent = false;
    });
  }

  bool get _passwordSignUpFlow =>
      widget.passwordSignUp ||
      (widget.initialEmail != null && !widget.googleSignUp);

  void _selectRole(SignUpRole role) {
    if (_passwordSignUpFlow) {
      _continueWithEmail(role);
      return;
    }

    if (widget.googleSignUp) {
      _continueWithGoogle(role);
      return;
    }

    setState(() {
      _selectedRole = role;
      _error = null;
    });
  }

  void _continueWithEmail(SignUpRole role) {
    Navigator.pushNamed(
      context,
      RouteName.finishSignUp,
      arguments: FinishSignUpArgs(
        initialEmail: widget.initialEmail,
        role: role,
        onboardingRepository: widget.onboardingRepository,
      ),
    );
  }

  Future<void> _continueWithGoogle(SignUpRole role) async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final idToken = await _googleIdTokenProvider.signInIdToken();
      await _authRepository.googleSignIn(
        idToken: idToken,
        role: role.backendValue,
      );
      if (!mounted) {
        return;
      }
      final routeName = await _resolveNextRoute(role);
      if (!mounted) {
        return;
      }
      await BookingResumeNavigator.afterAuthentication(
        context,
        fallbackRoute: routeName,
      );
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = failure.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Google sign-up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<String> _resolveNextRoute(SignUpRole role) async {
    try {
      final readiness = await _onboardingRepository.accountReadiness();
      return _routeResolver.resolve(
        readiness: readiness,
        fallbackRole: role.backendValue,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. We could not check the next setup step. Please continue setup.',
            ),
          ),
        );
      }
      return _routeResolver.fallbackForRole(role.backendValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = _selectedRole;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: REdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: selectedRole == null ? 'Back' : 'Change account type',
                onPressed:
                    selectedRole == null
                        ? () => Navigator.of(context).maybePop()
                        : () => setState(() {
                          _selectedRole = null;
                          _error = null;
                        }),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              SizedBox(height: 16.h),
              if (_checkingBookingIntent)
                const Center(child: CircularProgressIndicator())
              else if (_bookingPatientOnly && selectedRole == null)
                _PatientBookingRoleStep(
                  isSubmitting: _isSubmitting,
                  error: _error,
                  onContinue: () => _selectRole(SignUpRole.patient),
                )
              else if (selectedRole == null)
                _RoleStep(
                  isSubmitting: _isSubmitting,
                  error: _error,
                  googleSignUp: widget.googleSignUp,
                  onRoleSelected: _selectRole,
                )
              else
                _MethodStep(
                  role: selectedRole,
                  isSubmitting: _isSubmitting,
                  googleEnabled: _googleIdTokenProvider.isConfigured,
                  error: _error,
                  onChangeRole:
                      () => setState(() {
                        _selectedRole = null;
                        _error = null;
                      }),
                  onEmail: () => _continueWithEmail(selectedRole),
                  onGoogle: () => _continueWithGoogle(selectedRole),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientBookingRoleStep extends StatelessWidget {
  const _PatientBookingRoleStep({
    required this.isSubmitting,
    required this.error,
    required this.onContinue,
  });

  final bool isSubmitting;
  final String? error;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallLabel(label: 'Appointment request'),
        SizedBox(height: 10.h),
        Text('Create a patient account', style: _titleStyle()),
        SizedBox(height: 10.h),
        Text(
          'Appointment requests require a patient account. Your selected '
          'professional and time will remain saved while you finish setup.',
          style: _bodyStyle(),
        ),
        SizedBox(height: 24.h),
        if (error != null) ...[
          _InlineError(message: error!),
          SizedBox(height: 14.h),
        ],
        _RoleCard(
          icon: Icons.favorite_border_rounded,
          title: 'Patient',
          subtitle:
              'Continue with the patient account required for this appointment request.',
          badge: 'Required',
          onTap: isSubmitting ? null : onContinue,
        ),
      ],
    );
  }
}

class _RoleStep extends StatelessWidget {
  const _RoleStep({
    required this.isSubmitting,
    required this.error,
    required this.googleSignUp,
    required this.onRoleSelected,
  });

  final bool isSubmitting;
  final String? error;
  final bool googleSignUp;
  final ValueChanged<SignUpRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallLabel(label: 'Create account'),
        SizedBox(height: 10.h),
        Text('How will you use CareNet?', style: _titleStyle()),
        SizedBox(height: 10.h),
        Text(
          googleSignUp
              ? 'Choose the CareNet account type for this Google sign-up. Profile setup still happens after account creation.'
              : 'Choose this first so CareNet asks only the questions that belong to your care path.',
          style: _bodyStyle(),
        ),
        SizedBox(height: 28.h),
        if (error != null) ...[
          _InlineError(message: error!),
          SizedBox(height: 14.h),
        ],
        _RoleCard(
          icon: Icons.favorite_border_rounded,
          title: 'Patient',
          subtitle:
              'Find verified care, book appointments, and manage your care profile when needed.',
          badge: 'Fast setup',
          onTap: isSubmitting ? null : () => onRoleSelected(SignUpRole.patient),
        ),
        SizedBox(height: 14.h),
        _RoleCard(
          icon: Icons.medical_services_outlined,
          title: 'Medical professional',
          subtitle:
              'Apply for profile review, submit credentials, and use professional tools after approval.',
          badge: 'Verification required',
          onTap:
              isSubmitting
                  ? null
                  : () => onRoleSelected(SignUpRole.professional),
        ),
        SizedBox(height: 30.h),
        CarenetButton(
          label: 'Already have an account? Sign in',
          type: CarenetButtonType.outline,
          onPressed: () => Navigator.pushNamed(context, RouteName.signInEmail),
        ),
      ],
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.role,
    required this.isSubmitting,
    required this.googleEnabled,
    required this.error,
    required this.onChangeRole,
    required this.onEmail,
    required this.onGoogle,
  });

  final SignUpRole role;
  final bool isSubmitting;
  final bool googleEnabled;
  final String? error;
  final VoidCallback onChangeRole;
  final VoidCallback onEmail;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SmallLabel(label: 'Signup method'),
        SizedBox(height: 10.h),
        Text(
          'Create your ${role.title.toLowerCase()} account',
          style: _titleStyle(),
        ),
        SizedBox(height: 12.h),
        _SelectedRolePill(role: role, onChangeRole: onChangeRole),
        SizedBox(height: 20.h),
        Text(
          'Your signup method creates the secure account only. CareNet will ask role-specific profile details after this step.',
          style: _bodyStyle(),
        ),
        SizedBox(height: 22.h),
        if (error != null) ...[
          _InlineError(message: error!),
          SizedBox(height: 14.h),
        ],
        _MethodCard(
          assetPath: AssetsIcon.google,
          title:
              isSubmitting ? 'Connecting to Google...' : 'Continue with Google',
          subtitle:
              googleEnabled
                  ? 'Use a verified Google identity. CareNet profile fields are still entered separately.'
                  : 'Google sign-up needs provider configuration before it can be used.',
          onTap: isSubmitting || !googleEnabled ? null : onGoogle,
        ),
        SizedBox(height: 12.h),
        _MethodCard(
          icon: Icons.mail_outline_rounded,
          title: 'Continue with email',
          subtitle: 'Create an account with email and password.',
          onTap: isSubmitting ? null : onEmail,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      enabled: onTap != null,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconTile(icon: icon),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title, style: _cardTitleStyle()),
                    _Badge(label: badge),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(subtitle, style: _cardBodyStyle()),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF155E63),
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.assetPath,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return _BaseCard(
      enabled: enabled,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MethodIcon(icon: icon, assetPath: assetPath, enabled: enabled),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _cardTitleStyle().copyWith(
                    color:
                        enabled
                            ? const Color(0xFF102A2A)
                            : CarenetColors.neutral400,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  subtitle,
                  style: _cardBodyStyle().copyWith(
                    color:
                        enabled
                            ? CarenetColors.neutral500
                            : CarenetColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.enabled, required this.child, this.onTap});

  final bool enabled;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Ink(
            width: double.infinity,
            padding: REdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color:
                    enabled
                        ? const Color(0xFFD8E9E6)
                        : CarenetColors.neutral200,
              ),
              boxShadow:
                  enabled
                      ? [
                        BoxShadow(
                          color: const Color(
                            0xFF155E63,
                          ).withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ]
                      : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4F1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: const Color(0xFF155E63), size: 22.sp),
    );
  }
}

class _MethodIcon extends StatelessWidget {
  const _MethodIcon({this.icon, this.assetPath, required this.enabled});

  final IconData? icon;
  final String? assetPath;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final child =
        assetPath != null
            ? SvgImage(imgName: assetPath!)
            : Icon(
              icon,
              color:
                  enabled ? const Color(0xFF155E63) : CarenetColors.neutral400,
              size: 21.sp,
            );

    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFE5F4F1) : CarenetColors.neutral100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: REdgeInsets.all(assetPath != null ? 9 : 0),
      child: Center(child: child),
    );
  }
}

class _SelectedRolePill extends StatelessWidget {
  const _SelectedRolePill({required this.role, required this.onChangeRole});

  final SignUpRole role;
  final VoidCallback onChangeRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4F1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            role == SignUpRole.professional
                ? Icons.medical_services_outlined
                : Icons.favorite_border_rounded,
            color: const Color(0xFF155E63),
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${role.title} account selected',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF155E63),
              ),
            ),
          ),
          TextButton(
            onPressed: onChangeRole,
            child: Text(
              'Change',
              style: TextStyle(
                fontFamily: AppFonts.montserrat,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF155E63),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontFamily: AppFonts.montserrat,
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF155E63),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF18794E),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CarenetColors.error200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: AppFonts.montserrat,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: CarenetColors.error100,
        ),
      ),
    );
  }
}

TextStyle _titleStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 27.sp,
    height: 1.16,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF102A2A),
  );
}

TextStyle _bodyStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 14.sp,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: CarenetColors.neutral500,
  );
}

TextStyle _cardTitleStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 15.sp,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF102A2A),
  );
}

TextStyle _cardBodyStyle() {
  return TextStyle(
    fontFamily: AppFonts.montserrat,
    fontSize: 12.sp,
    height: 1.38,
    fontWeight: FontWeight.w500,
    color: CarenetColors.neutral500,
  );
}
