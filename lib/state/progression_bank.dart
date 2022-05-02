import 'package:thoery_test/modals/identifiable.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';

import '../modals/progression.dart';

abstract class ProgressionBank {
  /// Key - entry title, value - entry.
  static Map<String, ProgressionBankEntry> _bank = {};

  /// Key - entry progression id, value - entry's title.
  ///
  /// Holds the ids for the progressions that are used in the substitutions.
  static Map<int, String> _substitutionsIDBank = {};

  /// Key - scale degree chord id, value - list of entry progression ids.
  ///
  /// Notice: if the major tonic is in the last place it will be saved in a
  /// different group then if it's in any other place (for tonicization).
  static Map<int, List<int>> _groupedBank = {};

  static final int _tonicID = ScaleDegreeChord.majorTonicTriad.weakID;

  static final int tonicizationID = Identifiable.hash2(_tonicID, true.hashCode);

  static Map<int, String> get substitutionsIDBank => _substitutionsIDBank;

  static Map<String, ProgressionBankEntry> get bank => _bank;

  static Map<int, List<int>> get groupedBank => _groupedBank;

  /// Returns all saved progressions that have a
  /// [ScaleDegreeChord.majorTonicTriad] as their last chord in the form of
  /// [title, progression].
  static List<List<dynamic>> get tonicizations {
    if (_groupedBank.containsKey(tonicizationID)) {
      return [
        for (int id in _groupedBank[tonicizationID]!)
          [
            _substitutionsIDBank[id]!,
            _bank[_substitutionsIDBank[id]!]!.progression
          ]
      ];
    }
    return const [];
  }

  static void initializeBuiltIn() {
    // TODO: Make sure no two same ids are in a list in _groupedBank.
    _bank = {};
    _substitutionsIDBank = {};
    _groupedBank = {};
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
    _substitutionsIDBank = {
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

  static Map<String, dynamic> toJson() => {
        'substitutionsTitles': {
          for (MapEntry<int, String> entry in _substitutionsIDBank.entries)
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
  /// Will return the id of the progression.
  static int add({required String title, required ProgressionBankEntry entry}) {
    // Remove the entry if currently present.
    int id = remove(title) ?? entry.progression.id;
    _bank[title] = entry;
    if (entry.usedInSubstitutions) {
      _addProgToGroups(entry.progression, title, id);
    }
    return id;
  }

  /// Removes an entry with the title of [entryTitle] from the [_bank] (and
  /// will check to remove from the [_groupedBank] based on the entry's
  /// [usedInSubstitutions]...).
  ///
  /// If no such entry exists (only checks for it's title), will do nothing.
  ///
  /// Will return the id of the progression if removed.
  static int? remove(String entryTitle) {
    if (_bank.containsKey(entryTitle)) {
      ProgressionBankEntry entry = _bank[entryTitle]!;
      int id = entry.progression.id;
      _bank.remove(entryTitle);
      if (entry.usedInSubstitutions && entryTitle == _substitutionsIDBank[id]) {
        _substitutionsIDBank.remove(id);
        _removeProgFromGroups(entry.progression, id);
      }
      return id;
    }
    return null;
  }

  /// Adds the progression to it's relevant groups ([_groupedBank]) and to
  /// [_substitutionsIDBank] to be later used in substitutions.
  static void _addProgToGroups(ScaleDegreeProgression progression, String title,
      [int? id]) {
    id ??= progression.id;
    if (!_substitutionsIDBank.containsKey(title)) {
      _substitutionsIDBank[id] = title;
    }
    for (int i = 0; i < progression.length; i++) {
      ScaleDegreeChord? chord = progression[i];
      final Map<int, ScaleDegreeChord> addedChords = {};
      if (chord != null) {
        int weakChordID = weakIDWithPlace(chord, i == progression.length - 1);
        if (!addedChords.containsKey(weakChordID)) {
          addedChords[weakChordID] = chord;
          if (_groupedBank.containsKey(weakChordID)) {
            _groupedBank[weakChordID]!.add(id);
          } else {
            _groupedBank[weakChordID] = [id];
          }
        }
      }
    }
  }

  static void _removeProgFromGroups(ScaleDegreeProgression progression,
      [int? id]) {
    id ??= progression.id;
    _substitutionsIDBank.remove(id);
    for (int i = 0; i < progression.length; i++) {
      ScaleDegreeChord? chord = progression[i];
      final Map<int, ScaleDegreeChord> addedChords = {};
      if (chord != null) {
        int weakChordID = weakIDWithPlace(chord, i == progression.length - 1);
        if (!addedChords.containsKey(weakChordID)) {
          addedChords[weakChordID] = chord;
          if (_groupedBank.containsKey(weakChordID)) {
            _groupedBank[weakChordID]!.remove(id);
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
        int id = entry.progression.id;
        _substitutionsIDBank.remove(id);
        _substitutionsIDBank[id] = newTitle;
      }
    }
  }

  static bool idFreeInSubs(String title, int id) =>
      !_substitutionsIDBank.containsKey(id) ||
      _substitutionsIDBank[id] == title;

  static bool canUseInSubstitutions(String title) =>
      _bank.containsKey(title) &&
      idFreeInSubs(title, _bank[title]!.progression.id);

  static bool canBeSubstitution(Progression progression) =>
      progression.length >= 2 && progression.length <= 8;

  static void changeUseInSubstitutions(
      {required String title, required bool useInSubstitutions}) {
    if (_bank.containsKey(title)) {
      ProgressionBankEntry entry = _bank[title]!;
      if (entry.usedInSubstitutions != useInSubstitutions &&
          idFreeInSubs(title, _bank[title]!.progression.id)) {
        _bank[title] = entry.copyWith(usedInSubstitutions: useInSubstitutions);
        if (useInSubstitutions) {
          _addProgToGroups(entry.progression, title);
        } else {
          _removeProgFromGroups(entry.progression);
        }
      }
    }
  }

  /* TODO: Decide whether to put this method here and whether to always hash
          'last'...*/

  /// [last] will only have effect when [chord.id] is equal to
  /// [ScaleDegreeChord.majorTonicTriad]'s weak hash.
  static int weakIDWithPlace(ScaleDegreeChord chord, [bool last = false]) {
    int weakID = chord.weakID;
    return Identifiable.hash2(
        weakID, weakID == _tonicID ? last.hashCode : false.hashCode);
  }

  /// Returns all saved progressions from [_bank] containing the
  /// [ScaleDegreeChord.id] of [chord] in the form of [title, progression].
  /// If [withTonicization] is true, returns also all saved progressions that
  /// have a [ScaleDegreeChord.majorTonicTriad] as their last chord.
  static List<List<dynamic>>? getByGroup(
      {required ScaleDegreeChord chord, required bool withTonicization}) {
    List<int>? ids = _groupedBank[weakIDWithPlace(chord, false)];
    if (ids != null) {
      if (withTonicization && _groupedBank.containsKey(tonicizationID)) {
        // TODO: Optimize...
        ids.addAll(_groupedBank[tonicizationID]!);
      }
      return [
        for (int id in ids)
          [
            _substitutionsIDBank[id]!,
            _bank[_substitutionsIDBank[id]!]!.progression
          ]
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

    'Four(minor)-Five-One': ScaleDegreeProgression.fromList(['iv', 'V', 'I']),

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

    'One-Four-One Altered': ScaleDegreeProgression.fromList(['I', 'iv', 'I']),

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
  };
}
