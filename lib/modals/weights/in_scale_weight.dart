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
          scoringStage: ScoringStage.beforeSubstitution,
          description: WeightDescription.diatonic,
        );

  static final List<ChordPattern> patternsInScale = [
    'Major',
    'Minor',
    'Minor',
    'Major',
    'Major',
    'Minor',
    'Diminished',
  ].map((e) => ChordPattern.parse(e)).toList(growable: false);

  /* TODO: Currently works only with minor and major scales, should update this
            if necessary. */
  @override
  double score(ScaleDegreeProgression progression) {
    // check if the degree is in degreesInScale
    // if it is, check if it's pattern (in the same index) is in
    // patternsInScale.
    // If it is it's in the scale.
    // If it isn't it can still be in the scale (for instance if it has
    // tensions), so split the chord to it's degrees and check that each one of
    // them is in degreesInScale.
    int count = 0;
    for (ScaleDegreeChord? chord in progression.values) {
      if (chord != null && chord.isDiatonic) {
        count++;
      }
    }
    return count / progression.length;
  }
}
