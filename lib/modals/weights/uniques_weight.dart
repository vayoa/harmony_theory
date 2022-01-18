import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:tonic/tonic.dart';

class UniquesWeight extends Weight {
  const UniquesWeight()
      : super(
          name: 'Uniques',
          importance: 2,
          scoringStage: ScoringStage.afterSubstitution,
          description: WeightDescription.exotic,
        );

  // FIXME: Optimize this a bit more...
  @override
  Score score(ScaleDegreeProgression progression) {
    int unique = progression.values.toSet().length;
    return Score(
        score: unique / progression.length,
        details:
            'Out of ${progression.length} chords, only $unique are unique.');
  }
}
