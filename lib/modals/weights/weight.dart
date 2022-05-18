import 'package:thoery_test/modals/quantized_progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';

import '../substitution.dart';

/// A particular [ScoreGiver] that scores a [QuantizedProgression] within a range of
/// 0 - 1, that is later multiplied by it's [importance].
abstract class Weight {
  final String name;
  final String description;
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
    required this.importance,
    required this.weightDescription,
  }) : assert(importance >= 0 && importance <= maxImportance);

  bool ofSound(Sound sound) {
    if (weightDescription == WeightDescription.technical) return true;
    switch (sound) {
      case Sound.both:
        return true;
      case Sound.classic:
        return weightDescription == WeightDescription.classic;
      case Sound.exotic:
        return weightDescription == WeightDescription.exotic;
    }
  }

  Score score(
      {required ScaleDegreeProgression progression,
      required ScaleDegreeProgression base,
      String? substitutionEntryTitle});

  /// Returns the [progression]'s score after scaling it based on [importance].
  Score scaledScore(
          {required Substitution substitution, ScaleDegreeProgression? base}) =>
      score(
        progression: substitution.substitutedBase,
        base: base ?? substitution.base,
        substitutionEntryTitle: substitution.title,
      ).scale(importance);
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
  classic,
  exotic,
  technical,
}

enum Sound {
  classic,
  both,
  exotic,
}
