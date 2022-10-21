import 'dart:math';

import '../../modals/substitution_context.dart';
import '../../modals/weights/in_scale_weight.dart';
import '../progression/degree_progression.dart';
import '../theory_base/degree/degree_chord.dart';
import 'weight.dart';

class OvertakingWeight extends Weight {
  const OvertakingWeight()
      : super(
          name: 'Setback',
          description: "Prefers substitutions to not tonicize from a "
              "chord to that same chord. ",
          importance: 4,
          weightDescription: WeightDescription.technical,
        );

  static const int maxOut = 4;
  static const double outEffect = 0.25;
  static const int maxMeasureDistance = 2;

  /// Deducts points based on how close equal chords are to each other
  /// (with a chord in between).
  ///
  /// Deducts more points based on how many chromatic notes there are in the chord
  /// ([outToMult]).
  ///
  /// The max distance in which we score is [maxMeasureDistance].
  ///
  /// Chords are deemed equal using [DegreeChord.weakHashNoBass].
  // TODO: Add details...
  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    SubstitutionContext? subContext,
  }) {
    final maxDistance = progression.timeSignature.decimal * maxMeasureDistance;

    String details = "";
    int? last;
    Map<int, double> positions = {};
    double score = 0.0;
    int repeats = 0;

    for (int i = 0; i < progression.length; i++) {
      DegreeChord? chord = progression[i];
      double position = progression.durations.position(i);

      int? weak = chord?.weakHashNoBass;

      if (weak != null && weak != last) {
        final prev = positions[weak];
        if (prev != null) {
          final out = InScaleWeight.evaluateChromatics(chord!).out;
          final dur = max(0, maxDistance - (position - prev));
          repeats++;
          score += outToMult(out) * dur;
          details +=
              "Found repeat number $repeats ending at $chord ($position). "
              "Bad score is now: $score. \n";
        }

        positions[weak] = position + progression.durations[i];
      }
      last = weak;
    }

    if (repeats == 0) {
      return Score(score: 1.0, details: "No repeats were found.");
    }

    double maxScore = outToMult(maxOut) *
        repeats *
        (maxDistance - progression.timeSignature.step);

    details += 'Out of max $maxScore bad score, bad score is $score.';

    return Score(score: 1.0 - (score / maxScore), details: details);
  }

  double outToMult(int out) => 1 + (out * outEffect);
}
