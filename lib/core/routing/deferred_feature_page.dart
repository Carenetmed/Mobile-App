import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:flutter/material.dart';

class DeferredFeaturePage extends StatelessWidget {
  const DeferredFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        foregroundColor: AppColors.primaryBlue5,
        title: const Text('CareNet'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.health_and_safety_outlined,
                    size: 48,
                    color: AppColors.primaryBlue5,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This feature is not available in CareNet Phase 1.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Return to the healthcare marketplace to find care or manage appointments.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteName.dashboard,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Return home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
