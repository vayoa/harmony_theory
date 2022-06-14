import 'dart:convert';

import 'package:harmony_theory/modals/theory_base/generic_chord.dart';
import 'package:tonic/tonic.dart';

import '../../../extensions/chord_extension.dart';
import '../../../extensions/interval_extension.dart';
import '../../identifiable.dart';
import '../../pitch_chord.dart';
import '../pitch_scale.dart';
import 'scale_degree.dart';
import 'tonicized_scale_degree_chord.dart';

class ScaleDegreeChord extends GenericChord<ScaleDegree>
    implements Identifiable {
  static final RegExp chordNamePattern = RegExp(
      r"^([#b♯♭𝄪𝄫]*(?:III|II|IV|I|VII|VI|V))(.*)$",
      caseSensitive: false);

  static const List<String> _canBeTonicizedPatterns = [
    'Major',
    'Minor',
    'Major 7th',
    'Minor 7th',
    'Dominant 7th',
  ];

  ScaleDegreeChord.raw(ChordPattern pattern, ScaleDegree rootDegree)
      : super(pattern, rootDegree);

  factory ScaleDegreeChord(PitchScale scale, PitchChord chord) {
    ChordPattern pattern = chord.pattern;
    Pitch cRoot = chord.root, tRoot = scale.majorTonic;
    int semitones = (cRoot.semitones - tRoot.semitones) % 12;
    int number = 1 + cRoot.letterIndex - tRoot.letterIndex;
    if (number <= 0) number += 7;
    ScaleDegree rootDegree = ScaleDegree.rawInterval(
        scalePattern: scale.pattern,
        intervalNumber: number,
        intervalSemitones: semitones);
    return ScaleDegreeChord.raw(pattern, rootDegree);
  }

  ScaleDegreeChord.copy(ScaleDegreeChord chord)
      : super(
            ChordPattern(
                name: chord.pattern.name,
                fullName: chord.pattern.fullName,
                abbrs: chord.pattern.abbrs,
                intervals: chord.pattern.intervals),
            ScaleDegree.copy(chord.root));

  factory ScaleDegreeChord.parse(String chord) {
    List<String> split = chord.split(r'/');
    if (split.length == 1) {
      return _parseInternal(chord);
    } else {
      return _parseInternal(split[0]).tonicizedFor(_parseInternal(split[1]));
    }
  }

  static ScaleDegreeChord _parseInternal(String chord) {
    final match = chordNamePattern.matchAsPrefix(chord);
    if (match == null) {
      throw FormatException("invalid ScaleDegreeChord name: $chord");
    }
    // If the degree is a lowercase letter (meaning the chord contains a minor
    // triad).
    ChordPattern _cPattern = ChordPattern.parse(match[2]!.replaceAll('b', '♭'));
    if (match[1]!.toLowerCase() == match[1]) {
      // We don't want to change any of the generated chord patterns (for some
      // reason they aren't const so I can change them and screw up that entire
      // ChordPattern.
      // The ... operator de-folds the list.
      final List<Interval> _intervals = [..._cPattern.intervals];
      // Make the 2nd interval (the one between the root and the 3rd) minor.
      _intervals[1] = Interval.m3;
      _cPattern = ChordPattern.fromIntervals(_intervals);
    }
    return ScaleDegreeChord.raw(_cPattern, ScaleDegree.parse(match[1]!));
  }

  ScaleDegreeChord.fromJson(Map<String, dynamic> json)
      : super(ChordPatternExtension.fromFullName(json['p']),
            ScaleDegree.fromJson(json['rd']));

  Map<String, dynamic> toJson() => {
        'rd': root.toJson(),
        'p': pattern.fullName,
      };

  @override
  List<ScaleDegree> get patternMapped =>
      pattern.intervals.map((i) => root.add(i)).toList();

  /// Returns a list of [ScaleDegree] that represents the degrees that make up
  /// the [ScaleDegreeChord] in the major scale.
  List<ScaleDegree> get degrees => patternMapped;

  int get degreesLength => patternLength;

  /// Returns true if the chord is diatonic in the major scale.
  bool get isDiatonic => degrees.every((degree) => degree.isDiatonic);

  bool get canBeTonic {
    if (_canBeTonicizedPatterns.contains(pattern.name)) return true;
    final List<Interval> _intervals = pattern.intervals;
    if ((_intervals[2] - _intervals[0]).equals(Interval.P5)) {
      final Interval third = _intervals[1] - _intervals[0];
      if (third.equals(Interval.M3) || third.equals(Interval.m3)) {
        if (_intervals.length < 4) return true;
        final Interval seventh = (_intervals[3] - _intervals[0]);
        if (seventh.equals(Interval.m7)) {
          return true;
        }
        return third.equals(Interval.M3) || seventh.equals(Interval.M7);
      }
    }
    return false;
  }

  /// Returns a new [ScaleDegreeChord] converted such that [tonic] is the new
  /// tonic. Everything is still represented in the major scale, besides to degree the function is called on...
  ///
  /// Example: V.tonicizedFor(VI) => III, I.tonicizedFor(VI) => VI,
  /// ii.tonicizedFor(VI) => vii.
  ScaleDegreeChord tonicizedFor(ScaleDegreeChord tonic) {
    if (tonic.root == ScaleDegree.tonic) {
      return ScaleDegreeChord.copy(this);
    } else if (weakEqual(majorTonicTriad)) {
      return ScaleDegreeChord.raw(tonic.pattern, root.tonicizedFor(tonic.root));
    }
    return TonicizedScaleDegreeChord(
      tonic: tonic,
      tonicizedToTonic: ScaleDegreeChord.copy(this),
      tonicizedToMajorScale:
          ScaleDegreeChord.raw(pattern, root.tonicizedFor(tonic.root)),
    );
  }

  /// We get a tonic and a chord and decide what chord it is for the new tonic
  ScaleDegreeChord shiftFor(ScaleDegreeChord tonic) {
    if (weakEqual(tonic)) {
      return ScaleDegreeChord.copy(ScaleDegreeChord.majorTonicTriad);
    } else {
      return ScaleDegreeChord.raw(pattern, root.shiftFor(tonic.root));
    }
  }

  /// Will return a new [ScaleDegreeChord] with an added 7th if possible.
  /// [harmonicFunction] can be given for slightly more relevant results.
  @override
  ScaleDegreeChord addSeventh({HarmonicFunction? harmonicFunction}) {
    if (pattern.intervals.length >= 4) return ScaleDegreeChord.copy(this);
    switch (pattern.fullName) {
      case "Minor":
        return ScaleDegreeChord.raw(ChordPattern.parse('Minor 7th'), root);
      case "Major":
        if (root == ScaleDegree.V ||
            (harmonicFunction != null &&
                harmonicFunction == HarmonicFunction.dominant)) {
          return ScaleDegreeChord.raw(ChordPattern.parse('Dominant 7th'), root);
        } else {
          return ScaleDegreeChord.raw(ChordPattern.parse('Major 7th'), root);
        }
      case "Augmented":
        return ScaleDegreeChord.raw(ChordPattern.parse('Augmented 7th'), root);
      case "Diminished":
        // not sure if to add 'Diminished 7th' here somehow...
        return ScaleDegreeChord.raw(ChordPattern.parse('Minor 7th ♭5'), root);
      default:
        return ScaleDegreeChord.copy(this);
    }
  }

  @override
  String get rootString {
    if (pattern.hasMinor3rd) {
      return root.toString().toLowerCase();
    }
    return root.toString();
  }

  PitchChord inScale(PitchScale scale) =>
      PitchChord(pattern: pattern, root: root.inScale(scale));

  @override
  bool operator ==(Object other) =>
      other is ScaleDegreeChord &&
      (other.pattern.equals(pattern) && other.root == root);

  @override
  int get hashCode => Object.hash(pattern.fullName, root);

  @override
  int get id => Identifiable.hash2(
      Identifiable.hashAllInts(utf8.encode(pattern.fullName)), root.id);

  /// Returns true if the chord is equal to [other], such that their triads + 7
  /// are equal. Tensions aren't taken into consideration.
  /// If there's no 7 in only one of the chords we treat it as if it had the
  /// relevant diatonic 7, base on the Major Scale. Meaning that in a major key
  /// a ii would be weakly equal to a ii7 but not a iimaj7.
  bool weakEqual(ScaleDegreeChord other) {
    if (root != other.root) {
      return false;
    } else if (pattern == other.pattern) {
      return true;
    }
    List<Interval> ownIntervals = pattern.intervals.sublist(1, 3);
    List<Interval> otherIntervals = other.pattern.intervals.sublist(1, 3);
    for (int i = 0; i < 2; i++) {
      if (!ownIntervals[i].equals(otherIntervals[i])) return false;
    }
    if (pattern.intervals.length >= 4) {
      if (other.pattern.intervals.length >= 4) {
        if (!pattern.intervals[3].equals(other.pattern.intervals[3])) {
          return false;
        }
      } else {
        if (!root.add(pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    } else {
      if (other.pattern.intervals.length >= 4) {
        if (!other.root.add(other.pattern.intervals[3]).isDiatonic) {
          return false;
        }
      }
    }
    return true;
  }

  /// Returns a hash of the chord with no tensions. 7th are hashed in if
  /// they're not diatonic (based on the major scale).
  int get weakHash {
    List<Interval> intervals = pattern.intervals.sublist(1, 3);
    if (intervals.length >= 4) {
      if (!root.add(pattern.intervals[3]).isDiatonic) {
        intervals.add(pattern.intervals[3]);
      }
    }
    return Object.hash(
        root,
        Object.hashAll(
            [for (Interval interval in intervals) interval.getHash]));
  }

  /// Like [weakHash] but is consistent over executions.
  int get weakID {
    List<Interval> intervals = pattern.intervals.sublist(1, 3);
    if (intervals.length >= 4) {
      if (!root.add(pattern.intervals[3]).isDiatonic) {
        intervals.add(pattern.intervals[3]);
      }
    }
    return Identifiable.hash2(
        root.id,
        Identifiable.hashAllInts(
            [for (Interval interval in intervals) interval.id]));
  }

  HarmonicFunction deriveHarmonicFunction({ScaleDegreeChord? next}) {
    int weakHash = this.weakHash;
    if (defaultFunctions.containsKey(weakHash)) {
      Map<List<int>?, HarmonicFunction> forChord = defaultFunctions[weakHash]!;
      if (next != null) {
        for (MapEntry<List<int>?, HarmonicFunction> entry in forChord.entries) {
          if (entry.key != null && entry.key!.contains(weakHash)) {
            return entry.value;
          }
        }
      }
      return forChord[null]!;
    }
    return HarmonicFunction.undefined;
  }

  static final Map<int, Map<List<int>?, HarmonicFunction>> defaultFunctions =
      <ScaleDegreeChord, Map<List<String>?, HarmonicFunction>>{
    ScaleDegreeChord.majorTonicTriad: {
      null: HarmonicFunction.tonic,
    },
    ScaleDegreeChord.ii: {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.parse('iidim'): {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.parse('bVII'): {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.iii: {
      null: HarmonicFunction.tonic,
    },
    ScaleDegreeChord.parse('III'): {
      null: HarmonicFunction.dominant,
    },
    ScaleDegreeChord.parse('iv'): {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.IV: {
      null: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.V: {
      null: HarmonicFunction.dominant,
    },
    ScaleDegreeChord.vi: {
      null: HarmonicFunction.tonic,
      ['V', 'V7', 'viidim']: HarmonicFunction.subDominant,
    },
    ScaleDegreeChord.viidim: {
      null: HarmonicFunction.dominant,
      ['I']: HarmonicFunction.dominant,
      ['vi']: HarmonicFunction.subDominant,
    }
  }.map((ScaleDegreeChord key, Map<List<String>?, HarmonicFunction> value) =>
          MapEntry<int, Map<List<int>?, HarmonicFunction>>(key.weakHash, {
            for (MapEntry<List<String>?, HarmonicFunction> entry
                in value.entries)
              (entry.key == null
                  ? null
                  : [
                      for (String chord in entry.key!)
                        ScaleDegreeChord.parse(chord).weakHash
                    ]): entry.value
          }));

  static final ScaleDegreeChord majorTonicTriad = ScaleDegreeChord.parse('I');
  static final ScaleDegreeChord ii = ScaleDegreeChord.parse('ii');
  static final ScaleDegreeChord iii = ScaleDegreeChord.parse('iii');

  // ignore: non_constant_identifier_names
  static final ScaleDegreeChord IV = ScaleDegreeChord.parse('IV');
  static final ScaleDegreeChord V = ScaleDegreeChord.parse('V');
  static final ScaleDegreeChord vi = ScaleDegreeChord.parse('vi');
  static final ScaleDegreeChord viidim = ScaleDegreeChord.parse('viidim');
}

enum HarmonicFunction {
  tonic,
  subDominant,
  dominant,
  undefined,
}
