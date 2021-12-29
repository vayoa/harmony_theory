import 'package:tonic/tonic.dart';

extension ChordExtension on Chord {
  String getCommonName() {
    String abbr = pattern.abbr;
    if (abbr == 'min7') abbr = '7';
    return root.pitchClass.toString() + abbr;
  }

  equals(Chord other) {
    if (pitches.length != other.pitches.length) return false;
    for (int i = 0; i < pitches.length; i++) {
      if (pitches[i].midiNumber != other.pitches[i].midiNumber) return false;
    }
    return true;
  }
}
