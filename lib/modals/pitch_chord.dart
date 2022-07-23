import 'package:tonic/tonic.dart';

import '../extensions/chord_extension.dart';
import '../extensions/pitch_extension.dart';
import 'theory_base/degree/degree_chord.dart';
import 'theory_base/generic_chord.dart';

/// Our implementation of a regular chord (built of [Pitch]...), with possible
/// inversions.
class PitchChord extends GenericChord<Pitch> {
  // TODO: Improve this regex...
  static final Pattern chordNamePattern = RegExp(
      r"^([a-gA-G],*'*[#b♯♭𝄪𝄫]*)\s*([^\/]*)(\/[a-gA-G],*'*[#b♯♭𝄪𝄫]*)?$");

  PitchChord({
    required ChordPattern pattern,
    required Pitch root,
    Pitch? bass,
  }) : super(
          pattern,
          root,
          bass: bass,
          bassToRoot: bass?.numberlessFrom(root),
        );

  factory PitchChord.parse(String name) {
    name = name.replaceAll('b', '♭').replaceAll('#', '♯');
    final match = chordNamePattern.matchAsPrefix(name);
    if (match == null) throw FormatException("invalid Chord name: $name");
    String pitch = match[1]!;
    String pattern = match[2]!;
    String? bass = match[3]?.substring(1);
    switch (pattern) {
      case 'm7':
        pattern = 'min7';
        break;
      case '7':
        pattern = 'dom7';
        break;
    }
    final Pitch rootPitch = Pitch.parse(pitch);
    Pitch? bassPitch = bass != null ? Pitch.parse(bass) : null;
    return PitchChord(
      pattern: ChordPattern.parse(pattern),
      root: rootPitch,
      bass: bassPitch,
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
  String get bassString => hasDifferentBass ? '/${bass.commonName}' : '';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    } else if (other is! PitchChord) {
      return false;
    }
    PitchChord chord = other;
    if (root.octavelessEqual(chord.root) && bass.octavelessEqual(chord.bass)) {
      return pattern.equals(chord.pattern);
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}
