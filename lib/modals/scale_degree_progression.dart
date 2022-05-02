import 'package:thoery_test/modals/absolute_durations.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:tonic/tonic.dart';

import 'chord_progression.dart';
import 'exceptions.dart';

/// A class representing a harmonic progression, built by [ScaleDegreeChord].
/// The mode of the progression will always be Ionian (Major).
class ScaleDegreeProgression extends Progression<ScaleDegreeChord> {

  ScaleDegreeProgression(List<ScaleDegreeChord?> base, List<double> durations,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super(base, durations, timeSignature: timeSignature);

  ScaleDegreeProgression.empty(
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this([], [], timeSignature: timeSignature);

  ScaleDegreeProgression.fromProgression(
      Progression<ScaleDegreeChord?> progression)
      : super.raw(
          values: progression.values,
          durations: progression.durations,
          timeSignature: progression.timeSignature,
          hasNull: progression.hasNull,
        );

  ScaleDegreeProgression.evenTime(List<ScaleDegreeChord?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super.evenTime(base, timeSignature: timeSignature);

  /// Gets a list of [String] each representing a ScaleDegreeChord and returns
  /// a new [ScaleDegreeProgression].
  /// If [scalePattern] isn't specified, it will be [ScaleDegree.majorKey].
  ScaleDegreeProgression.fromList(
    List<String?> base, {
    List<double>? durations,
    TimeSignature timeSignature = const TimeSignature.evenTime(),
  }) : this(
            base
                .map((String? chord) =>
                    chord == null ? null : ScaleDegreeChord.parse(chord))
                .toList(),
            durations ??
                List.generate(
                    base.length, (index) => 1 / timeSignature.denominator),
            timeSignature: timeSignature);

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
        );

  ScaleDegreeProgression.fromJson(Map<String, dynamic> json)
      : super.raw(
          values: [
            for (Map<String, dynamic>? map in json['val'])
              map == null ? null : ScaleDegreeChord.fromJson(map)
          ],
          durations:
              AbsoluteDurations((json['dur'] as List<dynamic>).cast<double>()),
          timeSignature: TimeSignature.fromString(json['ts']),
          hasNull: json['null'],
        );

  Map<String, dynamic> toJson() {
    //TDC: Not sure if this is needed.
    List<Map<String, dynamic>?> _chords =
        values.map((e) => e?.toJson()).toList(growable: false);
    return {
      'val': _chords,
      'dur': durations.realDurations,
      'ts': timeSignature.toString(),
      'null': hasNull,
    };
  }

/* TDC: Not sure if this is the best way to do it and if it's even
          important... */
  ScaleDegreeProgression addSeventh({double ratio = 1.0}) {
    ScaleDegreeProgression converted =
        ScaleDegreeProgression.empty(timeSignature: timeSignature);
    for (int i = 0; i < length; i++) {
      if (values[i] != null) {
        converted.add(values[i]!.addSeventh(), durations[i] * ratio);
      }
    }
    return converted;
  }

  ScaleDegreeProgression tonicizedFor(ScaleDegreeChord tonic,
      {bool addSeventh = false, double ratio = 1.0}) {
    ScaleDegreeProgression converted =
        ScaleDegreeProgression.empty(timeSignature: timeSignature);
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

  /// Returns a list containing substitution match locations, where [sub] could
  /// substitute the current progression (base) within the range of
  /// [start] - [end] (end excluded).
  ///
  /// [forIndex], if not null, will search only for substitutions containing
  /// that index.
  ///
  /// [startDur] - if you want to start at a different time, essentially cutting
  /// the duration at start. The duration you input will not be included.
  ///
  /// [endDur] - limit the end duration. The duration you input will be
  /// included.
  List<SubstitutionMatch> getFittingMatchLocations(
    ScaleDegreeProgression sub, {
    int start = 0,
    int? end,
    int? forIndex,
    double startDur = 0.0,
    double? endDur,
  }) {
    end ??= length;
    endDur ??= durations[end - 1];
    assert(durations[start] > startDur);
    assert(endDur != 0 && durations[end - 1] >= endDur);

    // List containing lists of match locations (first element is location in
    // base and second is location here).
    final List<SubstitutionMatch> matches = [];

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

    int loopStart = start, loopEnd = end;
    if (forIndex != null) {
      loopStart = forIndex;
      loopEnd = forIndex + 1;
    }

    double durationToStart =
        durations.real(start) - durations[start] + startDur;
    double maxDur = durations.real(end - 1);
    if (endDur != durations[end - 1]) maxDur += -durations[end - 1] + endDur;

    for (var baseChordPos = loopStart; baseChordPos < loopEnd; baseChordPos++) {
      double minus = 0;
      double realBaseDuration = durations[baseChordPos];
      if (baseChordPos == start) {
        minus = startDur;
      } else if (baseChordPos == end - 1) {
        realBaseDuration = endDur;
      }
      realBaseDuration -= minus;
      double realDurationToBase =
          durations.real(baseChordPos) - durations[baseChordPos] + minus;
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
          final double ratio = realBaseDuration / sub.durations[subChordPos];
          // TDC: Is this condition even necessary?
          if (sub.duration * ratio <= duration) {
            double neededDurationLeft = 0, neededDurationRight = 0;
            double baseDurationLeft = 0.0, baseDurationRight = 0.0;
            bool enoughInLeft = false;
            neededDurationLeft = sub.sumDurations(0, subChordPos) * ratio;
            // If this is 0 than there's no point on checking the sum since it's
            // 0... (also there'll be an error with base[baseChordPos - 1] if we
            // don't check this...)
            if (baseChordPos != start) {
              baseDurationLeft =
                  durations.real(baseChordPos - 1) - durationToStart;
            }
            enoughInLeft = baseDurationLeft >= neededDurationLeft;
            // Continue on only if there's enough duration to fit sub in the
            // left side of base from baseChordPose...
            if (enoughInLeft) {
              neededDurationRight = sub.sumDurations(subChordPos + 1) * ratio;
              if (subChordPos != end - 1) {
                baseDurationRight =
                    maxDur - realDurationToBase - realBaseDuration;
              }
              // Do we have enough duration in right?
              if (baseDurationRight >= neededDurationRight) {
                // Add the location to the list of match locations and continue
                // searching.
                matches.add(
                  SubstitutionMatch(
                    baseIndex: baseChordPos,
                    baseOffset: baseChordPos == start ? startDur : 0.0,
                    subIndex: subChordPos,
                    ratio: ratio,
                    type: type,
                    // We add seventh only if base contains one.
                    withSeventh: this[baseChordPos] != null &&
                        this[baseChordPos]!.requiresAddingSeventh,
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

/* TDC: Returns a lot of duplicates (that we filter with the toSet() method
          in the end.
          Figure out a way to optimize this filtering... (The problem could be
          in getFittingMatchLocations...).
   */
// TDC: Implement weight scoring in this function so we won't have to loop again.
  /// Returns a substituted [base] from the current progression within the
  /// range [start] - [end] (end excluded) if possible.
  /// If not, returns [base].
  /// The range can also be fine tuned with [startDur] and [endDur]
  /// (the duration int [startDur] will be excluded and the duration in [endDur]
  /// wll be included).
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
  List<Substitution> getPossibleSubstitutions(
    ScaleDegreeProgression sub, {
    int start = 0,
    int? end,
    int? forIndex,
    double startDur = 0.0,
    double? endDur,
    String? substitutionTitle,
  }) {
    final List<SubstitutionMatch> matches = getFittingMatchLocations(
      sub,
      start: start,
      startDur: startDur,
      end: end,
      endDur: endDur,
      forIndex: forIndex,
    );
    final List<Substitution> substitutions = [];
    double halfStep = (timeSignature.step / 2);
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
                ratio: match.ratio,
                tonic: this[match.baseIndex]);
        // The duration from the beginning of sub to matching chord in sub.
        double d1 = -1 * relativeMatch.sumDurations(0, chord);
        // First index that could be changed.
        int left = getPlayingIndex(d1, from: baseChord);
        // The duration from the matching chord in sub to the end of sub, without
        // the duration of the matching chord itself.
        double d2 = relativeMatch.sumDurations(chord);
        // Last index to change...
        int right =
            getPlayingIndex(d2 - match.baseOffset - halfStep, from: baseChord);
        ScaleDegreeProgression substitution =
            ScaleDegreeProgression.fromProgression(sublist(0, left));
        double bd1 = -1 * sumDurations(left, baseChord) - match.baseOffset;
        double bd2 = sumDurations(baseChord, right + 1) - match.baseOffset;
        if (bd1 != d1) {
          substitution.add(this[left], -1 * (bd1 - d1));
        }
        substitution.addAll(fillWith(substitution.duration, relativeMatch));
        if (bd2 != d2) {
          substitution.add(this[right], bd2 - d2);
        }
        if (right + 1 != length) {
          substitution.addAll(sublist(right + 1));
        }
        // Calculate the new first + last changed indexes (could be changed
        // after overlaps etc...).
        double _durToBaseChord =
            durations.real(baseChord) - durations[baseChord];
        int firstChanged = substitution.getPlayingIndex(_durToBaseChord + d1);
        int lastChanged =
            substitution.getPlayingIndex(_durToBaseChord + d2 - halfStep);
        bool different = false;
        for (int i = firstChanged; !different && i <= lastChanged; i++) {
          different = i >= length ||
              this[i] != substitution[i] ||
              durations.real(i) != substitution.durations.real(i);
        }
        if (different) {
          substitutions.add(
            Substitution(
              originalSubstitution: sub,
              substitutedBase: substitution,
              base: this,
              match: match,
              firstChangedIndex: firstChanged,
              lastChangedIndex: lastChanged,
              title: substitutionTitle,
            ),
          );
        }
      } catch (e) {
        if (e is! NonValidDuration) rethrow;
      }
    }
    // TODO: This makes sure the results will be unique, make it more efficient.
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
        timeSignature: relativeSubSection.timeSignature);
    for (int i = 0; i < relativeSubSection.length; i++) {
      ScaleDegreeChord? filler = relativeSubSection[i];
      double dur = relativeSubSection.durations[i];
      filler ??= this[getPlayingIndex(durationBefore + sum)];
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

}
