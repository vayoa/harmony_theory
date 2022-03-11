import 'package:tonic/tonic.dart';

extension ChordExtension on Chord {
  String getCommonName() {
    String abbr = pattern.abbr;
    if (abbr == 'min7') abbr = 'm7';
    return root.pitchClass.toString() + abbr;
  }

  equals(Object? other) {
    if (Object is! Chord) return false;
    Chord chord = other as Chord;
    Pitch oRoot = chord.root;
    return pattern.intervals == chord.pattern.intervals &&
        root.accidentalSemitones == oRoot.accidentalSemitones &&
        root.diatonicSemitones % 12 == oRoot.diatonicSemitones % 12;
  }
}
