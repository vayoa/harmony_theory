import '../../state/progression_bank.dart';
import '../progression/scale_degree_progression.dart';
import 'weight.dart';

class ComplexWeight extends Weight {
  const ComplexWeight()
      : super(
          name: 'Complex',
          description: "Prefers progressions that have a higher chord count "
              "than their base.",
          importance: 3,
          weightDescription: WeightDescription.technical,
        );

  static const double maxRatio = 2.0;

  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
    EntryLocation? location,
  }) {
    int pc = _countChords(progression), bc = _countChords(base);
    final int max = (bc * maxRatio).round();
    return Score(
      score: pc >= bc ? (pc >= max ? 1.0 : pc / max) : 0.0,
      details:
          "Scoring based on counted chords in base ($bc) compared to counted "
          "chords in the substitution ($pc).",
    );
  }

  int _countChords(ScaleDegreeProgression progression) {
    final double decimal = progression.timeSignature.decimal;
    int count = 0;
    for (int i = 0; i < progression.length; i++) {
      double duration = progression.durations[i];
      count += duration ~/ decimal;
      if (duration % decimal != 0) count++;
    }
    return count;
  }
}
