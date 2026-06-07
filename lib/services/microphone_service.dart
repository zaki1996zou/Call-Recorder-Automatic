import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MicrophoneService {
  /// Uses the same permission path as [AudioRecorder] so checks match recording.
  Future<bool> get hasPermission async {
    final recorder = AudioRecorder();
    try {
      return await recorder.hasPermission(request: false);
    } finally {
      await recorder.dispose();
    }
  }

  Future<bool> ensurePermission() async {
    final recorder = AudioRecorder();
    try {
      return await recorder.hasPermission(request: true);
    } finally {
      await recorder.dispose();
    }
  }

  Future<bool> isPermanentlyDenied() async {
    final current = await Permission.microphone.status;
    return current.isPermanentlyDenied || current.isRestricted;
  }

  Future<void> openSettings() => openAppSettings();
}
