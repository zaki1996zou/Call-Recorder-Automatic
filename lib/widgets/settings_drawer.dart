import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/theme/app_colors.dart';
import '../features/info/about_screen.dart';
import '../features/info/privacy_policy_screen.dart';
import '../features/info/recording_consent_screen.dart';
import '../l10n/locale_scope.dart';
import '../services/ad_consent_service.dart';
import '../services/app_preferences_service.dart';
import '../services/interstitial_ad_gate_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/drawer_icon.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({
    super.key,
    this.onRecordingModeChanged,
  });

  final ValueChanged<RecordingModePreference>? onRecordingModeChanged;

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final _preferences = AppPreferencesService();
  RecordingModePreference _recordingMode = RecordingModePreference.manual;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final mode = await _preferences.getRecordingMode();
    if (mounted) {
      setState(() {
        _recordingMode = mode;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Drawer(
      width: 320,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeader(),
            _buildInfoBanner(l10n.drawerSafetyBanner),
            _sectionTitle(l10n.settings),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.mic,
                accent: DrawerIconAccent.green,
              ),
              title: l10n.recordingMode,
              subtitle: _isLoading
                  ? l10n.loading
                  : l10n.recordingModeLabel(_recordingMode),
              onTap: _showRecordingModePicker,
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.keyboard_voice,
                accent: DrawerIconAccent.green,
              ),
              title: l10n.audioSource,
              subtitle: l10n.microphone,
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(icon: Icons.graphic_eq),
              title: l10n.audioChannel,
              subtitle: l10n.mono,
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(icon: Icons.equalizer),
              title: l10n.audioRate,
              subtitle: '44100 Hz',
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(icon: Icons.graphic_eq),
              title: l10n.audioBitrate,
              subtitle: '128 Kbps',
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.privacy_tip_outlined,
                accent: DrawerIconAccent.purple,
              ),
              title: l10n.privacyPolicy,
              onTap: () => _openScreen(const PrivacyPolicyScreen()),
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.verified_user_outlined,
                accent: DrawerIconAccent.purple,
              ),
              title: l10n.recordingConsent,
              onTap: () => _openScreen(const RecordingConsentScreen()),
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.info_outline,
                accent: DrawerIconAccent.purple,
              ),
              title: l10n.about,
              onTap: () => _openScreen(const AboutScreen()),
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.star_rate_outlined,
                accent: DrawerIconAccent.purple,
              ),
              title: l10n.rateFiveStars,
              onTap: _showRatingPlaceholder,
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.ads_click_outlined,
                accent: DrawerIconAccent.purple,
              ),
              title: l10n.adPrivacySettings,
              onTap: _showAdPrivacyOptions,
            ),
            _SettingsTile(
              leading: const DrawerBrandIcon(
                icon: Icons.share_outlined,
                accent: DrawerIconAccent.purple,
              ),
              title: l10n.share,
              onTap: _shareApp,
            ),
          ],
        ),
      ),
    );
  }

  void _openScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showRatingPlaceholder() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.ratingUnavailable)),
    );
  }

  Future<void> _showAdPrivacyOptions() async {
    Navigator.pop(context);
    await AdConsentService.instance.showPrivacyOptionsForm();
  }

  Future<void> _shareApp() async {
    final shareText = context.l10n.shareAppText;
    Navigator.pop(context);
    InterstitialAdGateService.instance.runBeforeShare(() async {
      await SharePlus.instance.share(
        ShareParams(text: shareText),
      );
    });
  }

  Future<void> _showRecordingModePicker() async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<RecordingModePreference>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: RecordingModePreference.values
                  .map(
                    (mode) => ListTile(
                      minVerticalPadding: 12,
                      title: Text(
                        l10n.recordingModeLabel(mode),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                      trailing: mode == _recordingMode
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, mode),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      await _preferences.setRecordingMode(selected);
      setState(() => _recordingMode = selected);
      widget.onRecordingModeChanged?.call(selected);
    }
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: AppLogo(size: 96)),
    );
  }

  Widget _buildInfoBanner(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.infoBannerBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.infoBannerBorder),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 12,
      minLeadingWidth: 36,
      leading: leading,
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.visible,
            ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: AppColors.iconMuted)
          : null,
      onTap: onTap,
    );
  }
}
