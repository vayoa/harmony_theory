import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';

/// A particular [ScoreGiver] that scores a [Progression] within a range of
/// 0 - 1, that is later multiplied by it's [importance].
abstract class Weight {
  final String name;
  final String description;
  final ScoringStage scoringStage;
  final WeightDescription weightDescription;

  /// The max [importance] value a [Weight] can have (inclusive).
  static const int maxImportance = 5;

  /// Represents the importance of the weight, ranges between 0 and
  /// [maxImportance] (inclusive).
  final int importance;

  /// Returns a new [Weight] object.
  /// [importance] must be between 0 and [maxImportance] (inclusive).
  const Weight({
    required this.name,
    required this.description,
    required this.scoringStage,
    required this.weightDescription,
    required this.importance,
  }) : assert(importance >= 0 && importance <= maxImportance);

  Score score(
      {required ScaleDegreeProgression progression,
      required ScaleDegreeProgression base});

  /// Returns the [progression]'s score after scaling it based on [importance].
  Score scaledScore(
          {required ScaleDegreeProgression progression,
          required ScaleDegreeProgression base}) =>
      score(progression: progression, base: base).scale(importance);
}

class Score {
  final double score;
  final String details;

  Score({required this.score, required String details})
      : details = '$details\n'
            'Final Score: $score';

  Score scale(int importance) {
    return Score(
      score: score * importance,
      details: details + ', scaled: ${score * importance}',
    );
  }

  @override
  String toString() {
    return 'Final Score: $score\n$details';
  }
}

enum WeightDescription {
  diatonic,
  exotic,
  technical,
}

// TDC: This is irrelevant now...
enum ScoringStage {
  /// The saved progression will be scored before substituting the base one.
  beforeSubstitution,
  afterSubstitution,
}
