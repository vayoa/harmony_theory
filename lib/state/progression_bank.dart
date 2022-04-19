import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';

// TDC: Decide if this stays static or not, since it has a constructor...
class ProgressionBank {
  static Map<int, ProgressionBankEntry> _bank = {};

  /// Notice: if the major tonic is in the last place it will be saved in a
  /// different group then if it's in any other place (for tonicization).
  static Map<int, List<int>> _groupedBank = {};

  static final int _tonicHash = ScaleDegreeChord.majorTonicTriad.weakHash;

  static final int tonicizationHash = Object.hash(_tonicHash, true);

  Map<int, ProgressionBankEntry> get bank => _bank;

  Map<int, List<int>> get groupedBank => _groupedBank;

  /// Returns all saved progressions that have a
  /// [ScaleDegreeChord.majorTonicTriad] as their last chord.
  static List<ScaleDegreeProgression> get tonicizations {
    if (_groupedBank.containsKey(tonicizationHash)) {
      return [
        for (int hash in _groupedBank[tonicizationHash]!)
          _bank[hash]!.progression
      ];
    }
    return const [];
  }

  ProgressionBank() {
    // TODO: Make sure no two same hashes are in a list in _groupedBank.
    for (ProgressionBankEntry entry in _bankList) {
      int hash = entry.hashCode;
      _bank[hash] = entry;
      for (int i = 0; i < entry.progression.length; i++) {
        ScaleDegreeChord? chord = entry.progression[i];
        final Map<int, ScaleDegreeChord> addedChords = {};
        if (chord != null) {
          int weakChordHash =
              weakHashWithPlace(chord, i == entry.progression.length - 1);
          if (!addedChords.containsKey(weakChordHash)) {
            addedChords[weakChordHash] = chord;
            if (_groupedBank.containsKey(weakChordHash)) {
              _groupedBank[weakChordHash]!.add(hash);
            } else {
              _groupedBank[weakChordHash] = [hash];
            }
          }
        }
      }
    }
  }

  ProgressionBank.fromJson(Map<String, dynamic> json) {
    _bank = {
      for (MapEntry<String, dynamic> entry in json['bank'].entries)
        int.parse(entry.key): ProgressionBankEntry.fromJson(entry.value)
    };
    _groupedBank = {
      for (MapEntry<String, dynamic> entry in json['groupedBank'].entries)
        int.parse(entry.key): entry.value.cast<int>(),
    };
  }

  /* TDC: Decide whether to save these maps with Strings as their keys to not
          have to convert them here (but have to convert ints to strings to use
          them, and have the map hash strings instead of ints...)
          or
          Keep them as int keys and convert them everytime you want to save
          to json.
   */
  Map<String, dynamic> toJson() => {
        'bank': {
          for (MapEntry<int, ProgressionBankEntry> entry in _bank.entries)
            entry.key.toString(): entry.value.toJson()
        },
        'groupedBank': {
          for (MapEntry<int, List<int>> entry in _groupedBank.entries)
            entry.key.toString(): entry.value
        }
      };

  @override
  String toString() {
    String output = '{';
    for (MapEntry<int, List<int>> entry in _groupedBank.entries) {
      output += '${entry.key}:\n';
      for (int hash in entry.value) {
        output += '${_bank[hash]},\n';
      }
      output += '\n';
    }
    return output + '}';
  }

  /* TODO: Decide whether to put this method here and whether to always hash
          'last'...*/

  /// [last] will only have effect when [chord.weakHash] is equal to
  /// [ScaleDegreeChord.majorTonicTriad]'s weak hash.
  static int weakHashWithPlace(ScaleDegreeChord chord, [bool last = false]) {
    int weakHash = chord.weakHash;
    if (weakHash == _tonicHash) {
      return Object.hash(weakHash, last);
    }
    return weakHash;
  }

  /// Returns all saved progressions from [_bank] containing the
  /// [ScaleDegreeChord.weakHash] of [chord].
  /// If [withTonicization] is true, returns also all saved progressions that
  /// have a [ScaleDegreeChord.majorTonicTriad] as their last chord.
  List<ScaleDegreeProgression>? getByGroup(
      {required ScaleDegreeChord chord, required bool withTonicization}) {
    List<int>? hashes = _groupedBank[weakHashWithPlace(chord, false)];
    if (hashes != null) {
      if (withTonicization && _groupedBank.containsKey(tonicizationHash)) {
        // TODO: Optimize...
        hashes.addAll(_groupedBank[tonicizationHash]!);
      }
      return [for (int hash in hashes) _bank[hash]!.progression];
    }
    return null;
  }

  static final List<ProgressionBankEntry> _bankList = [
    ProgressionBankEntry(
      title: 'Deceptive Cadence',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['V', 'vi']),
    ),
    // V I
    ProgressionBankEntry(
      title: 'Authentic Cadence',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['V', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Authentic Cadence 2',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['V', 'I'],
          durations: [1 / 4, 1 / 2]),
    ),
    // ii V I
    ProgressionBankEntry(
      title: 'Two-Five-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['ii', 'V', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Two-Five-One 2',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['ii', 'V', 'I'],
          durations: [1 / 4, 1 / 4, 1 / 2]),
    ),
    ProgressionBankEntry(
      title: 'Altered Two-Five-One in Minor',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(
          ['viidim', 'iii', 'III', 'vi'],
          durations: [1 / 4, 1 / 4, 1 / 4, 1 / 4]),
    ),
    ProgressionBankEntry(
      title: 'Two(diminished)-Five-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iidim', 'V', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Two(half-diminished)-Five-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iim7b5', 'V', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Two-Five-One with 7ths',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iim7b5', 'V7', 'I']),
    ),
    // IV V I
    ProgressionBankEntry(
      title: 'Four-Five-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['IV', 'V', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Altered Minor Plagal Cadence',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['IV', 'iv', 'I']),
    ),
    // IV I
    ProgressionBankEntry(
      title: 'Plagal Cadence',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['IV', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Minor Plagal Cadence',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iv', 'I']),
    ),
    // Added
    ProgressionBankEntry(
      title: 'Altered Authentic Cadence in Minor',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iii', 'III', 'vi']),
    ),
    ProgressionBankEntry(
      title: 'Altered Authentic Cadence in Minor 2',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iii', 'III', 'vi', 'vi']),
    ),
    ProgressionBankEntry(
      title: 'Diminished Resolution with 7ths',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iim7b5', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Diminished Resolution',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iidim', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Diatonic Quartal Harmony',
      builtIn: true,
      progression:
          ScaleDegreeProgression.fromList(['IV', 'II', 'V', 'III', 'vi']),
    ),
    ProgressionBankEntry(
      title: 'Reversed Diatonic Quartal Harmony',
      builtIn: true,
      progression:
          ScaleDegreeProgression.fromList(['vi', 'III', 'V', 'II', 'IV']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['bVII', 'V', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 2',
      builtIn: true,
      progression:
          ScaleDegreeProgression.fromList(['bVI', 'IV', 'bVII', 'V', 'I']),
    ),
    ProgressionBankEntry(
      title: 'One-Four-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['I', 'IV', 'I']),
    ),
    ProgressionBankEntry(
      title: 'One-Six-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['I', 'iv', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 3',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['bII', 'V', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 4',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['bVII', 'VIIdim7', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Diatonic Diminished',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['VIIdim7', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Minor-Based Diminished',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['bII7', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 5',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['ii', 'bII', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 6',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iidim', 'bII', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 7',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['bVI', 'bVII', 'I']),
    ),
    ProgressionBankEntry(
      // TDC: Get the help of yuval to name.
      title: 'Yuval Added 8',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['bVII', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Augmented Authentic Cadence',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['Vaug', 'I']),
    ),
    ProgressionBankEntry(
      title: 'Six-Five-One',
      builtIn: true,
      progression: ScaleDegreeProgression.fromList(['iv', 'V', 'I']),
    ),
  ];
}
