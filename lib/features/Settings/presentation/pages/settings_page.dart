import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/features/Settings/presentation/widgets/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is not part of this ticket yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsInfoCard(
            icon: Icons.shield_outlined,
            accentColor: AppColors.primaryBlue6,
            backgroundColor: AppColors.blue02,
            title: 'Settings & Privacy',
            description:
                'Manage your notifications, privacy controls, and account access from one place.',
          ),
          SizedBox(height: 24.h),
          const SettingsSectionTitle(title: 'Preferences'),
          SizedBox(height: 12.h),
          SettingsNavigationTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle:
                'Control reminders, message alerts, and in-app activity updates.',
            onTap: () => _showComingSoon(context, 'Notifications settings'),
          ),
          SizedBox(height: 12.h),
          SettingsNavigationTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy & safety',
            subtitle:
                'Review data visibility, profile controls, and security preferences.',
            onTap: () => _showComingSoon(context, 'Privacy & safety'),
          ),
          SizedBox(height: 12.h),
          SettingsNavigationTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle:
                'Find guidance for account access, security, and support requests.',
            onTap: () => _showComingSoon(context, 'Help & support'),
          ),
          SizedBox(height: 24.h),
          const SettingsSectionTitle(title: 'Account actions'),
          SizedBox(height: 12.h),
          SettingsNavigationTile(
            icon: Icons.pause_circle_outline_rounded,
            title: 'Deactivate account',
            subtitle:
                'Temporarily disable your account while keeping your information available when you return.',
            destructive: true,
            onTap:
                () => Navigator.pushNamed(context, RouteName.deactivateAccount),
          ),
          SizedBox(height: 12.h),
          SettingsNavigationTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete account',
            subtitle:
                'Permanently remove your account and start the final account deletion review.',
            destructive: true,
            onTap: () => Navigator.pushNamed(context, RouteName.deleteAccount),
          ),
        ],
      ),
    );
  }
}
