import '../../state/progression_bank.dart';
import '../../state/substitution_handler.dart';
import '../progression/degree_progression.dart';
import '../theory_base/degree/degree_chord.dart';
import 'weight.dart';

class KeepHarmonicFunctionWeight extends Weight {
  const KeepHarmonicFunctionWeight()
      : super(
          name: 'KeepHarmonicFunction',
          description: "Prefers progressions that retain the harmonic function "
              "of their base.",
          importance: 4,
          weightDescription: WeightDescription.technical,
        );

  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    EntryLocation? location,
  }) {
    // For each chord in base, see which chords are replacing it and score
    // based on how different their harmonic function is from base.
    int baseIndex = 0, subIndex = 0;
    double baseDurSum = 0.0, subDurSum = 0.0;
    HarmonicFunction baseFunction = base.deriveHarmonicFunctionOf(0),
        underBase = progression.deriveHarmonicFunctionOf(0);
    int replacements = 0, points = 0;
    String details = '';
    // Since a progression has to have the same duration as it's base...
    while (subIndex < progression.length && baseIndex < base.length) {
      DegreeChord? baseChord = base[baseIndex];
      DegreeChord? subChord = progression[subIndex];
      if (((baseChord == null) != (subChord == null)) ||
          (baseChord != null && !baseChord.weakEqual(subChord!))) {
        replacements++;
        if (underBase != baseFunction) {
          // We use the static keep amount in SubstitutionHandler.
          if (SubstitutionHandler.keepAmount ==
              KeepHarmonicFunctionAmount.high) {
            return Score(
                score: 0.0,
                details: 'A ${base[baseIndex]} in base '
                    '(a ${baseFunction.name}) was replaced by a '
                    '${progression[subIndex]} (a ${underBase.name}). '
                    'Deducted points: $points.');
          }
          points++;
          details += '-1 for ${base[baseIndex]} in base '
              '(a ${baseFunction.name}) replaced by a '
              '${progression[subIndex]} (a ${underBase.name}). '
              'Deducted points: $points.\n';
        }
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
    double score = replacements == 0 ? 1.0 : 1.0 - (points / replacements);
    return Score(score: score, details: details);
  }
}

enum KeepHarmonicFunctionAmount {
  low, // Don't check at all.
  med, // Check and treat as a real weight.
  high, // If a sub doesn't get full points, remove it.
}
