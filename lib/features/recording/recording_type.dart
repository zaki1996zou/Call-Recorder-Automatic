enum RecordingType {
  meeting,
  incomingNote,
  outgoingNote,
  voiceNote;

  static RecordingType? fromName(String name) {
    for (final type in RecordingType.values) {
      if (type.name == name) return type;
    }
    return null;
  }
}
