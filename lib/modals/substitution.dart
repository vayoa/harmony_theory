import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:thoery_test/state/substitution_handler.dart';
import 'package:tonic/tonic.dart';

class Substitution {
  final ScaleDegreeProgression substitutedBase;
  final ScaleDegreeProgression originalSubstitution;
  final ScaleDegreeProgression base;
  SubstitutionScore score;
  final SubstitutionMatch? match;

  double get rating => score.score;

  Substitution(
      {required this.substitutedBase,
      required this.originalSubstitution,
      required this.base,
      SubstitutionScore? score,
      this.match})
      : score = score ?? SubstitutionScore.empty();

  Substitution copyWith(
          {ScaleDegreeProgression? substitutedBase,
          ScaleDegreeProgression? originalSubstitution,
          ScaleDegreeProgression? base,
          SubstitutionScore? score,
          SubstitutionMatch? match}) =>
      Substitution(
        substitutedBase: substitutedBase ?? this.substitutedBase,
        originalSubstitution: originalSubstitution ?? this.originalSubstitution,
        base: base ?? this.base,
        score: score ?? this.score,
        match: match ?? this.match,
      );

  /// If [keepHarmonicFunction] is true and no [harmonicFunctionBase] is given,
  /// will use [base] as the latter.
  SubstitutionScore scoreWith(
    List<Weight> weights, {
    bool keepHarmonicFunction = false,
    ScaleDegreeProgression? harmonicFunctionBase,
  }) {
    double rating = 0.0;
    int length = 0;
    Map<String, Score> details = {};
    for (Weight weight in weights) {
      Score weightScore;
      length += weight.importance;
      switch (weight.scoringStage) {
        case ScoringStage.beforeSubstitution:
          weightScore =
              weight.scaledScore(progression: originalSubstitution, base: base);
          break;
        case ScoringStage.afterSubstitution:
          weightScore =
              weight.scaledScore(progression: substitutedBase, base: base);
          break;
      }
      rating += weightScore.score;
      details[weight.name] = weightScore;
    }
    if (keepHarmonicFunction) {
      Weight keep = SubstitutionHandler.keepHarmonicFunction;
      Score keepScore = keep.scaledScore(
          progression: substitutedBase, base: harmonicFunctionBase ?? base);
      rating += keepScore.score;
      details[keep.name] = keepScore;
      length += keep.importance;
    }
    rating / length;
    score = SubstitutionScore(score: rating / length, details: details);
    return score;
  }

  void setScore(SubstitutionScore newScore) => score = newScore;

  @override
  bool operator ==(Object other) =>
      other is Substitution && substitutedBase == other.substitutedBase;

  @override
  int get hashCode => substitutedBase.hashCode;

  @override
  String toString({PitchScale? scale, bool detailed = false}) {
    return '-- $originalSubstitution --\n'
            '$substitutedBase' +
        (scale == null ? ': ' : ' ->\n${substitutedBase.inScale(scale)}:') +
        ' ${rating.toStringAsFixed(3)} '
            '(${(substitutedBase.percentMatchedTo(base) * 100).toInt()}% '
            'equal).\n' +
        'base: $base' +
        (scale == null ? '' : ' ->\n${base.inScale(scale)}') +
        '.\n'
            '${score.toString(detailed)}\n'
            'Details: $match';
  }

  int compareTo(Substitution other) => score.compareTo(other.score);
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
