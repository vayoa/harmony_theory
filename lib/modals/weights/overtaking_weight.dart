import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:tonic/tonic.dart';

class OvertakingWeight extends Weight {
  const OvertakingWeight()
      : super(
          importance: 4,
          scoringStage: ScoringStage.afterSubstitution,
          description: WeightDescription.technical,
        );

  static const double overtaking = 1 / 3;

  /// Acts only on progressions longer than 1 bar (returns 1.0 otherwise).
  /// If [progression] has a chord that takes up [overtaking] or more
  /// of the whole progression's duration, returns 0, otherwise returns 1.
  /// Chords are deemed equal using [ScaleDegreeChord.weakEqual].
  @override
  double score(ScaleDegreeProgression progression) {
    if (progression.duration < progression.timeSignature.decimal) return 1.0;
    final Map<int, double> chordDurations = {};
    for (int i = 0; i < progression.length; i++) {
      final int hash =
          progression.values[i].weakHash(progression.scalePattern);
      final double duration = progression.durations[i];
      if (chordDurations.containsKey(hash)) {
        // FIXME: Dart stuff...
        chordDurations[hash] = chordDurations[hash]! + duration;
      } else {
        chordDurations[hash] = duration;
      }
      if (chordDurations[hash]! / progression.duration >= overtaking) {
        return 0.0;
      }
    }
    return 1.0;
  }
}
