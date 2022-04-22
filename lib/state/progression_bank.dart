import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';

// TDC: Decide if this stays static or not, since it has a constructor...
abstract class ProgressionBank {
  /// Key - entry title, value - entry.
  static Map<String, ProgressionBankEntry> _bank = {};

  /// Key - entry progression hash, value - entry's title.
  ///
  /// Holds the hashes for the progressions that are used in the substitutions.
  static Map<int, String> _substitutionsHashesBank = {};

  /// Key - scale degree chord hash, value - list of entry progression hashes.
  ///
  /// Notice: if the major tonic is in the last place it will be saved in a
  /// different group then if it's in any other place (for tonicization).
  static Map<int, List<int>> _groupedBank = {};

  static final int _tonicHash = ScaleDegreeChord.majorTonicTriad.weakHash;

  static final int tonicizationHash = Object.hash(_tonicHash, true);

  static Map<int, String> get substitutionsHashesBank =>
      _substitutionsHashesBank;

  static Map<String, ProgressionBankEntry> get bank => _bank;

  static Map<int, List<int>> get groupedBank => _groupedBank;

  /// Returns all saved progressions that have a
  /// [ScaleDegreeChord.majorTonicTriad] as their last chord.
  static List<ScaleDegreeProgression> get tonicizations {
    if (_groupedBank.containsKey(tonicizationHash)) {
      return [
        for (int hash in _groupedBank[tonicizationHash]!)
          _bank[_substitutionsHashesBank[hash]!]!.progression
      ];
    }
    return const [];
  }

  static void initializeBuiltIn() {
    // TODO: Make sure no two same hashes are in a list in _groupedBank.
    for (MapEntry<String, ScaleDegreeProgression> mapEntry
        in _builtInBank.entries) {
      ProgressionBankEntry entry = ProgressionBankEntry(
        builtIn: true,
        usedInSubstitutions: true,
        progression: mapEntry.value,
      );
      add(title: mapEntry.key, entry: entry);
    }
  }

  static void initializeFromJson(Map<String, dynamic> json) {
    _substitutionsHashesBank = {
      for (MapEntry<String, dynamic> entry
          in json['substitutionsTitles'].entries)
        int.parse(entry.key): entry.value
    };
    _bank = {
      for (MapEntry<String, dynamic> entry in json['bank'].entries)
        entry.key: ProgressionBankEntry.fromJson(json: entry.value)
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
  static Map<String, dynamic> toJson() => {
        'substitutionsTitles': {
          for (MapEntry<int, String> entry in _substitutionsHashesBank.entries)
            entry.key.toString(): entry.value
        },
        'bank': {
          for (MapEntry<String, ProgressionBankEntry> entry in _bank.entries)
            entry.key: entry.value.toJson()
        },
        'groupedBank': {
          for (MapEntry<int, List<int>> entry in _groupedBank.entries)
            entry.key.toString(): entry.value
        }
      };

  /// Adds [entry] to the [_bank] (and to the [_groupedBank] based on
  /// [entry.usedInSubstitutions]...).
  ///
  /// If the entry exist in the bank already, will do nothing.
  ///
  /// If another entry in the bank has the same title, will override that
  /// entry with the new one ([entry]).
  ///
  /// Will return the hash of the progression.
  static int add({required String title, required ProgressionBankEntry entry}) {
    // Remove the entry if currently present.
    int hash = remove(title) ?? entry.progression.hashCode;
    _bank[title] = entry;
    if (entry.usedInSubstitutions) {
      _addProgToGroups(entry.progression, title, hash);
    }
    return hash;
  }

  /// Removes an entry with the title of [entryTitle] from the [_bank] (and
  /// will check to remove from the [_groupedBank] based on the entry's
  /// [usedInSubstitutions]...).
  ///
  /// If no such entry exists (only checks for it's title), will do nothing.
  ///
  /// Will return the hash of the progression if removed.
  static int? remove(String entryTitle) {
    if (_bank.containsKey(entryTitle)) {
      ProgressionBankEntry entry = _bank[entryTitle]!;
      int hash = entry.progression.hashCode;
      _bank.remove(entryTitle);
      _substitutionsHashesBank.remove(hash);
      if (entry.usedInSubstitutions) {
        _removeProgFromGroups(entry.progression, hash);
      }
      return hash;
    }
    return null;
  }

  /// Adds the progression to it's relevant groups ([_groupedBank]) and to
  /// [_substitutionsHashesBank] to be later used in substitutions.
  static void _addProgToGroups(ScaleDegreeProgression progression, String title,
      [int? hash]) {
    hash ??= progression.hashCode;
    if (!_substitutionsHashesBank.containsKey(title)) {
      _substitutionsHashesBank[hash] = title;
    }
    for (int i = 0; i < progression.length; i++) {
      ScaleDegreeChord? chord = progression[i];
      final Map<int, ScaleDegreeChord> addedChords = {};
      if (chord != null) {
        int weakChordHash =
            weakHashWithPlace(chord, i == progression.length - 1);
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

  static void _removeProgFromGroups(ScaleDegreeProgression progression,
      [int? hash]) {
    hash ??= progression.hashCode;
    for (int i = 0; i < progression.length; i++) {
      ScaleDegreeChord? chord = progression[i];
      final Map<int, ScaleDegreeChord> addedChords = {};
      if (chord != null) {
        int weakChordHash =
            weakHashWithPlace(chord, i == progression.length - 1);
        if (!addedChords.containsKey(weakChordHash)) {
          addedChords[weakChordHash] = chord;
          if (_groupedBank.containsKey(weakChordHash)) {
            _groupedBank[weakChordHash]!.remove(hash);
          }
        }
      }
    }
  }

  /// Checks whether an entry with the title [previousTitle] can be renamed to
  /// [newTitle].
  static bool canRename(
          {required String previousTitle, required String newTitle}) =>
      !_bank.containsKey(newTitle) && _bank.containsKey(previousTitle);

  /// Renames an entry with [previousTitle] to [newTitle], if exists.
  static void rename(
      {required String previousTitle, required String newTitle}) {
    if (canRename(previousTitle: previousTitle, newTitle: newTitle)) {
      ProgressionBankEntry entry = _bank[previousTitle]!;
      _bank.remove(previousTitle);
      _bank[newTitle] = entry;
      if (entry.usedInSubstitutions) {
        int hash = entry.progression.hashCode;
        _substitutionsHashesBank.remove(hash);
        _substitutionsHashesBank[hash] = newTitle;
      }
    }
  }

  static bool hashExistsInSubs(int hash) =>
      _substitutionsHashesBank.containsKey(hash);

  static bool canUseInSubstitutions(String title) =>
      _bank.containsKey(title) &&
      !hashExistsInSubs(_bank[title]!.progression.hashCode);

  static void changeUseInSubstitutions(
      {required String title, required bool useInSubstitutions}) {
    if (_bank.containsKey(title)) {
      ProgressionBankEntry entry = _bank[title]!;
      if (entry.usedInSubstitutions != useInSubstitutions &&
          !hashExistsInSubs(_bank[title]!.progression.hashCode)) {
        _bank[title] = entry.copyWith(usedInSubstitutions: useInSubstitutions);
        if (useInSubstitutions) {
          _addProgToGroups(entry.progression, title);
        } else {
          _substitutionsHashesBank.remove(hash);
          _removeProgFromGroups(entry.progression);
        }
      }
    }
  }

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
  static List<ScaleDegreeProgression>? getByGroup(
      {required ScaleDegreeChord chord, required bool withTonicization}) {
    List<int>? hashes = _groupedBank[weakHashWithPlace(chord, false)];
    if (hashes != null) {
      if (withTonicization && _groupedBank.containsKey(tonicizationHash)) {
        // TODO: Optimize...
        hashes.addAll(_groupedBank[tonicizationHash]!);
      }
      return [
        for (int hash in hashes)
          _bank[_substitutionsHashesBank[hash]!]!.progression
      ];
    }
    return null;
  }

  static final Map<String, ScaleDegreeProgression> _builtInBank = {
    'Deceptive Cadence': ScaleDegreeProgression.fromList(['V', 'vi']),
    // V I
    'Authentic Cadence': ScaleDegreeProgression.fromList(['V', 'I']),
    'Authentic Cadence 2':
        ScaleDegreeProgression.fromList(['V', 'I'], durations: [1 / 4, 1 / 2]),
    // ii V I
    'Two-Five-One': ScaleDegreeProgression.fromList(['ii', 'V', 'I']),
    'Two-Five-One 2': ScaleDegreeProgression.fromList(['ii', 'V', 'I'],
        durations: [1 / 4, 1 / 4, 1 / 2]),
    'Altered Two-Five-One in Minor': ScaleDegreeProgression.fromList(
        ['viidim', 'iii', 'III', 'vi'],
        durations: [1 / 4, 1 / 4, 1 / 4, 1 / 4]),
    'Two(diminished)-Five-One':
        ScaleDegreeProgression.fromList(['iidim', 'V', 'I']),
    'Two(half-diminished)-Five-One':
        ScaleDegreeProgression.fromList(['iim7b5', 'V', 'I']),

    'Two-Five-One with 7ths':
        ScaleDegreeProgression.fromList(['iim7b5', 'V7', 'I']),

    // IV V I
    'Four-Five-One': ScaleDegreeProgression.fromList(['IV', 'V', 'I']),

    'Altered Minor Plagal Cadence':
        ScaleDegreeProgression.fromList(['IV', 'iv', 'I']),

    // IV I
    'Plagal Cadence': ScaleDegreeProgression.fromList(['IV', 'I']),

    'Minor Plagal Cadence': ScaleDegreeProgression.fromList(['iv', 'I']),

    // Added
    'Altered Authentic Cadence in Minor':
        ScaleDegreeProgression.fromList(['iii', 'III', 'vi']),

    'Altered Authentic Cadence in Minor 2':
        ScaleDegreeProgression.fromList(['iii', 'III', 'vi', 'vi']),

    'Diminished Resolution with 7ths':
        ScaleDegreeProgression.fromList(['iim7b5', 'I']),

    'Diminished Resolution': ScaleDegreeProgression.fromList(['iidim', 'I']),

    'Diatonic Quartal Harmony':
        ScaleDegreeProgression.fromList(['IV', 'II', 'V', 'III', 'vi']),

    'Reversed Diatonic Quartal Harmony':
        ScaleDegreeProgression.fromList(['vi', 'III', 'V', 'II', 'IV']),

    // TDC: Get the help of yuval to name.
    'Yuval Added': ScaleDegreeProgression.fromList(['bVII', 'V', 'I']),

    // TDC: Get the help of yuval to name.
    'Yuval Added 2':
        ScaleDegreeProgression.fromList(['bVI', 'IV', 'bVII', 'V', 'I']),

    'One-Four-One': ScaleDegreeProgression.fromList(['I', 'IV', 'I']),

    'One-Six-One': ScaleDegreeProgression.fromList(['I', 'iv', 'I']),

    // TDC: Get the help of yuval to name.
    'Yuval Added 3': ScaleDegreeProgression.fromList(['bII', 'V', 'I']),

    // TDC: Get the help of yuval to name.
    'Yuval Added 4': ScaleDegreeProgression.fromList(['bVII', 'VIIdim7', 'I']),

    // TDC: Get the help of yuval to name.
    'Diatonic Diminished': ScaleDegreeProgression.fromList(['VIIdim7', 'I']),

    // TDC: Get the help of yuval to name.
    'Minor-Based Diminished': ScaleDegreeProgression.fromList(['bII7', 'I']),

    // TDC: Get the help of yuval to name.
    'Yuval Added 5': ScaleDegreeProgression.fromList(['ii', 'bII', 'I']),
    // TDC: Get the help of yuval to name.
    'Yuval Added 6': ScaleDegreeProgression.fromList(['iidim', 'bII', 'I']),
    // TDC: Get the help of yuval to name.
    'Yuval Added 7': ScaleDegreeProgression.fromList(['bVI', 'bVII', 'I']),
    // TDC: Get the help of yuval to name.
    'Yuval Added 8': ScaleDegreeProgression.fromList(['bVII', 'I']),
    'Augmented Authentic Cadence':
        ScaleDegreeProgression.fromList(['Vaug', 'I']),
    'Six-Five-One': ScaleDegreeProgression.fromList(['iv', 'V', 'I']),
  };
}
