import 'package:thoery_test/extensions/interval_extension.dart';
import 'package:tonic/tonic.dart';

extension ChordExtension on Chord {
  String getCommonName() {
    String abbr = pattern.abbr;
    if (abbr == 'min7') abbr = 'm7';
    return root.pitchClass.toString() + abbr;
  }

  equals(Object? other) {
    if (other is! Chord) return false;
    Chord chord = other;
    Pitch oRoot = chord.root;
    if (intervals.length != chord.intervals.length) return false;
    for (int i = 0; i < intervals.length; i++) {
      if (!intervals[i].equals(chord.intervals[i])) return false;
    }
    return root.accidentalSemitones == oRoot.accidentalSemitones &&
        (root.diatonicSemitones % 12) == (oRoot.diatonicSemitones % 12);
  }
}
