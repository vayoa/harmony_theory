import 'package:tonic/tonic.dart';

import '../../modals/analysis_tools/pair_map.dart';
import '../progression/degree_progression.dart';
import '../progression/progression.dart';
import '../theory_base/degree/degree.dart';
import '../theory_base/degree/degree_chord.dart';
import '../theory_base/degree/tonicized_degree_chord.dart';
import '../weights/harmonic_function_weight.dart';

abstract class ProgressionAnalyzer {
  /// A copy of [HarmonicFunctionWeight.sortedFunctions], but
  /// while that [PairMap] has "duplicate" entries for better analysis
  /// (like having iidim -> V = 3 and also viidim -> III == 3,
  /// which are both the same function...) this version does not.
  ///
  /// The way this is done is by checking duplicates to the vi degree.
  static final PairMap<int> cleanFunctions = _generateCleanFunctions();

  static PairMap<int> _generateCleanFunctions() {
    final List<DegreeChord> checks = [DegreeChord.vi];

    Map<String, Map<int, List<String>>> map =
        Map.from(HarmonicFunctionWeight.mapFunctions);

    final functions = HarmonicFunctionWeight.sortedFunctions;

    final remove = [];

    for (String chord in map.keys) {
      DegreeChord degreeChord = DegreeChord.parse(chord);
      for (int score in map[chord]!.keys) {
        for (String next in map[chord]![score]!) {
          DegreeChord nextDegreeChord = DegreeChord.parse(next);
          for (var check in checks) {
            final cleanChord = _clean(degreeChord.reverseTonicization(check));
            final cleanNext =
                _clean(nextDegreeChord.reverseTonicization(check));
            if (functions.getMatch(cleanChord, cleanNext) != null) {
              remove.add([chord, score, next]);
            }
          }
        }
      }
    }

    for (var r in remove) {
      var chord = r[0], score = r[1], next = r[2];
      map[chord]![score]!.remove(next);
      if (map[chord]![score]!.isEmpty) {
        map[chord]!.remove(score);
      }
      if (map[chord]!.isEmpty) {
        map.remove(chord);
      }
    }
    // This went down with the calculations and I don't think it had to...
    map['IV']![2]!.add('V');
    // AY: These are the progressions that are fine opposite...
    return PairMap({
      'I': {
        3: ['V'],
      },
      ...map,
    });
  }

  static DegreeChord _clean(DegreeChord chord) =>
      chord is TonicizedDegreeChord ? chord.tonicizedToTonic : chord;

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
      chord = _analyzeSlashChord(chord);
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
      var tonicizedToPrev = _tonicizedToPrev(index, prog, chord);
      return _pickBest(
        next: lastAdded,
        prev: tonicizedToPrev?.tonic,
        chords: [
          chord,
          // If we're not on hard analysis and the chord is diatonic
          if (hard || _diatonicTonicization(tonicized)) tonicized,
          // If we're not on hard analysis and the chord tonicized to it's
          // adjacent chord is diatonic
          if (tonicizedToNext != null &&
              (hard || _diatonicTonicization(tonicizedToNext)))
            tonicizedToNext,
          if (tonicizedToPrev != null &&
              (hard || _diatonicTonicization(tonicizedToPrev)))
            tonicizedToPrev,
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
    required DegreeChord? prev,
  }) {
    if (chords.length == 1) return chords.first;
    DegreeChord maxChord = chords.first;
    int maxScore = HarmonicFunctionWeight.maxFunctionImportance * -2;
    for (var chord in chords) {
      var realNext = next ?? chord.tonic;
      var realPrev = prev ?? chord.tonic;
      // Compare their scores.
      int nextScore = _harmonicScore(chord, realNext);
      // Notice, we take prev first because we specify in _cleanFunctions
      // the functions that are good opposite as well...
      int prevScore = _harmonicScore(realPrev, chord);
      bool nextBigger = nextScore > prevScore;
      int score = nextBigger ? nextScore : prevScore;
      // Remove points for non-diatonic tonicizations...
      if (chord is TonicizedDegreeChord && !_diatonicTonicization(chord)) {
        score -= chord.isDiatonic ? 2 : 1;
      }
      // If the chord isn't a tonicization and it's not diatonic,
      // remove points...
      else if (!chord.isDiatonic) {
        score--;
      }
      // Add points when the current chord and the next have the
      // same tonic (when it's not a I)...
      // Or when the current chord's tonic is the next chord...
      if ((nextBigger && _pairOfTonic(chord, realNext)) ||
          _pairOfTonic(realPrev, chord)) {
        score++;
      }
      if (score > maxScore) {
        maxChord = chord;
        maxScore = score;
      }
    }
    return maxChord;
  }

  static int _harmonicScore(DegreeChord chord, DegreeChord next) =>
      cleanFunctions.getMatch(chord, next,
          useTonicizations: true, forceRelations: true) ??
      0;

  static bool _continuesTonic(DegreeChord chord, DegreeChord next) =>
      (chord.tonic != DegreeChord.majorTonicTriad &&
          chord.tonic == next.tonic) ||
      chord.tonic.weakEqual(next);

  static bool _pairOfTonic(DegreeChord chord, DegreeChord other) =>
      _continuesTonic(chord, other) || _continuesTonic(other, chord);

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

  static DegreeChord? _tonicizedToPrev(
    int index,
    DegreeProgression prog,
    DegreeChord chord,
  ) {
    if (index - 1 >= 0 && prog.values[index - 1] != null) {
      DegreeChord nextTonic = prog.values[index - 1]!;
      DegreeChord tonicizedToPrev = chord.reverseTonicization(nextTonic);
      return tonicizedToPrev;
    }
    return null;
  }

  /// Returns true if [chord] is [TonicizedDegreeChord] and its
  /// [TonicizedDegreeChord.tonicizedToTonic] is diatonic.
  static bool _diatonicTonicization(DegreeChord chord) =>
      chord is TonicizedDegreeChord && chord.tonicizedToTonic.isDiatonic;

  static DegreeChord? _analyzeSlashChord(DegreeChord? chord) {
    if (chord != null) {
      if (chord.hasDifferentBass && chord.bassToRoot.number == 6) {
        List<Degree> degrees = chord.patternMapped.sublist(0, 3);
        List<Interval> intervals = [Interval.P1];
        for (var degree in degrees) {
          var interval = degree.tryFrom(chord.bass);
          if (interval == null) {
            return chord;
          } else {
            intervals.add(interval);
          }
        }
        return DegreeChord.raw(
          ChordPattern.fromIntervals(intervals),
          chord.bass,
        );
      }
    }
    return chord;
  }
}
