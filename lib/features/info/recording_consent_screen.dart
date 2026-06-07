import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/locale_scope.dart';
import '../../services/interstitial_ad_gate_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/legal_safety_content.dart';

class RecordingConsentScreen extends StatelessWidget {
  const RecordingConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: GradientAppBar(
        title: l10n.recordingConsent,
        leadingIcon: Icons.arrow_back,
        onMenuTap: () => InterstitialAdGateService.instance.runBeforeBack(
          () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.recordingConsent,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LegalSafetyContent.safetyBox(context),
          const SizedBox(height: 16),
          Text(
            l10n.consentIntro,
            style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.consentManualStart,
            style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.consentUseFor,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.consentUseBullets,
            style: const TextStyle(height: 1.6, color: AppColors.textSecondary),
          ),
          ...LegalSafetyContent.standardFooter(context),
        ],
      ),
    );
  }
}
