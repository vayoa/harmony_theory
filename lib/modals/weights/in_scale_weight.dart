import '../../state/progression_bank.dart';
import '../progression/degree_progression.dart';
import '../theory_base/scale_degree/degree.dart';
import '../theory_base/scale_degree/degree_chord.dart';
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

  /// Based on chord degrees. Any degrees in the progression that are in
  /// [sharps] or [flats] subtract a point from the score.
  /// The final score is (1.0 - (outPoints / degreeCount)).
  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    EntryLocation? location,
  }) {
    int count = 0, outCount = 0;
    String details = '';
    for (DegreeChord? chord in progression.values) {
      if (chord != null) {
        List<Degree> degrees = chord.degrees;
        count += degrees.length;
        for (Degree degree in degrees) {
          if (degree.accidentals != 0) {
            // Since flats is bigger than sharps by one...
            if (flats.last == degree) {
              outCount++;
              details +=
                  'Subtracting 1 point for a $degree in $chord. Subtracted '
                  'Points: $outCount.\n';
            } else {
              for (int i = 0; i < sharps.length; i++) {
                if (sharps[i] == degree || flats[i] == degree) {
                  outCount++;
                  details +=
                      'Subtracting 1 point for a $degree in $chord. Subtracted '
                      'Points: $outCount.\n';
                  break;
                }
              }
            }
          }
        }
      }
    }
    return Score(
      score: 1.0 - (outCount / count),
      details:
          '${details}Out of $count max points, this progression got ${count - outCount} points.',
    );
  }
}
