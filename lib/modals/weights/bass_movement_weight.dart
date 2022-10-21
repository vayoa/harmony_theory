import 'package:tonic/tonic.dart';

import '../../modals/progression/degree_progression.dart';
import '../../modals/substitution_context.dart';
import '../../modals/weights/weight.dart';
import '../theory_base/degree/degree_chord.dart';

class BassMovementWeight extends Weight {
  /* TODO & AY: Improve the weight's description and make
                sure the parameters are ok.
   */
  const BassMovementWeight()
      : super(
          name: "BassMovement",
          description: "Prefers progressions with deliberate bass "
              "movement in their inversions.",
          importance: 4,
          weightDescription: WeightDescription.technical,
        );

  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    SubstitutionContext? subContext,
  }) {
    int bad = 0;
    String details = '';
    for (int i = 0; i < progression.length - 1; i++) {
      DegreeChord? chord = progression[i], next = progression[i + 1];
      // TODO: Handle non-inversions.
      if (chord != null &&
          next != null &&
          (chord.hasDifferentBass && chord.isInversion)) {
        Interval toNext = next.bass.from(chord.bass);
        if (toNext.number != 1 && toNext.number != 2 && toNext.number != 7) {
          bad++;
          details += "\nFound $chord - $next where the basses "
              "(${chord.bass} - ${next.bass} => $toNext) aren't "
              "a semitone apart (or the same note)."
              "\nBad Points: $bad";
        }
      }
    }
    return Score(
      score: 1.0 - (bad / (progression.length - 1)),
      details: details.isEmpty ? "No inversions were found." : details,
    );
  }
}
