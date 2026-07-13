import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/account_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountShellPage extends StatelessWidget {
  const AccountShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
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
        child: ValueListenableBuilder<AccountProfileSnapshot>(
          valueListenable: AccountLocalStore.snapshot,
          builder: (context, snapshot, _) {
            return ListView(
              padding: REdgeInsets.all(16.r),
              children: [
                if (snapshot.deactivationNotice != null) ...[
                  Container(
                    margin: REdgeInsets.only(bottom: 16.h),
                    padding: REdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.blue02,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.white04),
                    ),
                    child: Text(
                      snapshot.deactivationNotice!,
                      style: TextStyle(
                        fontSize: FontSizes.footer3,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryBlue5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                _AccountTile(
                  icon: Icons.lock_outline,
                  title: 'Authentication',
                  subtitle: snapshot.authenticationLabel,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteName.changeAuthentication,
                    );
                  },
                ),
                _AccountTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Settings & Profile',
                  subtitle: 'Edit your local account profile details',
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.settings);
                  },
                ),
                _AccountTile(
                  icon: Icons.mail_outline,
                  title: 'Email address',
                  subtitle: snapshot.email,
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.addEmail);
                  },
                ),
                _AccountTile(
                  icon: Icons.phone_android_outlined,
                  title: 'Phone number',
                  subtitle: snapshot.phoneNumber,
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.addPhoneNumber);
                  },
                ),
                _AccountTile(
                  icon: Icons.password_outlined,
                  title: 'Password',
                  subtitle: snapshot.passwordHint,
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.password);
                  },
                ),
                _AccountTile(
                  icon: Icons.info_outline,
                  title: 'Help',
                  subtitle: snapshot.helpLabel,
                  onTap: null,
                ),
                _AccountTile(
                  icon: Icons.delete_outline,
                  title: 'Delete account',
                  subtitle: 'Open the local confirmation flow',
                  onTap: () {
                    Navigator.pushNamed(context, RouteName.deleteAccount);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SettingsProfilePage extends StatefulWidget {
  const SettingsProfilePage({super.key});

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

  @override
  void initState() {
    super.initState();
    final snapshot = AccountLocalStore.snapshot.value;
    _firstNameController = TextEditingController(text: snapshot.firstName);
    _lastNameController = TextEditingController(text: snapshot.lastName);
    _usernameController = TextEditingController(text: snapshot.username);
    _emailController = TextEditingController(text: snapshot.email);
    _bioController = TextEditingController(text: snapshot.bio);
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
      _firstNameError =
          _firstNameController.text.trim().isEmpty
              ? 'First name is required'
              : null;
      _lastNameError =
          _lastNameController.text.trim().isEmpty
              ? 'Last name is required'
              : null;
      _usernameError =
          username.isEmpty
              ? 'Username is required'
              : (!AccountLocalStore.isUsernameAvailable(username)
                  ? 'Username taken'
                  : null);
      _emailError =
          email.isEmpty
              ? 'Enter your email address'
              : (!email.contains('@') ? 'Enter a valid email address' : null);
      _bioError = _bioController.text.trim().isEmpty ? 'Bio is required' : null;
    });
  }

  void _save() {
    _validate();
    if (!_canSave) {
      return;
    }

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
          'Profile changes saved locally. Backend username/email checks can replace this seam later.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AccountLocalStore.snapshot.value;

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
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
                      snapshot.firstName.characters.first,
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
                          '${snapshot.firstName} ${snapshot.lastName}',
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
            CarenetTextField(
              label: 'First Name',
              controller: _firstNameController,
              onChanged: (_) => _validate(),
              validationState:
                  _firstNameError == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _firstNameError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Last Name',
              controller: _lastNameController,
              onChanged: (_) => _validate(),
              validationState:
                  _lastNameError == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _lastNameError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Username',
              controller: _usernameController,
              onChanged: (_) => _validate(),
              validationState:
                  _usernameError == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _usernameError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Email',
              controller: _emailController,
              onChanged: (_) => _validate(),
              validationState:
                  _emailError == null
                      ? CarenetTextFieldValidationState.none
                      : CarenetTextFieldValidationState.invalid,
              errorText: _emailError,
            ),
            SizedBox(height: 14.h),
            CarenetTextField(
              label: 'Bio',
              controller: _bioController,
              onChanged: (_) => _validate(),
              validationState:
                  _bioError == null
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
                    label: 'Save Changes',
                    onPressed: _canSave ? _save : null,
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
      builder:
          (dialogContext) => AlertDialog(
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
              validationState:
                  _emailError == null
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
              validationState:
                  _phoneError == null
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
              validationState:
                  _passwordError == null
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: FontSizes.footer4,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryBlue11,
          ),
        ),
        trailing:
            onTap == null
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
