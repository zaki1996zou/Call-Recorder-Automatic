import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/locale_scope.dart';
import '../models/recording_item.dart';
import '../services/app_preferences_service.dart';
import 'disclaimer_card.dart';
import 'empty_list_view.dart';
import 'recording_list_tile.dart';

class RecordingActionsView extends StatelessWidget {
  const RecordingActionsView({
    super.key,
    this.preferredMode,
    required this.recordings,
    required this.onRecordMeeting,
    required this.onRecordCallNote,
    required this.onItemTap,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.onDismissDelete,
    required this.onConfirmDismissDelete,
  });

  final RecordingModePreference? preferredMode;
  final List<RecordingItem> recordings;
  final VoidCallback onRecordMeeting;
  final VoidCallback onRecordCallNote;
  final ValueChanged<RecordingItem> onItemTap;
  final ValueChanged<RecordingItem> onFavoriteToggle;
  final ValueChanged<RecordingItem> onDelete;
  final ValueChanged<RecordingItem> onDismissDelete;
  final Future<bool> Function(RecordingItem item) onConfirmDismissDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final highlightMeeting =
        preferredMode == RecordingModePreference.meeting;
    final highlightCallNote =
        preferredMode == RecordingModePreference.callNote;
    final hasRecordings = recordings.isNotEmpty;
    final title = hasRecordings ? l10n.myRecordings : l10n.emptyList;
    final subtitle = hasRecordings ? null : l10n.emptySubtitle;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        MediaQuery.viewPaddingOf(context).bottom + 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeListHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 28),
          _ActionButton(
            icon: Icons.mic,
            iconColor: AppColors.primary,
            title: l10n.recordMeeting,
            subtitle: l10n.recordMeetingSubtitle,
            highlighted: highlightMeeting,
            defaultBadge: l10n.defaultBadge,
            onTap: onRecordMeeting,
          ),
          const SizedBox(height: 14),
          _ActionButton(
            icon: Icons.phone_in_talk_outlined,
            iconColor: AppColors.brandMaroonLight,
            title: l10n.callNoteAfter,
            subtitle: l10n.callNoteAfterSubtitle,
            highlighted: highlightCallNote,
            defaultBadge: l10n.defaultBadge,
            onTap: onRecordCallNote,
          ),
          if (hasRecordings) ...[
            const SizedBox(height: 20),
            ...recordings.map(
              (item) => Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => onConfirmDismissDelete(item),
                onDismissed: (_) => onDismissDelete(item),
                background: Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.onError,
                  ),
                ),
                child: RecordingListTile(
                  item: item,
                  onTap: () => onItemTap(item),
                  onFavoriteToggle: () => onFavoriteToggle(item),
                  onDelete: () => onDelete(item),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const DisclaimerCard(),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.defaultBadge,
    this.highlighted = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String defaultBadge;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.cardShadow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlighted ? AppColors.primary : AppColors.border,
              width: highlighted ? 2 : 1,
            ),
            color: highlighted ? AppColors.chipBackground : AppColors.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (highlighted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              defaultBadge,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onError,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}
