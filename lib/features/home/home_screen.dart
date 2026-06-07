import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/recording/call_note_type_sheet.dart';
import '../../features/recording/playback_sheet.dart';
import '../../features/recording/recording_screen.dart';
import '../../features/recording/recording_type.dart';
import '../../features/recording/save_recording_sheet.dart';
import '../../l10n/locale_scope.dart';
import '../../models/recording_filter_tab.dart';
import '../../models/recording_item.dart';
import '../../services/app_preferences_service.dart';
import '../../services/interstitial_ad_gate_service.dart';
import '../../services/microphone_service.dart';
import '../../services/rewarded_ad_gate_service.dart';
import '../../services/recording_storage_service.dart';
import '../../services/recordings_repository.dart';
import '../../widgets/app_banner_ad.dart';
import '../../widgets/empty_list_view.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/permission_dialog.dart';
import '../../widgets/recording_actions_view.dart';
import '../../widgets/recording_list_tile.dart';
import '../../widgets/settings_drawer.dart';

extension RecordingFilterTabUi on RecordingFilterTab {
  String appBarTitle(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case RecordingFilterTab.all:
        return l10n.tabAll;
      case RecordingFilterTab.incoming:
        return l10n.tabIncoming;
      case RecordingFilterTab.outgoing:
        return l10n.tabOutgoing;
      case RecordingFilterTab.favorites:
        return l10n.tabFavorites;
    }
  }

  String navLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case RecordingFilterTab.all:
        return l10n.tabAllNav;
      case RecordingFilterTab.incoming:
        return l10n.tabIncoming;
      case RecordingFilterTab.outgoing:
        return l10n.tabOutgoing;
      case RecordingFilterTab.favorites:
        return l10n.tabFavorites;
    }
  }

  IconData get icon {
    switch (this) {
      case RecordingFilterTab.all:
        return Icons.phone;
      case RecordingFilterTab.incoming:
        return Icons.phone_callback;
      case RecordingFilterTab.outgoing:
        return Icons.phone_forwarded;
      case RecordingFilterTab.favorites:
        return Icons.star;
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _repository = RecordingsRepository();
  final _microphoneService = MicrophoneService();
  final _storageService = RecordingStorageService();
  RecordingFilterTab _currentTab = RecordingFilterTab.all;
  bool _isLoading = true;
  RecordingModePreference _recordingMode = RecordingModePreference.manual;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepositoryChanged);
    _initializeRecordings();
  }

  Future<void> _initializeRecordings() async {
    final mode = await AppPreferencesService().getRecordingMode();
    await _repository.loadRecordings();
    if (mounted) {
      setState(() {
        _recordingMode = mode;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    _repository.dispose();
    super.dispose();
  }

  void _onRepositoryChanged() => setState(() {});

  List<RecordingItem> get _visibleItems => _repository.forTab(_currentTab);

  bool get _isAllTab => _currentTab == RecordingFilterTab.all;

  Future<bool> _ensureMicrophonePermission() async {
    if (await _microphoneService.hasPermission) return true;
    if (!mounted) return false;

    final granted = await showMicrophonePermissionDialog(
      context,
      _microphoneService,
    );
    if (!mounted) return false;

    if (granted) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.micPermissionRequired)),
    );
    return false;
  }

  void _startMeetingRecording() {
    RewardedAdGateService.instance.runBeforeMeetingRecording(
      _continueMeetingRecording,
    );
  }

  Future<void> _continueMeetingRecording() async {
    if (!mounted) return;
    if (!await _ensureMicrophonePermission()) return;
    await _openRecordingFlow(RecordingType.meeting);
  }

  Future<void> _startCallNoteRecording() async {
    final type = await showCallNoteTypeSheet(context);
    if (type == null || !mounted) return;

    if (!await _ensureMicrophonePermission()) return;
    await _openRecordingFlow(type);
  }

  Future<void> _openRecordingFlow(RecordingType type) async {
    final session = await Navigator.push<RecordingSessionResult>(
      context,
      MaterialPageRoute(builder: (_) => RecordingScreen(type: type)),
    );
    if (session == null || !mounted) return;

    final savedItem = await showSaveRecordingSheet(context, session);
    if (!mounted) return;

    if (savedItem == null) {
      await _storageService.deleteFile(session.filePath);
      return;
    }

    final fileExists = await _storageService.fileExists(savedItem.filePath);
    if (!mounted) return;
    if (!fileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.audioSaveFailed)),
      );
      return;
    }

    await _repository.addRecording(savedItem);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.recordingSaved)),
    );
  }

  Future<void> _deleteRecording(RecordingItem item) async {
    InterstitialAdGateService.instance.runBeforeDelete(() {
      _performDeleteRecording(item);
    });
  }

  Future<void> _performDeleteRecording(RecordingItem item) async {
    final deleted = await _repository.deleteRecording(item.id);
    if (!deleted || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.recordingDeleted)),
    );
  }

  Future<void> _confirmAndDelete(RecordingItem item) async {
    InterstitialAdGateService.instance.runBeforeDelete(() {
      _performConfirmAndDelete(item);
    });
  }

  Future<void> _performConfirmAndDelete(RecordingItem item) async {
    final confirmed = await showDeleteRecordingDialog(context);
    if (!confirmed || !mounted) return;

    final deleted = await _repository.deleteRecording(item.id);
    if (!deleted || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.recordingDeleted)),
    );
  }

  Future<bool> _confirmDismissDelete(RecordingItem item) async {
    return showDeleteRecordingDialog(context);
  }

  void _openPlayback(RecordingItem item) {
    RewardedAdGateService.instance.runBeforePlayback(() {
      if (!mounted) return;
      showPlaybackSheet(
        context,
        item: item,
        repository: _repository,
        onDeleted: () => setState(() {}),
        onUpdated: () => setState(() {}),
      );
    });
  }

  void _onRecordingModeChanged(RecordingModePreference mode) {
    setState(() => _recordingMode = mode);
  }

  Widget _buildFilteredTabBody() {
    if (_visibleItems.isEmpty) {
      return EmptyListView(subtitle: context.l10n.emptyCategory);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: _visibleItems.length,
      itemBuilder: (context, index) {
        final item = _visibleItems[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDismissDelete(item),
          onDismissed: (_) => _deleteRecording(item),
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.onError),
          ),
          child: RecordingListTile(
            item: item,
            onTap: () => _openPlayback(item),
            onFavoriteToggle: () => _repository.toggleFavorite(item.id),
            onDelete: () => _confirmAndDelete(item),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_isAllTab) {
      return RecordingActionsView(
        preferredMode: _recordingMode,
        recordings: _visibleItems,
        onRecordMeeting: _startMeetingRecording,
        onRecordCallNote: _startCallNoteRecording,
        onItemTap: _openPlayback,
        onFavoriteToggle: (item) => _repository.toggleFavorite(item.id),
        onDelete: _confirmAndDelete,
        onDismissDelete: _deleteRecording,
        onConfirmDismissDelete: _confirmDismissDelete,
      );
    }

    return _buildFilteredTabBody();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SettingsDrawer(onRecordingModeChanged: _onRecordingModeChanged),
      appBar: GradientAppBar(
        title: _currentTab.appBarTitle(context),
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.appBarForeground),
            tooltip: l10n.language,
            onPressed: () => showLanguageSelector(context),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppBannerAd(),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _currentTab.index,
                onTap: (index) {
                  setState(
                    () => _currentTab = RecordingFilterTab.values[index],
                  );
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.iconMuted,
                selectedFontSize: 11,
                unselectedFontSize: 0,
                showUnselectedLabels: false,
                items: RecordingFilterTab.values
                    .map(
                      (tab) => BottomNavigationBarItem(
                        icon: Icon(tab.icon),
                        activeIcon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tab.icon, size: 26),
                            const SizedBox(height: 2),
                            Text(
                              tab.navLabel(context),
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        label: tab.navLabel(context),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
