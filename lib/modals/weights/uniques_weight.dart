import '../../modals/substitution_context.dart';
import '../progression/degree_progression.dart';
import 'weight.dart';

class UniquesWeight extends Weight {
  const UniquesWeight()
      : super(
          name: 'Uniques',
          description: "Prefers progressions with a higher amount of unique "
              "chords.",
          importance: 2,
          weightDescription: WeightDescription.exotic,
        );

  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    SubstitutionContext? subContext,
  }) {
    int unique = progression.values.toSet().length;
    return Score(
        score: unique / progression.length,
        details:
            'Out of ${progression.length} chords, only $unique are unique.');
  }
}
