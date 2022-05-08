import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/weights/keep_harmonic_function_weight.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:thoery_test/state/substitution_handler.dart';

class Substitution {
  final String? title;
  final ScaleDegreeProgression substitutedBase;
  final ScaleDegreeProgression originalSubstitution;
  final ScaleDegreeProgression base;
  SubstitutionScore score;
  final SubstitutionMatch match;
  final int firstChangedIndex;
  final int lastChangedIndex;

  double get rating => score.score;

  Substitution({
    this.title,
    required this.substitutedBase,
    required this.originalSubstitution,
    required this.base,
    required this.firstChangedIndex,
    required this.lastChangedIndex,
    required this.match,
    SubstitutionScore? score,
  }) : score = score ?? SubstitutionScore.empty();

  Substitution copyWith({
    String? title,
    ScaleDegreeProgression? substitutedBase,
    ScaleDegreeProgression? originalSubstitution,
    ScaleDegreeProgression? base,
    int? firstChangedIndex,
    int? lastChangedIndex,
    SubstitutionScore? score,
    SubstitutionMatch? match,
  }) =>
      Substitution(
        title: title ?? this.title,
        substitutedBase: substitutedBase ?? this.substitutedBase,
        originalSubstitution: originalSubstitution ?? this.originalSubstitution,
        base: base ?? this.base,
        score: score ?? this.score,
        firstChangedIndex: firstChangedIndex ?? this.firstChangedIndex,
        lastChangedIndex: lastChangedIndex ?? this.lastChangedIndex,
        match: match ?? this.match,
      );

  /// Returns and sets the substitution's [score] based on the relevant
  /// parameters.
  ///
  /// If [KeepHarmonicFunctionWeight] (based on
  /// [SubstitutionHandler.keepAmount]) has failed a progression, returns null.
  ///
  /// If [keepHarmonicFunction] is true and no [harmonicFunctionBase] is given,
  /// will use [base] as the latter.
  SubstitutionScore? scoreWith(
    List<Weight> weights, {
    bool keepHarmonicFunction = false,
    ScaleDegreeProgression? harmonicFunctionBase,
  }) {
    double rating = 0.0;
    int length = 0;
    Map<String, Score> details = {};
    // First, score with
    if (keepHarmonicFunction) {
      Weight keep = SubstitutionHandler.keepHarmonicFunction;
      Score keepScore = keep.scaledScore(
          substitution: this, base: harmonicFunctionBase ?? base);
      rating += keepScore.score;
      details[keep.name] = keepScore;
      length += keep.importance;
      // If keepAmount is high and the substitution keepHarmonicFunction score
      // is 0, return null.
      if (SubstitutionHandler.keepAmount == KeepHarmonicFunctionAmount.high &&
          keepScore.score == 0.0) {
        return null;
      }
    }
    for (Weight weight in weights) {
      Score weightScore;
      length += weight.importance;
      weightScore = weight.scaledScore(substitution: this, base: base);
      rating += weightScore.score;
      details[weight.name] = weightScore;
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
    return '-- "$title" $originalSubstitution --\n'
            '$substitutedBase' +
        (scale == null ? ': ' : ' ->\n${substitutedBase.inScale(scale)}:') +
        ' ${rating.toStringAsFixed(3)} '
            '(${(substitutedBase.percentMatchedTo(base) * 100).toInt()}% '
            'equal).\n' +
        'base: $base' +
        (scale == null ? '' : ' ->\n${base.inScale(scale)}') +
        '.\n'
            '${score.toString(detailed)}\n'
            'Details: $match Changed Range: $firstChangedIndex - ${lastChangedIndex + 1}.';
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
