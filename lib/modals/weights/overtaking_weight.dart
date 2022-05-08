import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

class OvertakingWeight extends Weight {
  const OvertakingWeight()
      : super(
          name: 'Overtaking',
          description: "Prefers progressions that don't have one chord "
              "overtaking the rest (in duration terms).",
          importance: 4,
          weightDescription: WeightDescription.technical,
        );

  static const double overtaking = 1 / 3;

  /// Acts only on progressions longer than 1 bar (returns 1.0 otherwise).
  /// If [progression] has a chord that takes up [overtaking] or more
  /// of the whole progression's duration, returns 0, otherwise returns 1.
  /// Chords are deemed equal using [ScaleDegreeChord.weakEqual].
  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
    String? substitutionEntryTitle,
  }) {
    if (progression.duration < progression.timeSignature.decimal) {
      return Score(
          score: 1.0,
          details: 'The progression is smaller than a measure,'
              ' so it is not checked.');
    }
    final Map<int, double> chordDurations = {};
    for (int i = 0; i < progression.length; i++) {
      if (progression.values[i] != null) {
        final int hash = progression.values[i]!.weakHash;
        final double duration = progression.durations[i];
        if (chordDurations.containsKey(hash)) {
          // FIXME: Dart stuff...
          chordDurations[hash] = chordDurations[hash]! + duration;
        } else {
          chordDurations[hash] = duration;
        }
        if (chordDurations[hash]! / progression.duration >= overtaking) {
          return Score(
              score: 0.0,
              details: 'The chord ${progression.values[i]!} is overall present'
                  ' ${chordDurations[hash]! / progression.duration} (${chordDurations[hash]!})'
                  ' and is overtaking ( >= $overtaking).');
        }
      }
    }
    return Score(
        score: 1.0,
        details: 'No chords are overtaking'
            ' ( >= $overtaking).');
  }
}
