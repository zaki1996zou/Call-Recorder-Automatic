import 'package:flutter/foundation.dart';

import '../util/global.dart';
import '../features/recording/recording_type.dart';

/// Rewarded gates. Shows an ad when ready; otherwise [onContinue] runs now.
class RewardedAdGateService {
  RewardedAdGateService._();

  static final RewardedAdGateService instance = RewardedAdGateService._();

  static const saveRegistrationGate = 'save_registration';
  static const editRecordingGate = 'edit_recording';
  static const meetingRecordingGate = 'meeting_recording';
  static const callNoteOutgoingGate = 'call_note_outgoing';
  static const callNoteVoiceGate = 'call_note_voice';
  static const deleteGate = 'delete';
  static const shareGate = 'share';

  final _showing = <String, bool>{};

  void runBefore(String gateId, VoidCallback onContinue) {
    if (_showing[gateId] == true) return;

    if (!gAdsReady || !gAds.hasRewarded) {
      onContinue();
      return;
    }

    _showing[gateId] = true;
    gAds.rewardInstance.showRewardAd(() {
      _showing[gateId] = false;
      onContinue();
    });
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

  void runBeforeDelete(VoidCallback onContinue) {
    runBefore(deleteGate, onContinue);
  }

  void runBeforeShare(VoidCallback onContinue) {
    runBefore(shareGate, onContinue);
  }

  void runBeforeCallNoteType(RecordingType type, VoidCallback onContinue) {
    final gateId = switch (type) {
      RecordingType.outgoingNote => callNoteOutgoingGate,
      RecordingType.voiceNote => callNoteVoiceGate,
      RecordingType.incomingNote || RecordingType.meeting => null,
    };
    if (gateId == null) {
      onContinue();
      return;
    }
    runBefore(gateId, onContinue);
  }
}
