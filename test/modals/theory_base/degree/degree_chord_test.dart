import 'package:harmony_theory/extensions/chord_extension.dart';
import 'package:harmony_theory/modals/theory_base/degree/degree.dart';
import 'package:harmony_theory/modals/theory_base/degree/degree_chord.dart';
import 'package:harmony_theory/modals/theory_base/generic_chord.dart';
import 'package:test/test.dart';

main() {
  test(".parse", () {
    _expectParse(parse: 'ii^7', pattern: 'Minor 7th', root: 'II', bass: 'I');
    _expectParse(parse: 'V^7', pattern: 'Dominant 7th', root: 'V', bass: 'IV');
    _expectParse(
        parse: 'viidim^7', pattern: 'Minor 7th ♭5', root: 'VII', bass: 'VI');
  });
}

String describe(GenericChord chord) => "root: ${chord.root}, "
    "pattern: ${chord.pattern}, bass: ${chord.bass}.";

_expectParse({
  required String parse,
  required String pattern,
  required String root,
  String? bass,
}) =>
    expect(
        describe(DegreeChord.parse(parse)),
        describe(DegreeChord.raw(
          ChordPatternExtension.fromFullName(pattern),
          Degree.parse(root),
          bass: bass == null ? null : Degree.parse(bass),
        )));
