import 'package:harmony_theory/modals/progression/scale_degree_progression.dart';

import '../progression/progression.dart';
import '../theory_base/scale_degree/scale_degree_chord.dart';
import '../theory_base/scale_degree/tonicized_scale_degree_chord.dart';
import '../weights/harmonic_function_weight.dart';

class ProgressionAnalyzer {
  /* TODO: Instead of iterating through values, iterate on
           values that get cut by measures too... */

  /// Returns a "re-written" [prog] after undergoing a harmonic
  /// analysis, finding tonicizations.
  ///
  /// [hard] signifies that
  static ScaleDegreeProgression analyze(
    ScaleDegreeProgression prog, {
    bool hard = false,
  }) {
    List<ScaleDegreeChord?> chords = [];
    int last = 0;
    // find the index of the first chord that isn't null,
    // this is our current tonic.
    for (; last < prog.length; last++) {
      if (prog.values[last] != null) break;
    }
    ScaleDegreeChord currentTonic = prog.values[last]!;

    // Iterate on the progression backwards.
    for (int i = prog.length - 1; i >= last; i--) {
      ScaleDegreeChord? chord = _analyze(
        prog: prog,
        index: i,
        hard: hard,
        currentTonic: currentTonic,
        lastAdded: chords.isEmpty ? null : chords.first,
      );
      if (chord != null) {
        currentTonic = chord.tonic;
      }
      chords.insert(0, chord);
    }

    return ScaleDegreeProgression.fromProgression(
      Progression.raw(
        values: chords,
        durations: prog.durations,
        timeSignature: prog.timeSignature,
        hasNull: prog.hasNull,
      ),
    );
  }

  static ScaleDegreeChord? _analyze({
    required ScaleDegreeProgression prog,
    required int index,
    required bool hard,
    required ScaleDegreeChord currentTonic,
    required ScaleDegreeChord? lastAdded,
  }) {
    ScaleDegreeChord? chord = prog.values[index];

    // If the chord isn't diatonic
    if (chord != null && (hard || !chord.isDiatonic)) {
      var tonicized = chord.reverseTonicization(currentTonic);
      var tonicizedToNext = _tonicizedToNext(index, prog, chord);
      return _pickBest(
        next: lastAdded,
        chords: [
          chord,
          // If we're not on hard analysis and the chord is diatonic
          if (hard || _diatonicTonicization(tonicized)) tonicized,
          // If we're not on hard analysis and the chord tonicized to it's
          // adjacent chord is diatonic
          if (tonicizedToNext != null &&
              (hard || _diatonicTonicization(tonicizedToNext)))
            tonicizedToNext,
        ],
      );
    }
    return chord;
  }

  /// Returns the best choice to write a chord from [chords], when the
  /// next chord after them is [next].
  ///
  /// [chords] should all be the same chord, just named differently.
  static ScaleDegreeChord _pickBest({
    required List<ScaleDegreeChord> chords,
    required ScaleDegreeChord? next,
  }) {
    if (chords.length == 1) return chords.first;
    ScaleDegreeChord maxChord = chords.first;
    int max = HarmonicFunctionWeight.maxFunctionImportance * -2;
    for (var chord in chords) {
      var realNext = next ?? chord.tonic;
      // Compare their scores.
      int score = HarmonicFunctionWeight.getSorted(chord, realNext) ?? 0;
      // Remove points for non-diatonic tonicizations...
      if (!_diatonicTonicization(chord)) score--;
      // Add points when the current chord and the next have the
      // same tonic (when it's not a I)...
      if (chord.tonic != ScaleDegreeChord.majorTonicTriad &&
          chord.tonic == realNext.tonic) score++;
      if (score > max) {
        maxChord = chord;
        max = score;
      }
    }
    return maxChord;
  }

  /// Returns [chord] when tonicized to its adjacent chord in [prog],
  /// if no adjacent chord exists, returns null.
  ///
  /// [index] is [chord]'s position in [prog].
  static ScaleDegreeChord? _tonicizedToNext(
    int index,
    ScaleDegreeProgression prog,
    ScaleDegreeChord chord,
  ) {
    /* TODO: Maybe instead of the next chord look for the next
                diatonic chord? Could interfere with tonicizations
                to non-diatonic chords though... */
    if (index + 1 < prog.length && prog.values[index + 1] != null) {
      ScaleDegreeChord nextTonic = prog.values[index + 1]!;
      ScaleDegreeChord tonicizedToNext = chord.reverseTonicization(nextTonic);
      return tonicizedToNext;
    }
    return null;
  }

  /// Returns true if [chord] is [TonicizedScaleDegreeChord] and its
  /// [TonicizedScaleDegreeChord.tonicizedToTonic] is diatonic.
  static bool _diatonicTonicization(ScaleDegreeChord chord) =>
      chord is TonicizedScaleDegreeChord && chord.tonicizedToTonic.isDiatonic;
}
