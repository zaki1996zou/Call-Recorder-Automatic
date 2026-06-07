import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/locale_scope.dart';
import '../../services/interstitial_ad_gate_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/legal_safety_content.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: GradientAppBar(
        title: l10n.privacyPolicy,
        leadingIcon: Icons.arrow_back,
        onMenuTap: () => InterstitialAdGateService.instance.runBeforeBack(
          () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.privacyPolicy,
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
            l10n.privacyIntro,
            style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
          ),
          ...LegalSafetyContent.standardFooter(context),
        ],
      ),
    );
  }
}
