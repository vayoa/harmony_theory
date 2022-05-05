import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class UniquesWeight extends Weight {
  const UniquesWeight()
      : super(
          name: 'Uniques',
          description: "Prefers progressions with a higher amount of unique "
              "chords.",
          importance: 2,
          scoringStage: ScoringStage.afterSubstitution,
          weightDescription: WeightDescription.exotic,
        );

  // TDC: Optimize this a bit more...
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
  }) {
    int unique = progression.values.toSet().length;
    return Score(
        score: unique / progression.length,
        details:
            'Out of ${progression.length} chords, only $unique are unique.');
  }
}
