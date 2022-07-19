import '../progression/degree_progression.dart';
import '../progression/progression.dart';
import '../theory_base/degree/degree_chord.dart';
import '../theory_base/degree/tonicized_degree_chord.dart';
import '../weights/harmonic_function_weight.dart';

class ProgressionAnalyzer {
  /// Returns a "re-written" [prog] after undergoing a harmonic
  /// analysis, finding tonicizations.
  ///
  /// [hard] signifies that
  /* TDC: Instead of iterating through values, iterate on
           values that get cut by measures too... */
  static DegreeProgression analyze(
    DegreeProgression prog, {
    bool hard = false,
  }) {
    List<DegreeChord?> chords = [];
    int last = 0;
    // find the index of the first chord that isn't null,
    // this is our current tonic.
    for (; last < prog.length; last++) {
      if (prog.values[last] != null) break;
    }
    DegreeChord currentTonic = DegreeChord.majorTonicTriad;
    // DegreeChord currentTonic = prog.values[last]!;

    // Iterate on the progression backwards.
    for (int i = prog.length - 1; i >= last; i--) {
      DegreeChord? chord = _analyzeChord(
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

    return DegreeProgression.fromProgression(
      Progression.raw(
        values: chords,
        durations: prog.durations,
        timeSignature: prog.timeSignature,
        hasNull: prog.hasNull,
      ),
    );
  }

  static DegreeChord? _analyzeChord({
    required DegreeProgression prog,
    required int index,
    required bool hard,
    required DegreeChord currentTonic,
    required DegreeChord? lastAdded,
  }) {
    DegreeChord? chord = prog.values[index];

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
  static DegreeChord _pickBest({
    required List<DegreeChord> chords,
    required DegreeChord? next,
  }) {
    if (chords.length == 1) return chords.first;
    DegreeChord maxChord = chords.first;
    int max = HarmonicFunctionWeight.maxFunctionImportance * -2;
    for (var chord in chords) {
      var realNext = next ?? chord.tonic;
      // Compare their scores.
      int score = _harmonicScore(chord, realNext);
      // Remove points for non-diatonic tonicizations...
      if (chord is TonicizedDegreeChord && !_diatonicTonicization(chord)) {
        score--;
      }
      // Add points when the current chord and the next have the
      // same tonic (when it's not a I)...
      // Or when the current chord's tonic is the next chord...
      if ((chord.tonic != DegreeChord.majorTonicTriad &&
              chord.tonic == realNext.tonic) ||
          chord.tonic.weakEqual(realNext)) score++;
      if (score > max) {
        maxChord = chord;
        max = score;
      }
    }
    return maxChord;
  }

  static int _harmonicScore(DegreeChord chord, DegreeChord next) {
    return HarmonicFunctionWeight.sortedFunctions.getMatch(chord, next,
            useTonicizations: true, forceRelations: true) ??
        // AY: priorities I?
        (chord.weakEqual(DegreeChord.majorTonicTriad) ? 1 : 0);
  }

  /// Returns [chord] when tonicized to its adjacent chord in [prog],
  /// if no adjacent chord exists, returns null.
  ///
  /// [index] is [chord]'s position in [prog].
  static DegreeChord? _tonicizedToNext(
    int index,
    DegreeProgression prog,
    DegreeChord chord,
  ) {
    /* TODO: Maybe instead of the next chord look for the next
                diatonic chord? Could interfere with tonicizations
                to non-diatonic chords though... */
    if (index + 1 < prog.length && prog.values[index + 1] != null) {
      DegreeChord nextTonic = prog.values[index + 1]!;
      DegreeChord tonicizedToNext = chord.reverseTonicization(nextTonic);
      return tonicizedToNext;
    }
    return null;
  }

  /// Returns true if [chord] is [TonicizedDegreeChord] and its
  /// [TonicizedDegreeChord.tonicizedToTonic] is diatonic.
  static bool _diatonicTonicization(DegreeChord chord) =>
      chord is TonicizedDegreeChord && chord.tonicizedToTonic.isDiatonic;
}
