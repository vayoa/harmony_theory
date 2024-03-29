import '../../state/progression_bank.dart';
import '../progression/degree_progression.dart';
import '../theory_base/degree/degree_chord.dart';
import 'weight.dart';

class ImportantChordsWeight extends Weight {
  const ImportantChordsWeight()
      : super(
          name: 'ImportantChords',
          description: "Prefers progressions that don't change the important "
              "values in their base (the first, last and middle tonics) and "
              "the dominants that precede them.",
          importance: 3,
          weightDescription: WeightDescription.technical,
        );

  /// Scores down [progression] if it changed the important tonics in [base],
  /// as well as changing the dominant that goes to them (if present) to
  /// something that's not a dominant.
  /// NOTE: by saying tonics I mean any chord that has a tonic root and can
  /// be tonicized!
  /// An important tonic is a tonic at the beginning, middle and end of a
  /// progression. If the progression has an odd number of measures, no middle
  /// tonic is considered (middle could be if we have 4 measures at the end
  /// of the 2nd one or at the beginning of the 3rd one. Both are checked).
  ///
  /// We also give special treatments to a I or a vi as tonics in the beginning
  /// or end of the base progression (if they exist) meaning that changing them
  /// would subtract more points than changing another tonic.
  @override
  Score score({
    required DegreeProgression progression,
    required DegreeProgression base,
    EntryLocation? location,
  }) {
    int points = 0, max = 0;
    String details = '';

    // This part of the code checks whether the first chord in base is a tonic
    // of any sort.
    // If it is we check for special cases where we would subtract more if it
    // was changed (a I or a vi). If it's not any of those we check for general
    // tonics.
    if (_isTonic(0, base)) {
      // If the first chord of base is a I or a vi
      if (base[0]!.weakEqual(DegreeChord.majorTonicTriad) ||
          base[0]!.weakEqual(DegreeChord.vi)) {
        max += 3;
        // If the first chord in progression isn't a I or a vi.
        if (progression[0] == null || !progression[0]!.weakEqual(base[0]!)) {
          // If it's a different tonic subtract 2 points.
          if (_isTonic(0, progression)) {
            points += 2;
          } else {
            // If it's not a tonic at all subtract 3.
            points += 3;
          }
          details +=
              '${-1 * points} for tonic in the beginning of base (${base[0]}) '
              'replaced by a ${progression[0]} in the beginning of the sub '
              'progression. Points: $points.\n';
        }
      } else {
        max++;
        if (!_isTonic(0, progression)) {
          points++;
          details +=
              '-1 for tonic in the beginning of base (${base[0]}) replaced by a '
              '${progression[0]} in the beginning of the sub progression. '
              'Points: $points.\n';
        }
      }
    }

    // This part of the code checks whether the last chord in base is a tonic
    // of any sort.
    // If it is we check for special cases where we would subtract more if it
    // was changed (a I or a vi). If it's not any of those we check for general
    // tonics.
    //
    // If we found any tonics we check whether the have dominants going into
    // them and if they do we subtract points if these are changed...
    if (_isTonic(base.length - 1, base)) {
      max++;
      bool checkDom = false;
      if (base.values.last!.weakEqual(DegreeChord.majorTonicTriad) ||
          base.values.last!.weakEqual(DegreeChord.vi)) {
        // Notice it's worst to change the ending tonic if it's a I or a vi
        // (since we added 1 to max earlier).
        max += 3;

        // Check for dom (later) if last in prog is also a I or vi.
        checkDom = progression.values.last!.weakEqual(base.values.last!);

        // If last in prog isn't null and not a I or a vi...
        if (progression.values.last == null || !checkDom) {
          int sub = 4;
          if (_isTonic(progression.length - 1, progression)) {
            // Check for dom (later) only if this is a tonic too.
            checkDom = true;
            sub = 3;
          }
          points += sub;
          details +=
              '${-1 * sub} for tonic in the end of base (${base.values.last}) '
              'replaced by a ${progression.values.last} in the end of the '
              'sub progression. Points: $points.\n';
        }
      } else {
        if (!_isTonic(progression.length - 1, progression)) {
          points++;
          details +=
              '-1 for tonic in the end of base (${base.values.last}) replaced by a '
              '${progression.values.last} in the end of the sub progression. '
              'Points: $points.\n';
        } else {
          checkDom = true;
        }
      }
      if (checkDom &&
          base.deriveHarmonicFunctionOf(base.length - 2) ==
              HarmonicFunction.dominant) {
        max++;
        if (progression.deriveHarmonicFunctionOf(progression.length - 2) !=
            HarmonicFunction.dominant) {
          points++;
          details += '-1 for dominant going to tonic in the end of base '
              '(${base[base.length - 2]} -> ${base.values.last}) replaced by '
              'a ${progression[progression.length - 2]} going to a tonic in '
              'the end of the sub progression. Points: $points.\n';
        }
      }
    }

    // This part checks for tonics in the middle of base and dominant chords
    // going into them. We don't check for special cases (a I or a vi where we
    // previously subtracted more if they were changed) this time, since it's
    // less important.
    //
    // Progression and base will have the same duration and time signature,
    // so their measure count will be the same...
    // See documentation as to why this is done twice.
    if (base.measureCount % 2 == 0) {
      bool stop = false;
      int middleBase = base.getPlayingIndex(base.duration / 2);
      for (int i = 0; i < 2; i++) {
        bool stopNext = false;
        middleBase += i;
        if (base.length > middleBase && _isTonic(middleBase, base)) {
          max++;
          int middleSub =
              progression.getPlayingIndex(progression.duration / 2) + i;
          // If we're a tonic and by chance the next chord will also be a tonic,
          // there's no need to check if a dominant is preceding it, since we
          // know there isn't...
          stopNext = true;
          if (middleSub < progression.length &&
              !_isTonic(middleSub, progression)) {
            points++;
            details +=
                '-1 for tonic in the middle of base (${base[middleBase]}) '
                'replaced by a ${progression[middleSub]} in the end of the sub '
                'progression. Points: $points.\n';
          } else if (!stop &&
              base.deriveHarmonicFunctionOf(middleBase - 1) ==
                  HarmonicFunction.dominant) {
            max++;
            if (progression.deriveHarmonicFunctionOf(middleSub - 1) !=
                HarmonicFunction.dominant) {
              points++;
              details += '-1 for dominant going to tonic in the middle of base '
                  '(${base[middleBase - 1]} -> ${base[middleBase]}) replaced by '
                  'a ${progression[middleSub - 1]} going to a tonic in '
                  'the end of the sub progression. Points: $points.\n';
            }
          }
        }
        if (stopNext) stop = true;
      }
    }
    double finalScore = 1.0;
    if (max != 0) {
      finalScore -= (points / max);
    }
    return Score(score: finalScore, details: details);
  }

  /* TODO: Ask yuval if this is correct, make sure to go through the PairMap
          to determine if what gets defined as a tonic is ok. */
  bool _isChordTonic(DegreeChord? chord, {DegreeChord? next}) =>
      chord != null &&
      chord.deriveHarmonicFunction(next: next) == HarmonicFunction.tonic;

  bool _isTonic(int index, DegreeProgression progression) =>
      _isChordTonic(progression[index],
          next: index + 1 < progression.length ? progression[index + 1] : null);
}
