import '../../modals/substitution_context.dart';
import '../progression/degree_progression.dart';
import '../theory_base/degree/degree.dart';
import '../theory_base/degree/degree_chord.dart';
import 'weight.dart';

class InScaleWeight extends Weight {
  const InScaleWeight()
      : super(
          name: 'InScale',
          description: "Prefers progressions with values that have notes "
              "closer to the root scale (based on the circle of fifths).",
          importance: 3,
          weightDescription: WeightDescription.classic,
        );

  static final List<Degree> sharps = [
    Degree.parse('#VI'),
    Degree.parse('#III'),
    Degree.parse('#VII'),
  ];

  static final List<Degree> flats = [
    Degree.parse('bII'),
    Degree.parse('bV'),
    Degree.parse('bI'),
    Degree.parse('bIV'),
  ];

  static EvaluationResult evaluateChromatics(DegreeChord chord,
      [String? details]) {
    int outCount = 0;
    for (Degree degree in chord.degrees) {
      if (degree.accidentals != 0) {
        // Since flats is bigger than sharps by one...
        if (flats.last == degree) {
          outCount++;
          if (details != null) {
            details +=
                'Subtracting 1 point for a $degree in $chord. Subtracted '
                'Points: $outCount.\n';
          }
        } else {
          for (int i = 0; i < sharps.length; i++) {
            if (sharps[i] == degree || flats[i] == degree) {
              outCount++;
              if (details != null) {
                details +=
                    'Subtracting 1 point for a $degree in $chord. Subtracted '
                    'Points: $outCount.\n';
              }
              break;
            }
          }
        }
      }
    }
    return EvaluationResult(outCount, details ?? "");
  }

  /// Based on chord degrees. Any degrees in the progression that are in
  /// [sharps] or [flats] subtract a point from the score.
  /// The final score is (1.0 - (outPoints / degreeCount)).
  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    SubstitutionContext? subContext,
  }) {
    int count = 0, outCount = 0;
    String details = '';
    for (DegreeChord? chord in progression.values) {
      if (chord != null) {
        count += chord.degreesLength;
        final s = evaluateChromatics(chord, details);
        outCount += s.out;
        details += s.details;
      }
    }
    return Score(
      score: 1.0 - (outCount / count),
      details:
          '${details}Out of $count max points, this progression got ${count - outCount} points.',
    );
  }
}

class EvaluationResult {
  final int out;
  final String details;

  const EvaluationResult(this.out, this.details);
}
