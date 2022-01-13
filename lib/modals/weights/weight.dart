import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:tonic/tonic.dart';

/// A particular [ScoreGiver] that scores a [Progression] within a range of
/// 0 - 1, that is later multiplied by it's [importance].
abstract class Weight {
  final String name;
  final ScoringStage scoringStage;
  final WeightDescription description;

  /// The max [importance] value a [Weight] can have (inclusive).
  static const int maxImportance = 5;

  /// Represents the importance of the weight, ranges between 0 and
  /// [maxImportance] (inclusive).
  final int importance;

  /// Returns a new [Weight] object.
  /// [importance] must be between 0 and [maxImportance] (inclusive).
  const Weight({
    required this.name,
    required this.scoringStage,
    required this.description,
    required this.importance,
  }) : assert(importance >= 0 && importance <= maxImportance);

  // TDC: Add a minor / major flag here.
  double score(ScaleDegreeProgression progression);

  /// Returns the [progression]'s score after scaling it based on [importance].
  double scaledScore(ScaleDegreeProgression progression) =>
      score(progression) * importance;
}

enum WeightDescription {
  diatonic,
  exotic,
  technical,
}

enum ScoringStage {
  /// The saved progression will be scored before substituting the base one.
  beforeSubstitution,
  afterSubstitution,
}
