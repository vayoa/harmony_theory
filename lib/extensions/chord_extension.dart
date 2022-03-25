import 'package:thoery_test/extensions/interval_extension.dart';
import 'package:thoery_test/extensions/pitch_extension.dart';
import 'package:tonic/tonic.dart';

extension ChordPatternExtension on ChordPattern {
  equals(Object? other) {
    if (other is ChordPattern) {
      if (name == other.name && fullName == other.fullName) return true;
      if (intervals.length == other.intervals.length) {
        for (int i = 0; i < intervals.length; i++) {
          if (!intervals[i].equals(other.intervals[i])) return false;
        }
        return true;
      }
    }
    return false;
  }
}

extension ChordExtension on Chord {
  String getCommonName() {
    String abbr = pattern.abbr;
    if (abbr == 'min7') abbr = 'm7';
    return root.commonName + abbr;
  }

  equals(Object? other) {
    if (other is! Chord) return false;
    Chord chord = other;
    Pitch oRoot = chord.root;
    if (root.accidentalSemitones == oRoot.accidentalSemitones &&
        (root.diatonicSemitones % 12) == (oRoot.diatonicSemitones % 12)) {
      return pattern.equals(chord.pattern);
    }
    return false;
  }

  static Chord parse(String name) =>
      Chord.parse(name.replaceFirst(RegExp(r'm7$'), 'min7').replaceFirstMapped(
          RegExp(r'^([A-G]b?)7$'), (match) => match.group(1)! + 'dom7'));
}
