import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/weights/weight.dart';

import '../scale_degree_chord.dart';

class KeepHarmonicFunctionWeight extends Weight {
  const KeepHarmonicFunctionWeight({
    this.keepHarmonicFunctionAmount = 5,
  }) : super(
          name: 'KeepHarmonicFunction',
          description: WeightDescription.technical,
          importance: 5,
          scoringStage: ScoringStage.afterSubstitution,
        );

  final int keepHarmonicFunctionAmount;

  @override
  Score score({
    required ScaleDegreeProgression progression,
    required ScaleDegreeProgression base,
  }) {
    // For each chord in base, see which chords are replacing it and score
    // based on how different their harmonic function is from base.
    // TDC: Think about what to do in the case below, whether it's good like this.
    // If in base we have a 1, 1 and in sub we have a 1.5, 0.5, the 0.5 of the
    // first 1.5 in the sub wont count as being below the second 1 in base,
    // since it didn't start playing when it started...
    int baseIndex = 0, subIndex = 0;
    double baseDurSum = 0.0, subDurSum = 0.0;
    HarmonicFunction baseFunction = base.deriveHarmonicFunctionOf(0),
        underBase = progression.deriveHarmonicFunctionOf(0);
    int replacements = 0, points = 0;
    String details = '';
    // Since a progression has to have the same duration as it's base...
    while (subIndex < progression.length && baseIndex < base.length) {
      replacements++;
      if (underBase != baseFunction) {
        points++;
        details += '-1 for ${base[baseIndex]} in base '
            '(a ${baseFunction.name}) replaced by a '
            '${progression[subIndex]} (a ${underBase.name}). '
            'Deducted points: $points.\n';
      }
      double nextBaseDurSum = baseDurSum + base.durations[baseIndex];
      double nextSubDurSum = subDurSum + progression.durations[subIndex];
      if (nextSubDurSum >= nextBaseDurSum) {
        baseIndex++;
        if (baseIndex < base.length) {
          baseFunction = base.deriveHarmonicFunctionOf(baseIndex);
          baseDurSum = nextBaseDurSum;
        }
      }
      if (nextBaseDurSum >= nextSubDurSum) {
        subIndex++;
        if (subIndex < progression.length) {
          underBase = progression.deriveHarmonicFunctionOf(subIndex);
          subDurSum = nextSubDurSum;
        }
      }
    }
    details += "Out of $replacements chord replacements, $points didn't keep "
        "the base progression's harmonic function.";
    return Score(score: 1.0 - (points / replacements), details: details);
  }
}
