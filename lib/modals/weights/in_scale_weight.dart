import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:tonic/tonic.dart';

import '../scale_degree.dart';

class InScaleWeight extends Weight {
  const InScaleWeight()
      : super(
          name: 'InScale',
          importance: 2,
          /* TDC: This can be beforeSubstitution but if it's a tonicized
                  progression the weight will score it before doing the
                  tonicization, which will give wrong results. */
          scoringStage: ScoringStage.afterSubstitution,
          description: WeightDescription.diatonic,
        );

  @override
  Score score(ScaleDegreeProgression progression) {
    int count = 0, outCount = 0;
    for (ScaleDegreeChord? chord in progression.values) {
      if (chord != null) {
        List<ScaleDegree> degrees = chord.degrees;
        count += degrees.length;
        for (ScaleDegree degree in degrees) {
          if (!degree.isDiatonic) outCount++;
        }
      }
    }
    return Score(
      score: 1.0 - outCount / count,
      details: 'Out of $count chord notes, $outCount are out of the scale.',
    );
  }
}
