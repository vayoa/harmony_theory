import 'package:harmony_theory/extensions/pitch_extension.dart';
import 'package:harmony_theory/modals/theory_base/generic_chord.dart';
import 'package:harmony_theory/modals/theory_base/scale_degree/scale_degree_chord.dart';
import 'package:harmony_theory/modals/theory_base/scale_degree/tonicized_scale_degree_chord.dart';

import '../modals/pitch_chord.dart';

abstract class ParsingTest {
  static ParsingTestResult test(String name) {
    bool pitch = name.startsWith(RegExp(r'[a-gA-G]'));
    GenericChord chord;
    try {
      chord = PitchChord.parse(name);
    } on Exception catch (pitchError) {
      try {
        chord = ScaleDegreeChord.parse(name);
      } on Exception catch (degreeError) {
        return ParsingTestResult(error: pitch ? pitchError : degreeError);
      }
    }
    return ParsingTestResult.ofGenericChord(chord);
  }
}

class ParsingTestResult {
  final ParsingTestResultSpec? spec;
  final Exception? error;

  const ParsingTestResult({
    this.spec,
    this.error,
  }) : assert((spec == null) != (error == null));

  factory ParsingTestResult.ofGenericChord(GenericChord chord) =>
      ParsingTestResult(
        spec: ParsingTestResultSpec(
          // Why like this? in web it doesn't show the runtime.toString correctly...
          type: chord is PitchChord
              ? 'Chord'
              : (chord is TonicizedScaleDegreeChord
                  ? 'Tonicization - ScaleDegreeChord'
                  : 'ScaleDegreeChorda'),
          root: chord is PitchChord
              ? chord.root.commonName
              : chord.root.toString(),
          bass: chord is PitchChord
              ? chord.bass.commonName
              : chord.bass.toString(),
          pattern:
              '${chord.pattern.fullName}, (intervals: ${chord.pattern.intervals})',
          object: chord,
        ),
      );

  @override
  String toString() {
    if (error != null) return 'Error!\n$error';
    return spec.toString();
  }
}

class ParsingTestResultSpec {
  final String type;
  final String root;
  final String bass;
  final String pattern;
  final dynamic object;

  const ParsingTestResultSpec({
    required this.type,
    required this.root,
    required this.bass,
    required this.pattern,
    required this.object,
  });

  @override
  String toString() => """Found type: $type.
Root: $root, Bass: ${bass == root ? 'same as root' : bass}.
Pattern: $pattern.
Will Be Displayed As: $object.""";
}
