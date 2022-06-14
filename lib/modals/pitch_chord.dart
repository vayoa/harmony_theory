import 'package:tonic/tonic.dart';

import '../extensions/chord_extension.dart';
import '../extensions/pitch_extension.dart';
import 'theory_base/generic_chord.dart';
import 'theory_base/scale_degree/scale_degree_chord.dart';

/// Our implementation of a regular chord (built of [Pitch]...), with possible
/// inversions.
class PitchChord extends GenericChord<Pitch> {
  static final Pattern chordNamePattern =
      RegExp(r"^([a-gA-G],*'*[#b♯♭𝄪𝄫]*)\s*(.*)$");

  PitchChord({required ChordPattern pattern, required Pitch root})
      : super(pattern, root);

  factory PitchChord.parse(String name) {
    name = name.replaceAll('b', '♭').replaceAll('#', '♯');
    final match = chordNamePattern.matchAsPrefix(name);
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
    return PitchChord(
      pattern: ChordPattern.parse(pattern),
      root: Pitch.parse(pitch),
    );
  }

  @override
  List<Pitch> get patternMapped =>
      pattern.intervals.map((interval) => root + interval).toList();

  List<Pitch> get pitches => patternMapped;

  @override
  GenericChord addSeventh({HarmonicFunction? harmonicFunction}) {
    // TODO: implement addSeventh
    throw UnimplementedError();
  }

  @override
  String get rootString => root.commonName;

  @override
  String get patternString => pattern.abbr == 'min7' ? 'm7' : pattern.abbr;

  @override
  bool operator ==(Object other) {
    if (!identical(this, other) || other is! PitchChord) {
      return false;
    }
    PitchChord chord = other;
    Pitch oRoot = chord.root;
    if (root.accidentalSemitones == oRoot.accidentalSemitones &&
        (root.diatonicSemitones % 12) == (oRoot.diatonicSemitones % 12)) {
      return pattern.equals(chord.pattern);
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
