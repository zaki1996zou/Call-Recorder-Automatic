import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/locale_scope.dart';
import '../../services/app_open_ad_service.dart';
import '../../services/interstitial_ad_gate_service.dart';
import '../../services/recording_storage_service.dart';
import '../../widgets/gradient_app_bar.dart';
import 'recording_type.dart';

class RecordingSessionResult {
  RecordingSessionResult({
    required this.filePath,
    required this.duration,
    required this.type,
  });

  final String filePath;
  final Duration duration;
  final RecordingType type;
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key, required this.type});

  final RecordingType type;

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final _recorder = AudioRecorder();
  final _storage = RecordingStorageService();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRecording = false;
  bool _isBusy = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    AppOpenAdService.instance.suppressed = true;
  }

  @override
  void dispose() {
    AppOpenAdService.instance.suppressed = false;
    _timer?.cancel();
    unawaited(_recorder.stop());
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isBusy) return;
    if (_isRecording) {
      await _stopRecording();
      return;
    }
    await _startRecording();
  }

  Future<void> _startRecording() async {
    setState(() => _isBusy = true);
    try {
      if (!await _recorder.hasPermission()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.micPermissionShort)),
        );
        return;
      }

      final path = await _storage.createRecordingPath();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
        _filePath = path;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordingStartFailed)),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _isBusy = true);
    _timer?.cancel();

    try {
      await _recorder.stop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.recordingStopFailed)),
        );
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isBusy = false;
        });
      }
    }

    if (!mounted) return;

    final path = _filePath;
    if (path == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final fileExists = await _storage.fileExists(path);
    if (!mounted) return;

    if (!fileExists || _elapsed.inSeconds < 1) {
      await _storage.deleteFile(path);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.recordingTooShort)),
      );
      return;
    }

    Navigator.pop(
      context,
      RecordingSessionResult(
        filePath: path,
        duration: _elapsed,
        type: widget.type,
      ),
    );
  }

  Future<bool> _confirmLeaveWhileRecording() async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.recordingInProgress),
          content: Text(l10n.stopAndLeave),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.continueAction),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.leave),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleBackNavigation() async {
    InterstitialAdGateService.instance.runBeforeBack(_performBackNavigation);
  }

  Future<void> _performBackNavigation() async {
    if (!_isRecording) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final shouldLeave = await _confirmLeaveWhileRecording();
    if (!shouldLeave || !mounted) return;

    _timer?.cancel();
    await _recorder.stop();
    if (_filePath != null) {
      await _storage.deleteFile(_filePath!);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screenTitle = l10n.recordingTypeTitle(widget.type);

    return PopScope(
      canPop: !_isRecording,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        appBar: GradientAppBar(
          title: screenTitle,
          leadingIcon: Icons.arrow_back,
          onMenuTap: _handleBackNavigation,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _isRecording ? 120 : 100,
                height: _isRecording ? 120 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                color: _isRecording
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.borderLight,
                border: Border.all(
                  color: _isRecording ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.mic,
                  size: 52,
                color: _isRecording
                    ? AppColors.primary
                    : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                screenTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _formatElapsed(_elapsed),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.consentBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.consentBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.consentBeforeRecord,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _isRecording
                        ? AppColors.error
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isBusy ? null : _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                  label: Text(_isRecording ? l10n.stop : l10n.start),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatElapsed(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
