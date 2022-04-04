import 'dart:math';

import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:thoery_test/modals/tonicized_scale_degree_chord.dart';
import 'package:tonic/tonic.dart';

import 'chord_progression.dart';
import 'exceptions.dart';

// TODO: Support uneven time signatures, in constructors and in the enter class.

/// A class representing a harmonic progression, built by [ScaleDegreeChord].
/// The mode of the progression will always be Ionian (Major).
class ScaleDegreeProgression extends Progression<ScaleDegreeChord> {
  /// While the individual [ScaleDegreeChord] in the progression are represented
  /// in the major scale. The overall progression could still be in the minor
  /// scale.
  final bool _inMinor;

  //TDC: Might be too destructive to base...
  static List<ScaleDegreeChord?> _convertToMinor(
      bool inMinor, List<ScaleDegreeChord?> base) {
    if (inMinor) {
      for (int i = 0; i < base.length; i++) {
        base[i] = base[i]?.modeShift(0, 5);
      }
    }
    return base;
  }

  ScaleDegreeProgression(List<ScaleDegreeChord?> base, List<double> durations,
      {required bool inMinor,
      TimeSignature timeSignature = const TimeSignature.evenTime()})
      : _inMinor = inMinor,
        super(_convertToMinor(inMinor, base), durations,
            timeSignature: timeSignature);

  ScaleDegreeProgression.empty(
      {required bool inMinor,
      TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this([], [], inMinor: inMinor, timeSignature: timeSignature);

  ScaleDegreeProgression.fromProgression(
      Progression<ScaleDegreeChord?> progression,
      {required bool inMinor})
      : _inMinor = inMinor,
        super.raw(
          values: progression.values,
          durations: progression.durations,
          timeSignature: progression.timeSignature,
          hasNull: progression.hasNull,
        );

  ScaleDegreeProgression.evenTime(List<ScaleDegreeChord?> base,
      {required bool inMinor,
      TimeSignature timeSignature = const TimeSignature.evenTime()})
      : _inMinor = inMinor,
        super.evenTime(_convertToMinor(inMinor, base),
            timeSignature: timeSignature);

  /// Gets a list of [String] each representing a ScaleDegreeChord and returns
  /// a new [ScaleDegreeProgression].
  /// If [scalePattern] isn't specified, it will be [ScaleDegree.majorKey].
  ScaleDegreeProgression.fromList(
    List<String?> base, {
    List<double>? durations,
    bool inMinor = false,
    TimeSignature timeSignature = const TimeSignature.evenTime(),
  }) : this(
            base
                .map((String? chord) =>
                    chord == null ? null : ScaleDegreeChord.parse(chord))
                .toList(),
            durations ??
                List.generate(
                    base.length, (index) => 1 / timeSignature.denominator),
            inMinor: inMinor,
            timeSignature: timeSignature);

  // TDC: Remove 'inMinor' and infer it from scale.
  // TDC: I changed it to raw, make sure it works!!.
  ScaleDegreeProgression.fromChords(PitchScale scale, Progression<Chord> chords,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this.fromProgression(
          Progression<ScaleDegreeChord>.raw(
            values: chords.values
                .map((Chord? chord) =>
                    chord == null ? null : ScaleDegreeChord(scale, chord))
                .toList(),
            durations: chords.durations,
            timeSignature: timeSignature,
            hasNull: chords.hasNull,
          ),
          inMinor: scale.isMinor,
        );

  /// While the individual [ScaleDegreeChord] in the progression are represented
  /// in the major scale. The overall progression could still be in the minor
  /// scale.
  bool get inMinor => _inMinor;

  // TDC: Make this work only for minor/major...
  // TODO: This might not work now, check (only if you're using it...)!
  /// Returns a new [ScaleDegreeChord] converted from [fromMode] mode to
  /// [toMode] mode.
  /// If [fromMode] isn't specified it is based on [_inMinor].
  /// Ionian's (Major) mode number is 0 and so on...
  ScaleDegreeProgression modeShift({int? fromMode, required int toMode}) {
    fromMode ??= _inMinor ? 5 : 0;
    return ScaleDegreeProgression.fromProgression(
      Progression<ScaleDegreeChord>.raw(
        values: values
            .map((ScaleDegreeChord? chord) =>
                chord?.modeShift(fromMode!, toMode))
            .toList(),
        durations: durations,
        timeSignature: timeSignature,
        hasNull: hasNull,
      ),
      inMinor: _inMinor,
    );
  }

  /* TDC: Not sure if this is the best way to do it and if it's even
          important... */
  ScaleDegreeProgression addSeventh({double ratio = 1.0}) {
    ScaleDegreeProgression converted = ScaleDegreeProgression.empty(
        timeSignature: timeSignature, inMinor: _inMinor);
    for (int i = 0; i < length; i++) {
      if (values[i] != null) {
        converted.add(values[i]!.addSeventh(), durations[i] * ratio);
      }
    }
    return converted;
  }

  ScaleDegreeProgression tonicizedFor(ScaleDegreeChord tonic,
      {bool addSeventh = false, double ratio = 1.0}) {
    ScaleDegreeProgression converted = ScaleDegreeProgression.empty(
        timeSignature: timeSignature, inMinor: _inMinor);
    for (int i = 0; i < length; i++) {
      ScaleDegreeChord? convertedChord;
      if (values[i] != null) {
        convertedChord = values[i]!.tonicizedFor(tonic);
        if (addSeventh) convertedChord = convertedChord.addSeventh();
      }
      converted.add(convertedChord, durations[i] * ratio);
    }
    return converted;
  }

  // TDC: Implement scale pattern matching!!
  /* TDC: SUPPORT THE NEW DURATION REFACTOR: MEASURES AREN'T CUT SO A VALUE
          COULD HAVE A DURATION OF 1.25 FOR INSTANCE. WE NEED TO MATCH THAT
          VALUE FOR 1.0 AS WELL AS 0.25 IF IT'S SKIPPING A MEASURE!!!
          |
          EXAMPLE:
          [I, V, I]
          [0.5, 1.0, 0.5]
          WILL LOOK LIKE THIS | I V | V I |, WE NEED TO GENERATE MATCHES FOR
          THE V IN THE FIRST MEASURE AND THE V IN THE SECOND ONE, EVEN THOUGH
          THEY ARE REPRESENTED AS ONE VALUE WITH ONE DURATION!!!
   */

  /// Returns a list containing substitution match locations, where [sub] could
  /// substitute the current progression (base) within the range of
  /// [start] - [end] (end excluded).
  /// [forIndex], if not null, will search only for substitutions containing
  /// that index.
  /* TDC: Make sure the ranges work correctly without flagging legal
          substitutions. */
  // ADC: Convert!!
  List<SubstitutionMatch> getFittingMatchLocations(ScaleDegreeProgression sub,
      {int start = 0, int? end, int? forIndex}) {
    // List containing lists of match locations (first element is location in
    // base and second is location here).
    final List<SubstitutionMatch> matches = [];

    // TODO: Check if it's the way this needs to be
    // TDC: Update this explanation with the new durations...
    // Each progression is treated differently. By that I mean that if a user
    // has a [1, 2, 3, 4] saved, as well as a [1, 2] and a [3, 4] for example,
    // they will all be treated as different progressions. This is why we're
    // doing things this way.
    // If we don't have enough chord spaces to finish the progression,
    // i.e. if we are [1, 2, 3, 4] comparing against  [5, 2, 3], we'll match
    // on 2 but we won't have enough to complete, so we stop.
    // This is also true if we are a [1, 2, 3] comparing against a [2, 3, 4].
    // This is also true if we are a [1, 2, 3] comparing against a [4, 5, 6, 1].
    // We'll match on 2 but won't have enough spaces backwards to continue
    // moving.

    // ABOUT DURATIONS:
    // The exception to the rule that each progressions is treated differently
    // is when two progressions are the same relatively. For example the
    // progression [1 2, 3, -, -] where 1 and 2 are 1/8 and 3 is a 1/4 would be
    // considered the same as a [1, 2, 3] where 1 and 2 are 1/4 and 3 is a 1/2.

    end ??= length;
    int loopStart = start, loopEnd = end;
    if (forIndex != null) {
      loopStart = forIndex;
      loopEnd = forIndex + 1;
    }

    for (var baseChordPos = loopStart; baseChordPos < loopEnd; baseChordPos++) {
      for (var subChordPos = 0; subChordPos < sub.length; subChordPos++) {
        // If the two chords are equal.
        // Or if we have a tonicization.
        final SubstitutionMatchType? type = SubstitutionMatch.getMatchType(
          base: this[baseChordPos],
          sub: sub[subChordPos],
          isSubLast: subChordPos == sub.length - 1,
        );
        if (type != null) {
          // We now check if there's enough space for this progression to
          // substitute in place for the current chord.
          // For this to be true there needs to be enough duration to cover the
          // rest of the progression.
          final double ratio =
              durations[baseChordPos] / sub.durations[subChordPos];
          // TDC: Is this condition even necessary?
          if (sub.duration * ratio <= duration) {
            double neededDurationLeft = 0, neededDurationRight = 0;
            double baseDurationLeft = 0, baseDurationRight = 0;
            bool enoughInLeft = false, enoughInRight = false;
            neededDurationLeft = sub.sumDurations(0, subChordPos) * ratio;
            // If this is 0 than there's no point on checking the sum since it's
            // 0... (also there'll be an error with base[baseChordPos - 1] if we
            // don't check this...)
            if (baseChordPos != 0) {
              for (var i = baseChordPos - 1; !enoughInLeft && i >= start; i--) {
                baseDurationLeft += durations[i];
                enoughInLeft = baseDurationLeft >= neededDurationLeft;
              }
            }
            enoughInLeft = baseDurationLeft >= neededDurationLeft;
            // Continue on only if there's enough duration to fit sub in the
            // left side of base from baseChordPose...
            if (enoughInLeft) {
              if (subChordPos != end - 1) {
                neededDurationRight = sub.sumDurations(subChordPos + 1) * ratio;
                for (var i = baseChordPos + 1; !enoughInRight && i < end; i++) {
                  baseDurationRight += durations[i];
                  enoughInRight = baseDurationRight >= neededDurationRight;
                }
              }
              // enoughInRight could still be false while this condition will be
              // true (because if we matched on the last chord we won't sum the
              // needed duration right and base duration right [because we know
              // the needed duration is 0 and so we don't care] meaning
              // enoughInRight won't get updated and stay false from it's
              // initialization). This is why I'm checking this again...
              if (baseDurationRight >= neededDurationRight) {
                // Add the location to the list of match locations and continue
                // searching.
                matches.add(
                  SubstitutionMatch(
                    baseIndex: baseChordPos,
                    subIndex: subChordPos,
                    type: type,
                    withSeventh: (this[baseChordPos] != null &&
                            this[baseChordPos]!.containsSeventh) ||
                        (sub[subChordPos] != null &&
                            sub[subChordPos]!.containsSeventh),
                  ),
                );
              }
            }
          }
        }
      }
    }
    return matches;
  }

  /// Get a comparing rating of this [ScaleDegreeProgression] against another
  /// one of matching length ([other]). The higher the result the more similar
  /// the progressions are (the more chords they have in common in the same
  /// duration from their start), where 0.0 means they are completely different
  /// and 1.0 means they are the same progression.
  // TDC: This isn't really working correctly...
  double percentMatchedTo(ScaleDegreeProgression other) {
    if (duration != other.duration) return 0.0;
    double durationSum = 0, otherSum = 0, sum = 0;
    var index = 0, otherIndex = 0;
    while (index < length && otherIndex < length) {
      // If both chords are at the same duration away from the beginning of
      // the progression and are both the same in chord, we add their duration
      // difference (unless it's 0.0 in which case we add their duration) to
      // durationSum.

      if (sum == otherSum) {
        if (this[index] == other[otherIndex]) {
          // print(this[index]);
          // print(other[index]);
          double add = (durations[index] - other.durations[otherIndex]).abs();
          if (add == 0.0) add = durations[index];
          durationSum += add;
        }
        if (durations[index] == other.durations[otherIndex]) {
          sum += durations[index];
          otherSum += other.durations[otherIndex];
          index++;
          otherIndex++;
        } else if (durations[index] < other.durations[otherIndex]) {
          sum += durations[index];
          index++;
        } else {
          otherSum += other.durations[otherIndex];
          otherIndex++;
        }
      } else if (sum < otherSum) {
        sum += durations[index];
        index++;
      } else {
        otherSum += other.durations[otherIndex];
        otherIndex++;
      }
    }
    return durationSum / duration;
  }

  /// Get a comparing score of this [ScaleDegreeProgression] against a base
  /// one ([base]), which we're meant to substitute.
  /* TODO: This doesn't really make sense as a progression has to possibility
      to substitute multiple times in one progression, so which one are we
      calculating against?
      for example, if we are a [1, 2] matching against a [1, 2, 7, 2], we can
      rate ourself 1.0 ([|1, 2|,7, 2]), but also 0.5 ([1, 2,|7, 2|])...
      I know we need a flag to quickly calculate and determine whether we
      should calculate the substitutions for a progression, but this can't be
      it. Think of a better solution.
   */
  /* TODO: There isn't really a perception of rhythm in this function, beyond
            one list cell = one bar. You should implement an actual rhythm
            system... (of course the ScaleDegreeProgression has to support
            a way to represent a chord's duration...).
   */
  @Deprecated("This function doesn't make much sense, see the TODOS above it"
      "to learn more.")
  double percentMatchedWith(ScaleDegreeProgression base) {
    // Explanation to why this is done is below...
    // if we (as a saved progression) can't fit in the base progression...
    if (length > base.length) return 0.0;
    int baseChord = 0;
    int chord = 0;
    bool found = false;
    for (; !found && baseChord < base.length;) {
      for (chord = 0; !found && chord < length;) {
        found = base[baseChord] == this[chord];
        if (!found) chord++;
      }
      if (!found) baseChord++;
    }
    if (!found) return 0.0;
    // TODO: Check if it's the way this needs to be
    // Each progression is treated differently. By that I mean that if a user
    // has a [1, 2, 3, 4] saved, as well as a [1, 2] and a [3, 4] for example,
    // they will all be treated as different progressions. This is why we're
    // doing things this way.
    // If we don't have enough chord spaces to finish the progression,
    // i.e. if we are [1, 2, 3, 4] comparing against  [5, 2, 3], we'll match
    // on 2 but we won't have enough to complete, so we stop.
    // This is also true if we are a [1, 2, 3] comparing against a [2, 3, 4].
    // This is also true if we are a [1, 2, 3] comparing against a [4, 5, 6, 1].
    // We'll match on 2 but won't have enough spaces backwards to continue
    // moving.
    if (baseChord < chord || base.length - baseChord < length - chord) {
      return 0.0;
    }

    // If we reached this, we can start matching by placements.
    // We add a point every time a chord exists in both progressions at the
    // same relative position.
    // For instance, if we're a [1, 2, 0, 3] comparing against a
    // [4, 2, 5, 3, 6], we'll  finish with 2 points [2, 3].
    // Keep in mind that if we were [1, 2, 3] instead, we would only get 1
    // points. The order is important.
    int points = 1;
    for (var i = 1; i + chord < length; i++) {
      if (this[chord + i] == base[baseChord + i]) points++;
    }

    // We finish with a score relative to the length of ourselves. A
    // progressions who completely exists within the base progression
    // (remember, order matters!) will get a score of 1.0.
    return points / length;
  }

  // TDC: Implement scale pattern matching!!
  /* TDC: Returns a lot of duplicates (that we filter with the toSet() method
          in the end.
          Figure out a way to optimize this filtering... (The problem could be
          in getFittingMatchLocations...).
   */
  // TDC: Implement weight scoring in this function so we won't have to loop again.
  /// Returns a substituted [base] from the current progression within the
  /// range [start] - [end] (end excluded) if possible.
  /// If not, returns [base].
  /* TODO: It doesn't make sense to call this from the sub on a base, switch
          it around...
   */
  /* TODO: Don't just copy the code, also it's inefficient to calculate these
      things twice.
  */
  /* TODO: If the base is a IVmaj7 V7 Imaj7 and we're a ii V I we should still
          match, and suggest a ii7 V7 Imaj7. (THIS CAN NOW BE DONE WITH THE NEW
          WEAK EQUALITY FUNCTION...).
   */
  List<Substitution> getPossibleSubstitutions(ScaleDegreeProgression sub,
      {int start = 0, int? end, int? forIndex}) {
    final List<SubstitutionMatch> matches = getFittingMatchLocations(sub,
        start: start, end: end, forIndex: forIndex);
    final List<Substitution> substitutions = [];

    /* FIXME: This gets computed twice (first time in
              getFittingMatchLocations()...).
     */

    for (SubstitutionMatch match in matches) {
      int baseChord = match.baseIndex;
      int chord = match.subIndex;
      /* TODO: We don't have to compute the relative straight away (we can just
                multiply the sum by the ratio like we do in
                getFittingMatchLocations()...), convert it. */
      try {
        final ScaleDegreeProgression relativeMatch =
            SubstitutionMatch.getSubstitution(
                progression: sub,
                type: match.type,
                addSeventh: match.withSeventh,
                ratio: durations[baseChord] / sub.durations[chord],
                tonic: this[match.baseIndex]);
        // The duration from the beginning of sub to matching chord in sub.
        double d1 = -1 * relativeMatch.sumDurations(0, chord);
        // First index that could be changed.
        int left = getIndexFromDuration(d1, from: baseChord);
        // The duration from the matching chord in sub to the end of sub, without
        // the duration of the matching chord itself.
        double d2 = relativeMatch.sumDurations(chord);
        // Last index to change...
        int right = getIndexFromDuration(d2, from: baseChord);
        ScaleDegreeProgression substitution =
            ScaleDegreeProgression.fromProgression(sublist(0, left),
                inMinor: _inMinor);
        // TDC: This won't support empty chord spaces...
        double bd1 = -1 * sumDurations(left, baseChord);
        double bd2 = sumDurations(baseChord, right + 1);
        if (bd1 - d1 != 0) {
          substitution.add(this[left], -1 * (bd1 - d1));
        }
        substitution.addAll(fillWith(substitution.duration, relativeMatch));
        if (bd2 - d2 != 0) {
          substitution.add(this[right], bd2 - d2);
        }
        if (right + 1 != length) {
          substitution.addAll(sublist(right + 1));
        }
        substitutions.add(
          Substitution(
            originalSubstitution: sub,
            substitutedBase: substitution,
            base: this,
            match: match,
            firstChangedIndex: left,
            lastChangedIndex: right,
          ),
        );
      } catch (e) {
        if (e is! NonValidDuration) rethrow;
      }
    }
    // TODO: This makes sure the results will be unique, make it more efficient.
    /* TDC: I'm not sure if this is the problem but even with this I'm still
            getting a lot of equal results... */
    return substitutions.toSet().toList();
  }

  /// Returns [relativeSubSection], but if a null values is there returns
  /// replaces the null value should be if [relativeSubSection] substituted the
  /// current one, a [durationBefore] duration away from the start.
  ScaleDegreeProgression fillWith(
      double durationBefore, ScaleDegreeProgression relativeSubSection) {
    if (!relativeSubSection.hasNull) return relativeSubSection;
    double sum = 0.0;
    ScaleDegreeProgression filled = ScaleDegreeProgression.empty(
        inMinor: relativeSubSection.inMinor,
        timeSignature: relativeSubSection.timeSignature);
    for (int i = 0; i < relativeSubSection.length; i++) {
      ScaleDegreeChord? filler = relativeSubSection[i];
      double dur = relativeSubSection.durations[i];
      filler ??= this[getIndexFromDuration(durationBefore + sum)];
      sum += dur;
      filled.add(filler, dur);
    }
    return filled;
  }

  List<ScaleDegreeProgression> getFailed() {
    /* TODO: implement getFailed.
             This will get called when a substitution was failed to pass
             (when there was no place for it). The substitution will be scored
             and if it'll be deemed good enough it will be changed to be able
             to fit, and suggested to the user.
     */
    throw UnimplementedError();
  }

  ChordProgression inScale(PitchScale scale) {
    ChordProgression _chords =
        ChordProgression.empty(timeSignature: timeSignature);
    for (var i = 0; i < length; i++) {
      if (values[i] == null) {
        _chords.add(null, durations[i]);
      } else {
        _chords.add(values[i]!.inScale(scale), durations[i]);
      }
    }
    return _chords;
  }

  List<HarmonicFunction> get deriveHarmonicFunctions {
    List<HarmonicFunction> harmonicFunctions = [];
    for (int i = 0; i < length - 1; i++) {
      ScaleDegreeChord? chord = this[i];
      if (chord != null) {
        harmonicFunctions.add(chord.deriveHarmonicFunction(next: this[i + 1]));
      } else {
        harmonicFunctions.add(HarmonicFunction.undefined);
      }
    }
    ScaleDegreeChord? last = values.last;
    if (last != null) {
      harmonicFunctions.add(last.deriveHarmonicFunction());
    } else {
      harmonicFunctions.add(HarmonicFunction.undefined);
    }
    return harmonicFunctions;
  }

  HarmonicFunction deriveHarmonicFunctionOf(int index) {
    ScaleDegreeChord? chord = this[index];
    if (chord != null) {
      if (index == length - 1) {
        return chord.deriveHarmonicFunction();
      }
      return chord.deriveHarmonicFunction(next: this[index + 1]);
    } else {
      return HarmonicFunction.undefined;
    }
  }

  ScaleDegreeProgression get deriveTonicizations {
    ScaleDegreeProgression progression =
        ScaleDegreeProgression.empty(inMinor: _inMinor);
    Map<int, List<TonicizedScaleDegreeChord?>> tonicizations = {};
    for (int tonic = 0; tonic < length + 2; tonic++) {
      ScaleDegreeChord? tonicChord;
      if (tonic == 0) {
        tonicChord = ScaleDegreeChord.majorTonicTriad;
      } else if (tonic == 1) {
        tonicChord = ScaleDegreeChord.vi;
      } else {
        tonicChord = this[tonic - 2];
      }
      if (tonicChord != null) {
        int weakHash = tonicChord.weakHash;
        if (!tonicizations.containsKey(weakHash)) {
          tonicizations[weakHash] = [];
          for (int chord = 0; chord < length; chord++) {
            if (this[chord] != null) {
              tonicizations[weakHash]!.add(TonicizedScaleDegreeChord.shifted(
                  tonic: tonicChord, tonicizedToMajorScale: this[chord]!));
            } else {
              tonicizations[weakHash]!.add(null);
            }
          }
        }
      }
    }

    Map<int, Map<int, int>> sequences = {};
    for (List<TonicizedScaleDegreeChord?> tonicization
        in tonicizations.values) {
      int tonic =
          tonicization.firstWhere((element) => element != null)!.tonic.weakHash;
      sequences[tonic] = {};
      int last = 0;
      for (int chord = 0; chord < length - 1; chord++) {
        TonicizedScaleDegreeChord? tonicized = tonicization[chord],
            next = tonicization[chord + 1];
        if (tonicized != null &&
            next != null &&
            tonicized.tonicizedToTonic.isDiatonic &&
            next.tonicizedToTonic.isDiatonic) {
          if (!sequences[tonic]!.containsKey(last)) {
            sequences[tonic]![last] = chord + 1;
          } else {
            sequences[tonic]![last] = sequences[tonic]![last]! + 1;
          }
        } else {
          last = chord + 1;
        }
      }
    }

    /*
    Up until now, these were the steps we took:
    1. Shift the entire progression for each chord in it.
    2. Grab sequences: When following chords in the shifted progressions are
       secondarily diatonic.

    We'll now define how to grab the best sequences, and 'moosh' them together.
    */

    Map<Sequence, List<Sequence>> overlapping = {};

    for (MapEntry<int, Map<int, int>> entry in sequences.entries) {
      for (MapEntry<int, int> location in entry.value.entries) {
        Sequence l = Sequence.fromMap(id: entry.key, entry: location);
        overlapping[l] = [];
        for (MapEntry<int, Map<int, int>> otherEntry in sequences.entries) {
          if (otherEntry.key != entry.key) {
            for (MapEntry<int, int> other in entry.value.entries) {
              Sequence o = Sequence.fromMap(id: otherEntry.key, entry: other);
              if (l.overlapsWith(o)) {
                overlapping[l]!.add(o);
              }
            }
          }
        }
      }
    }

    for (var e in overlapping.entries) {
      Sequence sequence = e.key;
      print('- $sequence: '
          '${tonicizations[sequence.id]!.sublist(sequence.start, sequence.end + 1)} -');
      for (var o in e.value) {
        print('$o: ${tonicizations[o.id]!.sublist(o.start, o.end + 1)}');
      }
      print('\n');
    }

    // Map<ScaleDegreeChord, int> count = {};
    //
    // for (List<TonicizedScaleDegreeChord?> tonicization
    //     in tonicizations.values) {
    //   ScaleDegreeChord tonic =
    //       tonicization.firstWhere((element) => element != null)!.tonic;
    //   count[tonic] = 0;
    //   for (int chord = 0; chord < length; chord++) {
    //     TonicizedScaleDegreeChord? tonicized = tonicization[chord];
    //     if (tonicized != null && chord < length - 1) {
    //       if (tonicized.isDiatonic) {
    //         count[tonic] = count[tonic]! + 1;
    //       }
    //       TonicizedScaleDegreeChord? next = tonicization[chord + 1];
    //       if (next != null && tonicized.tonic == next.tonic) {
    //         // Dart stuff...
    //         count[tonic] = count[tonic]! + 1;
    //       }
    //     }
    //   }
    // }

    return progression;
  }
}

class Sequence {
  final int id;
  final int start;
  final int end;

  const Sequence({required this.id, required this.start, required this.end});

  Sequence.fromMap({required this.id, required MapEntry<int, int> entry})
      : start = entry.key,
        end = entry.value;

  bool overlapsWith(Sequence other) =>
      max(start, other.start) <= min(end, other.end);

  @override
  bool operator ==(Object other) =>
      other is Sequence &&
      id == other.id &&
      start == other.start &&
      end == other.end;

  @override
  int get hashCode => Object.hash(id, start, end);

  @override
  String toString() => '$start-$end';
}
