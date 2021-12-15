import 'package:thoery_test/modals/scale_degree_progression.dart';

abstract class Weight {
  /// The max [importance] value a [Weight] can have (inclusive).
  static const maxImportance = 5;

  /// Represents the importance of the weight, ranges between 0 and
  /// [maxImportance] (inclusive).
  final int importance;
  final ScoringStage scoringStage;
  final List<WeightDescription> description;

  /// Returns a new [Weight] object.
  /// [importance] must be between 0 and [maxImportance] (inclusive).
  const Weight(this.importance, this.scoringStage, this.description)
      : assert(importance >= 0 && importance <= maxImportance);

  double score(ScaleDegreeProgression progression);
}

enum WeightDescription {
  diatonic,
  exotic,
}

enum ScoringStage {
  /// The saved progression will be scored before substituting the base one.
  beforeSubstitution,
  afterSubstitution,
  both,
}
