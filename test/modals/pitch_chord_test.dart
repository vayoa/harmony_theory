import 'package:harmony_theory/extensions/chord_extension.dart';
import 'package:harmony_theory/modals/pitch_chord.dart';
import 'package:test/test.dart';
import 'package:tonic/tonic.dart';

import 'theory_base/degree/degree_chord_test.dart';

main() {
  test('.parse', () {
    _expectParse(parse: 'C/Bb', pattern: 'Dominant 7th', root: 'C', bass: 'Bb');
    // TDC: The bass should probably be B...
    _expectParse(parse: 'C/Cb', pattern: 'Major 7th', root: 'C', bass: 'Cb');
    _expectParse(
        parse: 'Cm/B', pattern: 'Minor-Major 7th', root: 'C', bass: 'B');
    // TDC: The bass should probably be B...
    _expectParse(
        parse: 'Cm/Cb', pattern: 'Minor-Major 7th', root: 'C', bass: 'Cb');
    _expectParse(parse: 'Cm/Bb', pattern: 'Minor 7th', root: 'C', bass: 'Bb');
  });
}

_expectParse({
  required String parse,
  required String pattern,
  required String root,
  String? bass,
}) =>
    expect(
      describe(PitchChord.parse(parse)),
      describe(PitchChord(
        pattern: ChordPatternExtension.fromFullName(pattern),
        root: Pitch.parse(root),
        bass: bass == null ? null : Pitch.parse(bass),
      )),
    );
