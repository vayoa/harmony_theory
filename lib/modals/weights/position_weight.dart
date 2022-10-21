import '../../modals/progression/degree_progression.dart';
import '../../modals/substitution_context.dart';
import '../../modals/weights/weight.dart';

class PositionWeight extends Weight {
  const PositionWeight()
      : super(
          name: "Position",
          description: "Prefers substitutions to mostly start on strong beats.",
          importance: 3,
          weightDescription: WeightDescription.technical,
        );

  static const int minLengthToCheck = 2;

  static const int minLengthForHalf = 3;

  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    SubstitutionContext? subContext,
  }) {
    if (subContext == null) {
      return Score(score: 1.0, details: "No Context Was Given.");
    } else if (subContext.originalSubstitution.length <= minLengthToCheck) {
      return Score(
        score: 1.0,
        details:
            "The inserted progression had less than $minLengthToCheck chords",
      );
    }
    final strong =
        progression.timeSignature.onStrongBeat(subContext.insertStart);
    if (strong) {
      return Score(
        score: 1.0,
        details:
            "Progression larger than $minLengthToCheck was inserted on a strong beat.",
      );
    } else {
      if (subContext.originalSubstitution.length <= minLengthForHalf) {
        return Score(
          score: 0.5,
          details:
              "Progression larger than $minLengthToCheck was inserted on a "
              "weak beat, but the number of chords ($minLengthForHalf) is "
              "small enough to allow 0.5 instead of 0.0.",
        );
      } else {
        return Score(
          score: 0.0,
          details:
              "Progression larger than $minLengthToCheck was inserted on a weak beat.",
        );
      }
    }
  }
}
