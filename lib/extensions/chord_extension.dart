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

  bool get hasMinor3rd =>
      intervals.length >= 2 && intervals[1].equals(Interval.m3);

  static ChordPattern fromFullName(String fullName) =>
      chordPatternSpecs[fullName]!;

  static final Map<String, ChordPattern> chordPatternSpecs = {
    'Major': ChordPattern.parse('Major'),
    'Minor': ChordPattern.parse('Minor'),
    'Augmented': ChordPattern.parse('Augmented'),
    'Diminished': ChordPattern.parse('Diminished'),
    'Sus2': ChordPattern.parse('Sus2'),
    'Sus4': ChordPattern.parse('Sus4'),
    'Dominant 7th': ChordPattern.parse('Dominant 7th'),
    'Augmented 7th': ChordPattern.parse('Augmented 7th'),
    'Diminished 7th': ChordPattern.parse('Diminished 7th'),
    'Major 7th': ChordPattern.parse('Major 7th'),
    'Minor 7th': ChordPattern.parse('Minor 7th'),
    'Dominant 7♭5': ChordPattern.parse('Dominant 7♭5'),
    'Minor 7th ♭5': ChordPattern.parse('Minor 7th ♭5'),
    'Diminished Maj 7th': ChordPattern.parse('Diminished Maj 7th'),
    'Minor-Major 7th': ChordPattern.parse('Minor-Major 7th'),
    '6th': ChordPattern.parse('6th'),
    'Minor 6th': ChordPattern.parse('Minor 6th'),
  };
}

extension ChordExtension on Chord {
  String get commonName {
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

  static final Pattern cordNamePattern =
      RegExp(r"^([a-gA-G],*'*[#b♯♭𝄪𝄫]*)\s*(.*)$");

  static Chord parse(String name) {
    name = name.replaceAll('b', '♭').replaceAll('#', '♯');
    final match = cordNamePattern.matchAsPrefix(name);
    if (match == null) throw FormatException("invalid Chord name: $name");
    String pitch = match[1]!;
    String pattern = match[2]!;
    switch (pattern) {
      case 'm7':
        pattern = 'min7';
        break;
      case '7':
        pattern = 'dom7';
        break;
    }
    return ChordPattern.parse(pattern).at(Pitch.parse(pitch));
  }
}
