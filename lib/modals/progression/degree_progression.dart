import 'dart:math';

import 'package:harmony_theory/modals/substitution_context.dart';

import '../../extensions/utilities.dart';
import '../../modals/variation_id.dart';
import '../../state/progression_bank.dart';
import '../pitch_chord.dart';
import '../substitution.dart';
import '../substitution_match.dart';
import '../theory_base/degree/degree_chord.dart';
import '../theory_base/degree/tonicized_degree_chord.dart';
import '../theory_base/pitch_scale.dart';
import 'absolute_durations.dart';
import 'chord_progression.dart';
import 'progression.dart';
import 'time_signature.dart';

/// A class representing a harmonic progression, built by [DegreeChord].
/// The mode of the progression will always be Ionian (Major).
class DegreeProgression extends Progression<DegreeChord> {
  DegreeProgression(List<DegreeChord?> base, List<double> durations,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super(base, durations, timeSignature: timeSignature);

  DegreeProgression.empty(
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : this([], [], timeSignature: timeSignature);

  DegreeProgression.fromProgression(Progression<DegreeChord?> progression)
      : super.raw(
          values: progression.values,
          durations: progression.durations,
          timeSignature: progression.timeSignature,
          hasNull: progression.hasNull,
        );

  DegreeProgression.evenTime(List<DegreeChord?> base,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super.evenTime(base, timeSignature: timeSignature);

  /// Gets a list of [String] each representing a ScaleDegreeChord and returns
  /// a new [DegreeProgression].
  DegreeProgression.fromList(
    List<String?> base, {
    List<double>? durations,
    TimeSignature timeSignature = const TimeSignature.evenTime(),
  }) : this(
          base
              .map((String? chord) =>
                  chord == null ? null : DegreeChord.parse(chord))
              .toList(),
          durations ??
              List.generate(
                  base.length, (index) => 1 / timeSignature.denominator),
          timeSignature: timeSignature,
        );

  DegreeProgression.fromChords(PitchScale scale, Progression<PitchChord> chords)
      : this.fromProgression(
          Progression<DegreeChord>.raw(
            values: chords.values
                .map((PitchChord? chord) =>
                    chord == null ? null : DegreeChord(scale, chord))
                .toList(),
            durations: chords.durations,
            timeSignature: chords.timeSignature,
            hasNull: chords.hasNull,
          ),
        );

  DegreeProgression.parse(String input)
      : super.parse(input: input, parser: DegreeChord.parse);

  DegreeProgression.fromJson(Map<String, dynamic> json)
      : super.raw(
          values: [
            for (Map<String, dynamic>? map in json['val'])
              map == null
                  ? null
                  : (map.containsKey('toTonic')
                      ? TonicizedDegreeChord.fromJson(map)
                      : DegreeChord.fromJson(map))
          ],
          durations: AbsoluteDurations(
            (json['dur'] as List<dynamic>).cast<double>(),
          ),
          timeSignature: TimeSignature.fromString(json['ts']),
          hasNull: json['null'],
        );

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>?> chords =
        values.map((e) => e?.toJson()).toList(growable: false);
    return {
      'val': chords,
      'dur': durations.realDurations,
      'ts': timeSignature.toString(),
      'null': hasNull,
    };
  }

  DegreeProgression addSeventh({double ratio = 1.0}) {
    DegreeProgression converted =
        DegreeProgression.empty(timeSignature: timeSignature);
    for (int i = 0; i < length; i++) {
      if (values[i] != null) {
        converted.add(values[i]!.addSeventh(), durations[i] * ratio);
      }
    }
    return converted;
  }

  /// Returns a new [DegreeChord] converted such that [tonic] is the new
  /// tonic. Everything is still represented in the major scale, besides to degree the function is called on...
  ///
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI,
  /// ii.tonicizedFor(VI) => vii.
  DegreeProgression tonicizedFor(DegreeChord tonic,
      {bool addSeventh = false, double ratio = 1.0}) {
    DegreeProgression converted =
        DegreeProgression.empty(timeSignature: timeSignature);
    for (int i = 0; i < length; i++) {
      DegreeChord? convertedChord;
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
    DegreeProgression sub, {
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

    final double step = timeSignature.step;

    for (var baseChordPos = loopStart; baseChordPos < loopEnd; baseChordPos++) {
      double minus = 0;
      double realBaseDuration = durations[baseChordPos];
      if (baseChordPos == start) {
        minus = startDur;
      } else if (baseChordPos == end - 1) {
        realBaseDuration = endDur;
      }
      realBaseDuration -= minus;
      final double maxDur = realBaseDuration;

      for (var subChordPos = 0; subChordPos < sub.length; subChordPos++) {
        // If the two chords are equal.
        // Or if we have a tonicization.
        final SubstitutionMatchType? type = SubstitutionMatch.getMatchType(
          base: this[baseChordPos],
          sub: sub[subChordPos],
          isSubLast: subChordPos == sub.length - 1,
        );
        if (type != null) {
          for (int i = 1; i <= maxDur ~/ step; i++) {
            final double dur = i * step;
            double offset = 0;
            while (offset + dur <= maxDur) {
              // We now check if there's enough space for this progression to
              // substitute in place for the current chord.
              // For this to be true there needs to be enough duration to cover the
              // rest of the progression.
              SubstitutionMatch? match = _getMatch(
                sub,
                type: type,
                baseChordPos: baseChordPos,
                realBaseDuration: dur,
                offsetDur: offset,
                subChordPos: subChordPos,
                start: start,
                startDur: startDur,
                end: end,
                endDur: endDur,
              );
              if (match != null) matches.add(match);
              offset += step;
            }
          }
        }
      }
    }
    return matches;
  }

  SubstitutionMatch? _getMatch(
    DegreeProgression sub, {
    required double realBaseDuration,
    required int subChordPos,
    required int baseChordPos,
    required int start,
    required int end,
    required double offsetDur,
    required double startDur,
    required double endDur,
    required SubstitutionMatchType type,
  }) {
    if (offsetDur + startDur >= durations[baseChordPos]) return null;

    double durationToStart =
        durations.real(start) - durations[start] + startDur;
    double maxDur = durations.real(end - 1);
    if (endDur != durations[end - 1]) maxDur += -durations[end - 1] + endDur;
    if (baseChordPos == end - 1 && realBaseDuration > endDur) {
      realBaseDuration = endDur;
    }

    final double ratio = realBaseDuration / sub.durations[subChordPos];
    if (sub.duration * ratio <= duration) {
      double neededDurationLeft = 0, neededDurationRight = 0;
      double baseDurationLeft = offsetDur, baseDurationRight = 0.0;
      neededDurationLeft = sub.sumDurations(0, subChordPos) * ratio;
      // If this is 0 than there's no point on checking the sum since it's
      // 0... (also there'll be an error with base[baseChordPos - 1] if we
      // don't check this...)
      if (baseChordPos != start) {
        baseDurationLeft = durations.real(baseChordPos - 1) - durationToStart;
      }
      // Continue on only if there's enough duration to fit sub in the
      // left side of base from baseChordPose...
      if (baseDurationLeft >= neededDurationLeft) {
        neededDurationRight = sub.sumDurations(subChordPos + 1) * ratio;
        double durationToBase =
            (durations.real(baseChordPos) - durations[baseChordPos]);
        baseDurationRight =
            maxDur - (durationToBase + offsetDur + startDur) - realBaseDuration;
        // Do we have enough duration in right?
        if (baseDurationRight >= neededDurationRight) {
          // Add the location to the list of match locations and continue
          // searching.
          return SubstitutionMatch(
            baseIndex: baseChordPos,
            baseIndexDur: durations[baseChordPos],
            baseOffset: offsetDur + startDur,
            subIndex: subChordPos,
            ratio: ratio,
            type: type,
            // We add seventh only if base contains one.
            withSeventh: this[baseChordPos] != null &&
                this[baseChordPos]!.requiresAddingSeventh,
          );
        }
      }
    }
    return null;
  }

  /// Returns a map of substituted [base] from the current progression within the
  /// range [start] - [end] (end excluded) if possible.
  /// If not, returns [base].
  /// The range can also be fine tuned with [startDur] and [endDur]
  /// (the duration int [startDur] will be excluded and the duration in [endDur]
  /// wll be included).
  ///
  /// The substitutions are separated into variation groups.
  Map<SubVariationId, List<Substitution>> getPossibleSubstitutions(
    DegreeProgression sub, {
    int start = 0,
    int? end,
    int? forIndex,
    double startDur = 0.0,
    double? endDur,
    EntryLocation? location,
  }) {
    final List<SubstitutionMatch> matches = getFittingMatchLocations(
      sub,
      start: start,
      startDur: startDur,
      end: end,
      endDur: endDur,
      forIndex: forIndex,
    );
    final Map<SubVariationId, List<Substitution>> substitutions = {};
    double halfStep = (timeSignature.step / 2);

    for (SubstitutionMatch match in matches) {
      int baseChord = match.baseIndex;
      int chord = match.subIndex;
      final DegreeProgression relativeMatch = SubstitutionMatch.getSubstitution(
          progression: sub,
          type: match.type,
          addSeventh: match.withSeventh,
          ratio: match.ratio,
          tonic: this[match.baseIndex]);
      // The duration from the beginning of sub to matching chord in sub.
      double d1 = -1 * relativeMatch.sumDurations(0, chord);
      // First index that could be changed.
      int left = baseChord;
      // If d1 is 0, left is baseChord
      if (d1 != 0) {
        left = getPlayingIndex(d1 + match.baseOffset, from: baseChord);
      }
      // The duration from the matching chord in sub to the end of sub, without
      // the duration of the matching chord itself.
      double d2 = relativeMatch.sumDurations(chord);
      // Last index to change...
      int right =
          getPlayingIndex(d2 + match.baseOffset - halfStep, from: baseChord);
      DegreeProgression substitution =
          DegreeProgression.fromProgression(sublist(0, left));
      double bd1 = -1 * sumDurations(left, baseChord) - match.baseOffset;
      double bd2 = sumDurations(baseChord, right + 1) - match.baseOffset;
      if (bd1 != d1) {
        try {
          substitution.add(this[left], d1 - bd1);
        } catch (e) {
          rethrow;
        }
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
      final double durToBaseChord =
          durations.real(baseChord) - durations[baseChord];
      final double changedStart = durToBaseChord + d1 + match.baseOffset;
      int firstChanged = substitution.getPlayingIndex(changedStart);
      final double changedEnd = durToBaseChord + d2 + match.baseOffset;
      int lastChanged = substitution.getPlayingIndex(changedEnd - halfStep);
      bool different = false;
      // Determines whether it's a different variation than base.
      bool isVariation = false;
      double? startVariation;
      double endVariation = changedEnd;
      int subStartVariation = firstChanged;
      int subEndVariation = lastChanged;

      Utilities.twoProgressionsIterator(
        this,
        substitution,
        startP1At: left,
        startP2At: firstChanged,
        iterate: (thisI, subI) {
          if (subI > lastChanged) return true;

          if (this[thisI]?.root != substitution[subI]?.root) {
            isVariation = true;
            if (startVariation == null) {
              subStartVariation = subI;
              startVariation = max(
                durations.real(thisI) - durations[thisI],
                substitution.durations.real(subI) -
                    substitution.durations[subI],
              );
            }

            subEndVariation = subI;
            endVariation = min(
              durations.real(thisI),
              substitution.durations.real(subI),
            );
          }

          if (!different) {
            different = this[thisI] != substitution[subI] ||
                durations.real(thisI) != substitution.durations.real(subI);
          }
          return false;
        },
      );
      startVariation ??= changedStart;

      if (different) {
        SubVariationId? subVariation;
        final subDurs = substitution.durations;

        if (isVariation) {
          subVariation = SubVariationId(
            progression: substitution,
            startChange: startVariation!,
            startDur: startVariation! -
                (subDurs.real(subStartVariation) - subDurs[subStartVariation]),
            start: subStartVariation,
            endDur: endVariation -
                (subDurs.real(subEndVariation) - subDurs[subEndVariation]),
            end: subEndVariation + 1,
          );
        }

        // TDC: Try to make your optimizations (above) work...
        subVariation =
            SubVariationId(progression: substitution, startChange: 0.0);

        final Substitution subToAdd = Substitution(
          substitutedBase: substitution,
          base: this,
          subContext: SubstitutionContext(
            originalSubstitution: sub,
            match: match,
            insertStart: changedStart,
            insertEnd: changedEnd,
            location: location,
            variationStart: startVariation!,
            variationEnd: endVariation,
          ),
          variationId: subVariation,
        );

        substitutions.putIfAbsent(subVariation, () => []).add(subToAdd);
      }
    }
    return substitutions;
  }

  /// Returns [relativeSubSection], but if a null values is there returns
  /// replaces the null value should be if [relativeSubSection] substituted the
  /// current one, a [durationBefore] duration away from the start.
  DegreeProgression fillWith(
      double durationBefore, DegreeProgression relativeSubSection) {
    if (!relativeSubSection.hasNull) return relativeSubSection;
    double sum = 0.0;
    DegreeProgression filled = DegreeProgression.empty(
        timeSignature: relativeSubSection.timeSignature);
    for (int i = 0; i < relativeSubSection.length; i++) {
      DegreeChord? filler = relativeSubSection[i];
      double dur = relativeSubSection.durations[i];
      filler ??= this[getPlayingIndex(durationBefore + sum)];
      sum += dur;
      filled.add(filler, dur);
    }
    return filled;
  }

  ChordProgression inScale(PitchScale scale) {
    ChordProgression chords =
        ChordProgression.empty(timeSignature: timeSignature);
    for (var i = 0; i < length; i++) {
      if (values[i] == null) {
        chords.add(null, durations[i]);
      } else {
        chords.add(values[i]!.inScale(scale), durations[i]);
      }
    }
    return chords;
  }

  HarmonicFunction deriveHarmonicFunctionOf(int index) {
    DegreeChord? chord = this[index];
    if (chord != null) {
      if (index == length - 1) {
        return chord.deriveHarmonicFunction();
      }
      return chord.deriveHarmonicFunction(next: this[index + 1]);
    } else {
      return HarmonicFunction.undefined;
    }
  }

  @override
  DegreeProgression inTimeSignature(TimeSignature timeSignature) =>
      DegreeProgression.fromProgression(super.inTimeSignature(timeSignature));

  DegreeChord get notNullLast => values.lastWhere((e) => e != null,
      orElse: () => throw Exception('All roots are null!'))!;

  DryVariationId get dryVariationId => DryVariationId(this);
}
