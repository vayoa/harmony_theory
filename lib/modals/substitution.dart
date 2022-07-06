import '../state/progression_bank.dart';
import '../state/substitution_handler.dart';
import 'progression/scale_degree_progression.dart';
import 'substitution_match.dart';
import 'theory_base/pitch_scale.dart';
import 'weights/keep_harmonic_function_weight.dart';
import 'weights/weight.dart';

class Substitution {
  final EntryLocation? location;
  final ScaleDegreeProgression substitutedBase;
  final ScaleDegreeProgression originalSubstitution;
  final ScaleDegreeProgression base;
  SubstitutionScore score;
  final SubstitutionMatch match;
  final double changedStart;
  final double changedEnd;

  double get rating => score.score;

  Substitution({
    required this.location,
    required this.substitutedBase,
    required this.originalSubstitution,
    required this.base,
    required this.changedStart,
    required this.changedEnd,
    required this.match,
    SubstitutionScore? score,
  }) : score = score ?? SubstitutionScore.empty();

  Substitution copyWith({
    EntryLocation? location,
    ScaleDegreeProgression? substitutedBase,
    ScaleDegreeProgression? originalSubstitution,
    ScaleDegreeProgression? base,
    double? changedStart,
    double? changedEnd,
    SubstitutionScore? score,
    SubstitutionMatch? match,
  }) =>
      Substitution(
        location: location ?? this.location,
        substitutedBase: substitutedBase ?? this.substitutedBase,
        originalSubstitution: originalSubstitution ?? this.originalSubstitution,
        base: base ?? this.base,
        score: score ?? this.score,
        changedStart: changedStart ?? this.changedStart,
        changedEnd: changedEnd ?? this.changedEnd,
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
  ///
  /// If [sound] is null, will default to [Sound.both].
  SubstitutionScore? scoreWith(
    List<Weight> weights, {
    bool keepHarmonicFunction = false,
    Sound? sound,
    ScaleDegreeProgression? harmonicFunctionBase,
  }) {
    sound ??= Sound.both;
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
      if (weight.ofSound(sound)) {
        Score weightScore;
        length += weight.importance;
        weightScore = weight.scaledScore(substitution: this, base: base);
        rating += weightScore.score;
        details[weight.name] = weightScore;
      }
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
    return '-- "$location" $originalSubstitution --\n'
        '$substitutedBase${scale == null ? ': ' : ' ->\n'
            '${substitutedBase.inScale(scale)}:'} '
        '${rating.toStringAsFixed(3)}\nbase: $base${scale == null ? '' : ' ->\n'
            '${base.inScale(scale)}'}.\n'
        '${score.toString(detailed)}\n'
        'Details: $match Changed Range: $changedStart - $changedEnd.';
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
      return '$output}';
    } else {
      String output = '{';
      for (MapEntry<String, Score> entry in details.entries) {
        output += '${entry.key}: ${entry.value.score}, ';
      }
      return '$output}';
    }
  }
}
