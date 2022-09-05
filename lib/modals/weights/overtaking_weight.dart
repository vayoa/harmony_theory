import 'dart:math';

import 'package:harmony_theory/modals/weights/in_scale_weight.dart';

import '../../state/progression_bank.dart';
import '../progression/degree_progression.dart';
import '../theory_base/degree/degree_chord.dart';
import 'weight.dart';

class OvertakingWeight extends Weight {
  const OvertakingWeight()
      : super(
          name: 'Overtaking',
          description: "Prefers progressions that don't have one chord "
              "overtaking the rest (in duration terms).",
          importance: 4,
          weightDescription: WeightDescription.technical,
        );

  static const int maxOut = 4;
  static const int maxMeasureDistance = 2;

  /// Deducts points based on how close equal chords are to each other
  /// (with a chord in between).
  ///
  /// Deducts more points based on how many chromatic notes there are in the chord
  /// ([outToMult]).
  ///
  /// The max distance in which we score is [maxMeasureDistance].
  ///
  /// Chords are deemed equal using [DegreeChord.weakEqual].
  // TODO: Add details...
  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    EntryLocation? location,
  }) {
    final maxDistance = progression.timeSignature.decimal * maxMeasureDistance;

    String details = "";
    int? last;
    Map<int, double> positions = {};
    double score = 0.0;

    for (int i = 0; i < progression.length; i++) {
      DegreeChord? chord = progression[i];
      double position = progression.durations.position(i);

      int? weak = chord?.weakHash;

      if (weak != null && weak != last) {
        final prev = positions[weak];
        if (prev != null) {
          final out = InScaleWeight.evaluateChromatics(chord!).out;
          final dur = max(0, maxDistance - (position - prev));
          score += outToMult(out) * dur;
        }

        positions[weak] = position + progression.durations[i];
      }
      last = weak;
    }

    double maxScore = outToMult(maxOut) *
        ((progression.duration ~/ progression.timeSignature.step) ~/ 2) *
        maxDistance;

    return Score(score: 1.0 - (score / maxScore), details: details);
  }

  int outToMult(int out) => out + 1;
}
