import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

import '../scale_degree.dart';

class InScaleWeight extends Weight {
  const InScaleWeight()
      : super(
          name: 'InScale',
          importance: 3,
          /* TDC: This can be beforeSubstitution but if it's a tonicized
                  progression the weight will score it before doing the
                  tonicization, which will give wrong results. */
          scoringStage: ScoringStage.afterSubstitution,
          description: WeightDescription.diatonic,
        );

  static final List<ScaleDegree> sharps = [
    ScaleDegree.parse('#VI'),
    ScaleDegree.parse('#III'),
    ScaleDegree.parse('#VII'),
  ];

  static final List<ScaleDegree> flats = [
    ScaleDegree.parse('bII'),
    ScaleDegree.parse('bV'),
    ScaleDegree.parse('bI'),
    ScaleDegree.parse('bIV'),
  ];

  /// Based on chord degrees. Any degrees in the progression that are in
  /// [sharps] or [flats] subtract a point from the score.
  /// The final score is (1.0 - (outPoints / degreeCount)).
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
  }) {
    int count = 0, outCount = 0;
    String details = '';
    for (ScaleDegreeChord? chord in progression.values) {
      if (chord != null) {
        List<ScaleDegree> degrees = chord.degrees;
        count += degrees.length;
        for (ScaleDegree degree in degrees) {
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
      details: details +
          'Out of $count max points, '
              'this progression got ${count - outCount} points.',
    );
  }
}
