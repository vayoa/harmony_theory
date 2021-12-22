import 'dart:math';

import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:tonic/tonic.dart';
import 'chord_progression.dart';

// TODO: Support uneven time signatures, in constructors and in the enter class.
class ScaleDegreeProgression extends Progression<ScaleDegreeChord> {
  final ScalePattern _scalePattern;

  ScaleDegreeProgression(List<ScaleDegreeChord> base, List<double> durations,
      {ScalePattern? scalePattern,
      TimeSignature timeSignature = const TimeSignature.evenTime()})
      : _scalePattern = scalePattern ?? ScaleDegree.majorKey,
        super(base, durations, timeSignature: timeSignature);

  ScaleDegreeProgression.empty(
      {ScalePattern? scalePattern,
      TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this([], [], timeSignature: timeSignature, scalePattern: scalePattern);

  ScaleDegreeProgression.fromProgression(
      Progression<ScaleDegreeChord> progression,
      {ScalePattern? scalePattern})
      : this(progression.values, progression.durations,
            timeSignature: progression.timeSignature,
            scalePattern: scalePattern);

  ScaleDegreeProgression.evenTime(List<ScaleDegreeChord> base,
      {ScalePattern? scalePattern})
      : _scalePattern = scalePattern ?? ScaleDegree.majorKey,
        super.evenTime(base);

  /// Gets a list of [String] each representing a ScaleDegreeChord and returns
  /// a new [ScaleDegreeProgression].
  /// If [scalePattern] isn't specified, it will be [ScaleDegree.majorKey].
  ScaleDegreeProgression.fromList(List<String> base,
      {List<double>? durations,
      TimeSignature? timeSignature,
      ScalePattern? scalePattern})
      : this(
            base
                .map((String chord) => ScaleDegreeChord.parse(
                    scalePattern ?? ScaleDegree.majorKey, chord))
                .toList(),
            durations ?? List.generate(base.length, (index) => 1 / 4),
            timeSignature: timeSignature ?? const TimeSignature.evenTime(),
            scalePattern: scalePattern);

  ScaleDegreeProgression.fromChords(Scale scale, ChordProgression chords,
      {TimeSignature? timeSignature})
      : this(
            chords
                .map((Chord chord) => ScaleDegreeChord(scale, chord))
                .toList(),
            chords.durations,
            timeSignature: timeSignature ?? const TimeSignature.evenTime(),
            scalePattern: scale.pattern);

  ScalePattern get scalePattern => _scalePattern;

  // TDC: Implement scale pattern matching!!
  /// Returns a list containing lists of match locations (first element is
  /// the location in [base] and second is location "here"...).
  List<List<int>> getFittingMatchLocations(ScaleDegreeProgression base) {
    // Explanation to why this is done is below...
    // if we (as a saved progression) can't fit in the base progression...
    if (duration > base.duration) return const [];

    // List containing lists of match locations (first element is location in
    // base and second is location here).
    final List<List<int>> matchLocations = [];

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

    for (var chordPos = 0; chordPos < length; chordPos++) {
      for (var baseChordPos = 0; baseChordPos < base.length; baseChordPos++) {
        // If the two chords are equal.
        if (this[chordPos] == base[baseChordPos]) {
          // We now check if there's enough space for this progression to
          // substitute in place for the current chord.
          // For this to be true there needs to be enough duration to cover the
          // rest of the progression.
          final double ratio =
              base.durations[baseChordPos] / durations[chordPos];
          double neededDurationLeft = 0, neededDurationRight = 0;
          double baseDurationLeft = 0, baseDurationRight = 0;
          bool enoughInLeft = false, enoughInRight = false;
          neededDurationLeft = sumDurations(0, chordPos) * ratio;
          // If this is 0 than there's no point on checking the sum since it's
          // 0... (also there'll be an error with base[baseChordPos - 1] if we
          // don't check this...)
          if (baseChordPos != 0) {
            for (var i = baseChordPos - 1; !enoughInLeft && i >= 0; i--) {
              baseDurationLeft += base.durations[i];
              enoughInLeft = baseDurationLeft >= neededDurationLeft;
            }
          }
          enoughInLeft = baseDurationLeft >= neededDurationLeft;
          // Continue on only if there's enough duration to fit 'us' in the
          // left side of base from baseChordPose...
          if (enoughInLeft) {
            if (chordPos != length - 1) {
              neededDurationRight = sumDurations(chordPos + 1) * ratio;
              for (var i = baseChordPos + 1;
                  !enoughInRight && i < base.length;
                  i++) {
                baseDurationRight += base.durations[i];
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
              // The first element is the location in base and the second is the
              // location here...
              matchLocations.add([baseChordPos, chordPos]);
            }
          }
        }
      }
    }
    return matchLocations;
  }

  /// Get a comparing rating of this [ScaleDegreeProgression] against another
  /// one of matching length ([other]). The higher the result the more similar
  /// the progressions are (the more chords they have in common in the same
  /// duration from their start), where 0.0 means they are completely different
  /// and 1.0 means they are the same progression.
  // TODO: Check that this is how it's intended to be...
  double percentMatchedTo(ScaleDegreeProgression other) {
    if (duration != other.duration) return 0.0;
    double durationSum = 0, otherSum = 0, sum = 0;
    var i = 0, j = 0;
    while (i < length && j < length) {
      // If both chords are at the same duration away from the beginning of
      // the progression and are both the same in chord and in duration,
      // we add they're duration to the durationSum.
      if (sum == otherSum) {
        if (this[i] == other[j] && durations[i] == other.durations[j]) {
          durationSum += durations[i];
        }
        i++;
        j++;
      } else if (sum < otherSum) {
        i++;
      } else {
        j++;
      }
      otherSum += other.durations[j - 1];
      sum += durations[i - 1];
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
  /// Returns a substituted [base] from the current progression if possible.
  /// If not, returns [base].
  /* TODO: Don't just copy the code, also it's inefficient to calculate these
      things twice.
  */
  /* TODO: If the base is a IVmaj7 V7 Imaj7 and we're a ii V I we should still
          match, and suggest a ii7 V7 Imaj7. (THIS CAN NOW BE DONE WITH THE NEW
          WEAK EQUALITY FUNCTION...).
   */
  List<ScaleDegreeProgression> getPossibleSubstitutions(
      ScaleDegreeProgression base) {
    final List<List<int>> matchLocations = getFittingMatchLocations(base);
    final List<ScaleDegreeProgression> substitutions = [];

    for (List<int> match in matchLocations) {
      int baseChord = match[0];
      int chord = match[1];
      /* TODO: We don't have to compute the relative straight away (we can just
                multiply the sum by the ratio like we do in
                getFittingMatchLocations()...), convert it. */
      final ScaleDegreeProgression relativeMatch =
          ScaleDegreeProgression.fromProgression(
              relativeTo(base.durations[baseChord] / durations[chord]));
      double d1 = -1 * relativeMatch.sumDurations(0, chord);
      // First index that could be changed
      int left = base.getIndexFromDuration(d1, from: baseChord);
      double d2 =
          relativeMatch.sumDurations(chord) - relativeMatch.durations[chord];
      // Last index to change...
      int right = base.getIndexFromDuration(d2, from: baseChord);
      ScaleDegreeProgression substitution =
          ScaleDegreeProgression.fromProgression(base.sublist(0, left));
      // TDC: This won't support empty chord spaces...
      double bd1 = -1 * base.sumDurations(left, baseChord);
      try {
        base.sumDurations(baseChord, right + 1) - base.durations[baseChord];
      } catch (e) {
        print(relativeMatch);
        print(relativeMatch.values[chord]);
        print(baseChord);
        print("$d2");
        print("${base.durations.length}, $baseChord, ${right + 1}");
      }
      double bd2 =
          base.sumDurations(baseChord, right + 1) - base.durations[baseChord];
      if (bd1 - d1 != 0) {
        substitution.add(base[left], -1 * (bd1 - d1));
      }
      substitution.addAll(relativeMatch);
      if (bd2 - d2 != 0) {
        substitution.add(base[right], bd2 - d2);
      }
      if (right + 1 != base.length) {
        substitution.addAll(base.sublist(right + 1));
      }
      substitutions.add(substitution);
    }
    // TODO: This makes sure the results will be unique, make it more efficient.
    return substitutions.toSet().toList();
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

  ChordProgression inScale(Scale scale) {
    ChordProgression _chords =
        ChordProgression.empty(timeSignature: timeSignature);
    for (var i = 0; i < length; i++) {
      final ScaleDegreeChord scaleDegreeChord = values[i];
      _chords.add(
          Chord(
            pattern: scaleDegreeChord.pattern,
            root: scaleDegreeChord.rootDegree.inScale(scale).toPitch(),
          ),
          durations[i]);
    }
    return _chords;
  }
}
