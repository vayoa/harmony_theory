import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:tonic/tonic.dart';

class Substitution {
  final ScaleDegreeProgression substitutedBase;
  final ScaleDegreeProgression originalSubstitution;
  double rating;
  final Map<String, double> detailedRating;
  final SubstitutionMatch? substitutionMatch;

  Substitution(
      {required this.substitutedBase,
      required this.originalSubstitution,
      this.rating = 0.0,
      Map<String, double>? detailedScores,
      this.substitutionMatch})
      : detailedRating = detailedScores ?? {};

  double score(List<Weight> weights) {
    double score = 0.0;
    int length = 0;
    for (Weight weight in weights) {
      double weightScore = 0.0;
      length += weight.importance;
      switch (weight.scoringStage) {
        case ScoringStage.beforeSubstitution:
          weightScore = weight.scaledScore(originalSubstitution);
          break;
        case ScoringStage.afterSubstitution:
          weightScore = weight.scaledScore(substitutedBase);
          break;
      }
      score += weightScore;
      detailedRating[weight.name] = weightScore / weight.importance;
    }
    rating = score / length;
    return rating;
  }

  @override
  bool operator ==(Object other) =>
      other is Substitution && substitutedBase == other.substitutedBase;

  @override
  int get hashCode => substitutedBase.hashCode;

  @override
  String toString([ScaleDegreeProgression? base, Scale? scale]) {
    return '-- $originalSubstitution --\n'
            '$substitutedBase' +
        (scale == null ? ': ' : ' -> ${substitutedBase.inScale(scale)}:') +
        ' ${rating.toStringAsFixed(3)} ' +
        (base == null
            ? '\n'
            : '(${(substitutedBase.percentMatchedTo(base) * 100).toInt()}% '
                'equal).\n') +
        (detailedRating.isEmpty ? '' : '$detailedRating\n') +
        'Details: $substitutionMatch';
  }
}
