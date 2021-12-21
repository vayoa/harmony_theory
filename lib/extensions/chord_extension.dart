import 'package:tonic/tonic.dart';

extension ChordExtension on Chord {
  String getCommonName() {
    return root.pitchClass.toString() + pattern.abbr;
  }

  equals(Chord other) {
    if (pitches.length != other.pitches.length) return false;
    for (int i = 0; i < pitches.length; i++) {
      if (pitches[i].midiNumber != other.pitches[i].midiNumber) return false;
    }
    return true;
  }
}
