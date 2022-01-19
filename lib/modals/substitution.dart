import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:tonic/tonic.dart';

class Substitution {
  final ScaleDegreeProgression substitutedBase;
  final ScaleDegreeProgression originalSubstitution;
  SubstitutionScore substitutionScore;
  final SubstitutionMatch? substitutionMatch;

  double get rating => substitutionScore.score;

  Substitution(
      {required this.substitutedBase,
      required this.originalSubstitution,
      SubstitutionScore? substitutionScore,
      this.substitutionMatch})
      : substitutionScore = substitutionScore ?? SubstitutionScore.empty();

  SubstitutionScore score(List<Weight> weights) {
    double rating = 0.0;
    int length = 0;
    Map<String, Score> details = {};
    for (Weight weight in weights) {
      Score weightScore;
      length += weight.importance;
      switch (weight.scoringStage) {
        case ScoringStage.beforeSubstitution:
          weightScore = weight.scaledScore(originalSubstitution);
          break;
        case ScoringStage.afterSubstitution:
          weightScore = weight.scaledScore(substitutedBase);
          break;
      }
      rating += weightScore.score;
      details[weight.name] = weightScore;
    }
    rating / length;
    substitutionScore =
        SubstitutionScore(score: rating / length, details: details);
    return substitutionScore;
  }

  @override
  bool operator ==(Object other) =>
      other is Substitution && substitutedBase == other.substitutedBase;

  @override
  int get hashCode => substitutedBase.hashCode;

  @override
  String toString(
      {ScaleDegreeProgression? base, Scale? scale, bool detailed = false}) {
    return '-- $originalSubstitution --\n'
            '$substitutedBase' +
        (scale == null ? ': ' : ' ->\n${substitutedBase.inScale(scale)}:') +
        ' ${rating.toStringAsFixed(3)} ' +
        (base == null
            ? '\n'
            : '(${(substitutedBase.percentMatchedTo(base) * 100).toInt()}% '
                'equal).\n') +
        '${substitutionScore.toString(detailed)}\n'
            'Details: $substitutionMatch';
  }

  int compareTo(Substitution other) =>
      substitutionScore.compareTo(other.substitutionScore);
}

class SubstitutionScore {
  final double score;
  final Map<String, Score> details;

  SubstitutionScore({required this.score, required this.details});

  SubstitutionScore.empty() : this(score: 0.0, details: {});

  int compareTo(SubstitutionScore other) => score.compareTo(other.score);

  @override
  String toString([bool detailed = false]) {
    if (detailed) {
      String output = 'Substitution Score: $score.\n{\n';
      for (MapEntry<String, Score> entry in details.entries) {
        output += '${entry.key}:\n${entry.value},\n\n';
      }
      return output + '}';
    } else {
      String output = '{';
      for (MapEntry<String, Score> entry in details.entries) {
        output += '${entry.key}: ${entry.value.score}, ';
      }
      return output + '}';
    }
  }
}
