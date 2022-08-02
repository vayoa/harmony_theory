import 'package:harmony_theory/extensions/utilities.dart';
import 'package:harmony_theory/state/variation_group.dart';

import '../modals/progression/degree_progression.dart';
import '../modals/substitution.dart';
import '../modals/theory_base/degree/degree_chord.dart';
import '../modals/weights/bass_movement_weight.dart';
import '../modals/weights/climactic_ending_weight.dart';
import '../modals/weights/complex_weight.dart';
import '../modals/weights/harmonic_function_weight.dart';
import '../modals/weights/important_chords_weight.dart';
import '../modals/weights/in_scale_weight.dart';
import '../modals/weights/keep_harmonic_function_weight.dart';
import '../modals/weights/overtaking_weight.dart';
import '../modals/weights/rhythm_and_placement_weight.dart';
import '../modals/weights/uniques_weight.dart';
import '../modals/weights/user_saved_weight.dart';
import '../modals/weights/weight.dart';
import 'progression_bank.dart';

abstract class SubstitutionHandler {
  static List<Weight> weights = [
    const InScaleWeight(),
    const OvertakingWeight(),
    const UniquesWeight(),
    const HarmonicFunctionWeight(),
    const RhythmAndPlacementWeight(),
    const ImportantChordsWeight(),
    const ClimacticEndingWeight(),
    const UserSavedWeight(),
    const ComplexWeight(),
    const BassMovementWeight(),
  ]..sort(
      (Weight w1, Weight w2) => -1 * w1.importance.compareTo(w2.importance));

  static const KeepHarmonicFunctionWeight keepHarmonicFunction =
      KeepHarmonicFunctionWeight();

  static KeepHarmonicFunctionAmount keepAmount = KeepHarmonicFunctionAmount.med;

  static final Map<String, Weight> weightsMap = {
    for (Weight weight in weights) weight.name: weight
  };

  static List<VariationGroup> _getPossibleSubstitutions(
    DegreeProgression base, {
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    final Map<int, List<Substitution>> substitutions = {};
    end ??= base.length;
    for (int i = start; i < end; i++) {
      DegreeChord? chord = base[i];
      if (chord != null) {
        List<PackagedProgression>? progressions =
            ProgressionBank.getByGroup(chord: chord, withTonicization: false);
        if (progressions != null && progressions.isNotEmpty) {
          for (PackagedProgression packagedProg in progressions) {
            Utilites.mergeMaps(
              substitutions,
              base.getPossibleSubstitutions(
                packagedProg.progression,
                start: start,
                startDur: startDur,
                end: end,
                endDur: endDur,
                forIndex: i,
                location: packagedProg.location,
                dryVariationId:
                    ProgressionBank.getDryVariationId(packagedProg.location),
              ),
            );
          }
        }
      }
    }
    // We do this here since it's more efficient...
    List<PackagedProgression> tonicizations = ProgressionBank.tonicizations;
    for (PackagedProgression sub in tonicizations) {
      Utilites.mergeMaps(
        substitutions,
        base.getPossibleSubstitutions(
          sub.progression,
          start: start,
          startDur: startDur,
          end: end,
          endDur: endDur,
          location: sub.location,
          dryVariationId: ProgressionBank.getDryVariationId(sub.location),
        ),
      );
    }
    return substitutions.entries
        .map((e) => VariationGroup(e.key, e.value))
        .toList();
  }

  static List<VariationGroup> getRatedSubstitutions(
    DegreeProgression base, {
    Sound? sound,
    KeepHarmonicFunctionAmount? keepAmount,
    DegreeProgression? harmonicFunctionBase,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    if (keepAmount != null) SubstitutionHandler.keepAmount = keepAmount;
    List<VariationGroup> variations = _getPossibleSubstitutions(
      base,
      start: start,
      startDur: startDur,
      end: end,
      endDur: endDur,
    );
    List<VariationGroup> sorted = [];
    bool shouldCalc = keepAmount != KeepHarmonicFunctionAmount.low;
    for (VariationGroup variation in variations) {
      List<Substitution> sortedSubs = [];
      for (Substitution sub in variation.members) {
        SubstitutionScore? score = sub.scoreWith(
          weights,
          keepHarmonicFunction: shouldCalc,
          sound: sound,
          harmonicFunctionBase: harmonicFunctionBase,
        );
        if (score != null) {
          sortedSubs.add(sub);
        }
      }
      if (sortedSubs.isNotEmpty) {
        final vg = VariationGroup(variation.subVariationId, sortedSubs);
        vg.sort();
        sorted.add(vg);
      }
    }
    sorted.sort((var a, var b) => -1 * a.compareTo(b));
    return sorted;
  }

  /// Substitutes the best option for [maxIterations] iterations.
  static Substitution substituteBy({
    required DegreeProgression base,
    required int maxIterations,
    Sound? sound,
    KeepHarmonicFunctionAmount? keepHarmonicFunction,
    int start = 0,
    double startDur = 0.0,
    int? end,
    double? endDur,
  }) {
    DegreeProgression prev = base;
    List<VariationGroup> rated;
    do {
      rated = getRatedSubstitutions(
        prev,
        sound: sound,
        keepAmount: keepHarmonicFunction,
        harmonicFunctionBase: base,
        start: start,
        startDur: startDur,
        end: end,
        endDur: endDur,
      );
      if (prev == rated.first.best.substitutedBase) break;
      prev = rated.first.best.substitutedBase;
      maxIterations--;
    } while (maxIterations > 0);
    Substitution result = rated.first.best.copyWith(base: base);
    return result;
  }
}
