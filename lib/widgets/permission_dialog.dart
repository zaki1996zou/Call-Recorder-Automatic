import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/locale_scope.dart';
import '../../services/interstitial_ad_gate_service.dart';
import '../../services/microphone_service.dart';

/// Shows a pre-request dialog, then triggers the native microphone permission.
/// Returns `true` when microphone access is granted.
Future<bool> showMicrophonePermissionDialog(
  BuildContext context,
  MicrophoneService microphoneService,
) async {
  final l10n = context.l10n;

  if (await microphoneService.hasPermission) return true;
  if (!context.mounted) return false;

  final shouldRequest = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(l10n.micRequired),
        content: Text(l10n.micRequiredBody),
        actions: [
          TextButton(
            onPressed: () => InterstitialAdGateService.instance.runBeforeCancel(
              () => Navigator.pop(dialogContext, false),
            ),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.allow),
          ),
        ],
      );
    },
  );

  if (shouldRequest != true) return false;

  var granted = await microphoneService.ensurePermission();
  if (granted) return true;

  if (await microphoneService.isPermanentlyDenied()) {
    await microphoneService.openSettings();
    granted = await microphoneService.hasPermission;
  }

  return granted;
}

Future<bool> showDeleteRecordingDialog(BuildContext context) async {
  final l10n = context.l10n;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(l10n.deleteRecordingTitle),
        content: Text(l10n.deleteRecordingBody),
        actions: [
          TextButton(
            onPressed: () => InterstitialAdGateService.instance.runBeforeCancel(
              () => Navigator.pop(dialogContext, false),
            ),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.confirm),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
