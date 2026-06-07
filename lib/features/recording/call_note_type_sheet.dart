import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/locale_scope.dart';
import '../../services/rewarded_ad_gate_service.dart';
import 'recording_type.dart';

Future<RecordingType?> showCallNoteTypeSheet(BuildContext context) {
  return showModalBottomSheet<RecordingType>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      final l10n = context.l10n;

      void selectType(RecordingType type) {
        RewardedAdGateService.instance.runBeforeCallNoteType(
          type,
          () {
            if (context.mounted) Navigator.pop(context, type);
          },
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.callNoteSheetTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.callNoteSheetSubtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.phone_callback,
                title: l10n.recordingTypeIncoming,
                subtitle: l10n.callNoteIncomingSubtitle,
                onTap: () => selectType(RecordingType.incomingNote),
              ),
              _OptionTile(
                icon: Icons.phone_forwarded,
                title: l10n.recordingTypeOutgoing,
                subtitle: l10n.callNoteOutgoingSubtitle,
                onTap: () => selectType(RecordingType.outgoingNote),
              ),
              _OptionTile(
                icon: Icons.note_alt_outlined,
                title: l10n.recordingTypeVoice,
                subtitle: l10n.callNoteVoiceSubtitle,
                onTap: () => selectType(RecordingType.voiceNote),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
      minTileHeight: 56,
      leading: CircleAvatar(
        backgroundColor: AppColors.chipBackground,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
