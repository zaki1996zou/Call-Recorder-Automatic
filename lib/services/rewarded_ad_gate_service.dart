import 'package:flutter/foundation.dart';

import '../util/global.dart';
import '../features/recording/recording_type.dart';

/// Rewarded ad gates with independent every-other-attempt counters.
///
/// Pattern per gate: 1st direct, 2nd ad, 3rd direct, 4th ad, ...
/// If the ad fails to load, [onContinue] still runs (no permanent block).
class RewardedAdGateService {
  RewardedAdGateService._();

  static final RewardedAdGateService instance = RewardedAdGateService._();

  static const playbackGate = 'playback';
  static const saveRegistrationGate = 'save_registration';
  static const editRecordingGate = 'edit_recording';
  static const meetingRecordingGate = 'meeting_recording';
  static const callNoteIncomingGate = 'call_note_incoming';
  static const callNoteOutgoingGate = 'call_note_outgoing';
  static const callNoteVoiceGate = 'call_note_voice';

  final _attempts = <String, int>{};
  final _showing = <String, bool>{};

  void runBefore(String gateId, VoidCallback onContinue) {
    if (_showing[gateId] == true) return;

    final count = (_attempts[gateId] ?? 0) + 1;
    _attempts[gateId] = count;

    final showAd = gAdsReady && gAds.hasRewarded && count.isEven;

    if (!showAd) {
      onContinue();
      return;
    }

    _showing[gateId] = true;
    gAds.rewardInstance.showRewardAd(() {
      _showing[gateId] = false;
      onContinue();
    });
  }

  void runBeforePlayback(VoidCallback onContinue) {
    runBefore(playbackGate, onContinue);
  }

  void runBeforeSaveRegistration(VoidCallback onContinue) {
    runBefore(saveRegistrationGate, onContinue);
  }

  void runBeforeEditRecording(VoidCallback onContinue) {
    runBefore(editRecordingGate, onContinue);
  }

  void runBeforeMeetingRecording(VoidCallback onContinue) {
    runBefore(meetingRecordingGate, onContinue);
  }

  void runBeforeCallNoteType(RecordingType type, VoidCallback onContinue) {
    final gateId = switch (type) {
      RecordingType.incomingNote => callNoteIncomingGate,
      RecordingType.outgoingNote => callNoteOutgoingGate,
      RecordingType.voiceNote => callNoteVoiceGate,
      RecordingType.meeting => meetingRecordingGate,
    };
    runBefore(gateId, onContinue);
  }
}
