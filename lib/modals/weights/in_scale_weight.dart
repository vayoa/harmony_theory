import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

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

  static final List<ScaleDegree> sharps = [
    ScaleDegree.parse('#IV'),
    ScaleDegree.parse('#I'),
    ScaleDegree.parse('#V'),
    ScaleDegree.parse('#II'),
    ScaleDegree.parse('#VI'),
    ScaleDegree.parse('#III'),
    ScaleDegree.parse('#VII'),
  ];
  static final List<ScaleDegree> flats = [
    ScaleDegree.parse('bVII'),
    ScaleDegree.parse('bIII'),
    ScaleDegree.parse('bVI'),
    ScaleDegree.parse('bII'),
    ScaleDegree.parse('bV'),
    ScaleDegree.parse('bI'),
    ScaleDegree.parse('bIV'),
  ];

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
