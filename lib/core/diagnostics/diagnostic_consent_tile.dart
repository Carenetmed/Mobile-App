import 'package:flutter/material.dart';

import '../tokens/carenet_colors.dart';
import 'diagnostic_preferences_controller.dart';

/// The app owns this controller; the account initializes it when opened.
class DiagnosticConsentTile extends StatelessWidget {
  const DiagnosticConsentTile({super.key, required this.controller});

  final DiagnosticPreferencesController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder:
        (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              value: controller.enabled,
              activeThumbColor: CarenetColors.brand,
              title: const Text('Share technical diagnostics'),
              subtitle: Text(
                'Optional technical metadata only, for this sign-in session. '
                'No health information or messages. '
                'Does not include native crash reports.'
                '${controller.busy ? ' Checking preference...' : ''}',
              ),
              onChanged: controller.canChange ? controller.setEnabled : null,
            ),
            if (controller.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Text(controller.message!),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Check diagnostic preference again',
                      onPressed:
                          controller.canRetry ? controller.initialize : null,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
          ],
        ),
  );
}
