import 'package:thoery_test/modals/identifiable.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';

import '../modals/progression.dart';

abstract class ProgressionBank {
  static const List<String> allBankVersions = ['beta', '1.0'];
  static const String defaultPackageName = 'General';
  static const String builtInPackageName = 'Built-In';
  static const String packageSeparator = r'\';

  static late String _version;

  /// Key - Package Name, value - Map{Key - entry title, value - entry}.
  static Map<String, Map<String, ProgressionBankEntry>> _bank = {};

  /// Key - entry progression id, value - "{package name}\{entry's title}"
  /// (which is the entry's location).
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

  static Map<String, Map<String, ProgressionBankEntry>> get bank => _bank;

  static Map<int, List<int>> get groupedBank => _groupedBank;

  /// Returns all saved progressions that have a
  /// [ScaleDegreeChord.majorTonicTriad] as their last chord.
  static List<PackagedProgression> get tonicizations {
    if (_groupedBank.containsKey(tonicizationID)) {
      List<PackagedProgression> results = [];
      for (int id in _groupedBank[tonicizationID]!) {
        EntryLocation location =
            EntryLocation.fromLocation(_substitutionsIDBank[id]!)!;
        results.add(
          PackagedProgression(
              location: location,
              progression:
                  _bank[location.package]![location.title]!.progression),
        );
      }
      return results;
    }
    return const [];
  }

  static void initializeBuiltIn() {
    _version = allBankVersions.last;
    // Since these packages always exist...
    _bank = {defaultPackageName: {}, builtInPackageName: {}};
    _substitutionsIDBank = {};
    _groupedBank = {};
    for (MapEntry<String, ScaleDegreeProgression> mapEntry
        in _builtInBank.entries) {
      ProgressionBankEntry entry = ProgressionBankEntry(
        usedInSubstitutions: true,
        progression: mapEntry.value,
      );
      add(package: builtInPackageName, title: mapEntry.key, entry: entry);
    }
  }

  static void initializeFromJson(Map<String, dynamic> json) {
    // During the beta version the version field wasn't saved, and so this
    // initializes it...
    _version = json['ver'] ?? allBankVersions[0];
    // If the version the database saved is the last version out...
    if (_version == allBankVersions.last) {
      _substitutionsIDBank = {
        for (MapEntry<String, dynamic> entry
            in json['substitutionsTitles'].entries)
          int.parse(entry.key): entry.value
      };
      _bank = {
        for (MapEntry<String, dynamic> package in json['bank'].entries)
          package.key: {
            for (MapEntry<String, dynamic> entry in package.value.entries)
              entry.key: ProgressionBankEntry.fromJson(json: entry.value)
          }
      };
      _groupedBank = {
        for (MapEntry<String, dynamic> entry in json['groupedBank'].entries)
          int.parse(entry.key): entry.value.cast<int>(),
      };
    } else {
      // If not, migrate it...
      migrator(json);
    }
  }

  /// Migrates the database [json] represents from previous versions to the
  /// current database scheme.
  static void migrator(Map<String, dynamic> json) {
    switch (_version) {
      case 'beta':
        // Since these packages always exist...
        _bank = {defaultPackageName: {}, builtInPackageName: {}};
        // We also initialize this here.
        _substitutionsIDBank = {};
        for (MapEntry<String, dynamic> entry in json['bank'].entries) {
          // If built in, put in built in package...
          String package =
              entry.value['b'] ? builtInPackageName : defaultPackageName;
          ProgressionBankEntry pEntry =
              ProgressionBankEntry.fromJson(json: entry.value);
          _bank[package]![entry.key] = pEntry;
          if (pEntry.usedInSubstitutions) {
            _substitutionsIDBank[pEntry.progression.id] =
                nameToLocation(package, entry.key);
          }
        }
        _groupedBank = {
          for (MapEntry<String, dynamic> entry in json['groupedBank'].entries)
            int.parse(entry.key): entry.value.cast<int>(),
        };
        break;
    }
  }

  static void initializeFromComputePass(
      ProgressionBankComputePass computePass) {
    _version = computePass.version;
    _bank = computePass.bank;
    _substitutionsIDBank = computePass.substitutionsIDBank;
    _groupedBank = computePass.groupedBank;
  }

  static ProgressionBankComputePass createComputePass() =>
      ProgressionBankComputePass(
        version: _version,
        bank: _bank,
        substitutionsIDBank: _substitutionsIDBank,
        groupedBank: _groupedBank,
      );

  static Map<String, dynamic> toJson() => {
        'ver': _version,
        'substitutionsTitles': {
          for (MapEntry<int, String> entry in _substitutionsIDBank.entries)
            entry.key.toString(): entry.value
        },
        'bank': {
          for (MapEntry<String, Map<String, ProgressionBankEntry>> package
              in _bank.entries)
            package.key: {
              for (MapEntry<String, ProgressionBankEntry> entry
                  in package.value.entries)
                entry.key: entry.value.toJson()
            }
        },
        'groupedBank': {
          for (MapEntry<int, List<int>> entry in _groupedBank.entries)
            entry.key.toString(): entry.value
        }
      };

  static String nameToLocation(String package, String name) =>
      package + packageSeparator + name;

  static bool packageNameValid(String package) =>
      package != defaultPackageName &&
      package != builtInPackageName &&
      !package.contains(packageSeparator);

  /// Moves the entry at [location] to [newPackage].
  /// If [newPackage] doesn't exists, creates it.
  static int move(
      {required EntryLocation location, required String newPackage}) {
    ProgressionBankEntry entry = _bank[location.package]![location.title]!;
    int? id = remove(package: location.package, title: location.title);
    id = add(
      package: location.package,
      title: location.title,
      entry: entry,
      id: id,
    );
    return id;
  }

  /// Adds [entry] to the [_bank] at [package] (and to the [_groupedBank] based
  /// on [entry.usedInSubstitutions]...).
  ///
  /// If no [package] was given, will use [defaultPackageName]. If no such
  /// [package] exists, will create one.
  ///
  /// If the entry exist in the bank in the [package] already, will do nothing.
  ///
  /// If another entry in the bank has the same [title] in the same [package],
  /// will override that entry with the new one ([entry]).
  ///
  /// Will return the id of the progression.
  static int add({
    String package = defaultPackageName,
    required String title,
    required ProgressionBankEntry entry,
    int? id,
  }) {
    // Remove the entry if currently present.
    int? removedID = remove(package: package, title: title, id: id);
    id ??= removedID ?? entry.progression.id;
    // Add the package to the bank if missing...
    if (!_bank.containsKey(package) && packageNameValid(package)) {
      _bank[package] = {};
    }
    _bank[package]![title] = entry;
    if (entry.usedInSubstitutions) {
      _addProgToGroups(
          progression: entry.progression,
          location: nameToLocation(package, title),
          id: id);
    }
    return id;
  }

  /// Removes an entry with the title of [title] from the [_bank] at
  /// [package] (and will check to remove from the [_groupedBank] based on the
  /// entry's [usedInSubstitutions]...).
  ///
  /// If no such entry exists in the [package] (only checks for it's title),
  /// will do nothing.
  ///
  /// Will return the id of the progression if removed.
  static int? remove(
      {required String package, required String title, int? id}) {
    if (_bank.containsKey(package) && _bank[package]!.containsKey(title)) {
      ProgressionBankEntry entry = _bank[package]![title]!;
      id ??= entry.progression.id;
      _bank.remove(title);
      if (entry.usedInSubstitutions &&
          nameToLocation(package, title) == _substitutionsIDBank[id]) {
        _substitutionsIDBank.remove(id);
        _removeProgFromGroups(entry.progression, id);
      }
      return id;
    }
    return null;
  }

  /// Gets [progression] and [location] (entry's LOCATION).
  /// Adds the progression to it's relevant groups ([_groupedBank]) and to
  /// [_substitutionsIDBank] to be later used in substitutions.
  static void _addProgToGroups(
      {required ScaleDegreeProgression progression,
      required String location,
      int? id}) {
    id ??= progression.id;
    if (!_substitutionsIDBank.containsKey(location)) {
      _substitutionsIDBank[id] = location;
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
  /// [newTitle] at [package] ([package] must exists otherwise will throw an
  /// error).
  static bool canRename(
          {required String package,
          required String previousTitle,
          required String newTitle}) =>
      !_bank[package]!.containsKey(newTitle) &&
      _bank[package]!.containsKey(previousTitle);

  /// Renames an entry with [previousTitle] to [newTitle] at [package],
  /// if exists ([package] must exists otherwise will throw an error).
  static void rename(
      {required String package,
      required String previousTitle,
      required String newTitle}) {
    if (canRename(
        package: package, previousTitle: previousTitle, newTitle: newTitle)) {
      ProgressionBankEntry entry = _bank[package]![previousTitle]!;
      _bank[package]!.remove(previousTitle);
      _bank[package]![newTitle] = entry;
      if (entry.usedInSubstitutions) {
        int id = entry.progression.id;
        _substitutionsIDBank.remove(id);
        _substitutionsIDBank[id] = nameToLocation(package, newTitle);
      }
    }
  }

  /// Gets an [id] and a [location] (entry's LOCATION!!!) and checks if it's
  /// free in [_substitutionsIDBank].
  static bool idFreeInSubs({required String location, required int id}) =>
      !_substitutionsIDBank.containsKey(id) ||
      _substitutionsIDBank[id] == location;

  static bool canUseInSubstitutions(
          {required String package, required String title}) =>
      _bank.containsKey(package) &&
      _bank[package]!.containsKey(title) &&
      idFreeInSubs(
          location: nameToLocation(package, title),
          id: _bank[package]![title]!.progression.id);

  static bool canBeSubstitution(Progression progression) =>
      progression.length >= 2 && progression.length <= 8;

  static void changeUseInSubstitutions(
      {required String package,
      required String title,
      required bool useInSubstitutions}) {
    if (_bank.containsKey(package) && _bank[package]!.containsKey(title)) {
      ProgressionBankEntry entry = _bank[package]![title]!;
      if (entry.usedInSubstitutions != useInSubstitutions &&
          idFreeInSubs(
              location: nameToLocation(package, title),
              id: _bank[package]![title]!.progression.id)) {
        _bank[package]![title] =
            entry.copyWith(usedInSubstitutions: useInSubstitutions);
        if (useInSubstitutions) {
          _addProgToGroups(
              progression: entry.progression,
              location: nameToLocation(package, title));
        } else {
          _removeProgFromGroups(entry.progression);
        }
      }
    }
  }

  /// [last] will only have effect when [chord.id] is equal to
  /// [ScaleDegreeChord.majorTonicTriad]'s weak hash.
  static int weakIDWithPlace(ScaleDegreeChord chord, [bool last = false]) {
    int weakID = chord.weakID;
    return Identifiable.hash2(
        weakID, weakID == _tonicID ? last.hashCode : false.hashCode);
  }

  /// Returns all saved progressions from [_bank] containing the
  /// [ScaleDegreeChord.id] of [chord].
  /// If [withTonicization] is true, returns also all saved progressions that
  /// have a [ScaleDegreeChord.majorTonicTriad] as their last chord.
  static List<PackagedProgression>? getByGroup(
      {required ScaleDegreeChord chord, required bool withTonicization}) {
    List<int>? ids = _groupedBank[weakIDWithPlace(chord, false)];
    if (ids != null) {
      if (withTonicization && _groupedBank.containsKey(tonicizationID)) {
        ids.addAll(_groupedBank[tonicizationID]!);
      }
      List<PackagedProgression> results = [];
      for (int id in ids) {
        EntryLocation location =
            EntryLocation.fromLocation(_substitutionsIDBank[id]!)!;
        results.add(
          PackagedProgression(
              location: location,
              progression:
                  _bank[location.package]![location.title]!.progression),
        );
      }
      return results;
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

    'Mix Pre-Dominant': ScaleDegreeProgression.fromList(['bVII', 'V', 'I']),

    'Long Chromatic Inner Voice':
        ScaleDegreeProgression.fromList(['bVI', 'IV', 'bVII', 'V', 'I']),

    'One-Four-One': ScaleDegreeProgression.fromList(['I', 'IV', 'I']),

    'One-Four-One Altered': ScaleDegreeProgression.fromList(['I', 'iv', 'I']),

    'Neapolitan Cadence': ScaleDegreeProgression.fromList(['bII', 'V', 'I']),

    'Short Chromatic Inner Voice (dim)':
        ScaleDegreeProgression.fromList(['bVII', 'VIIdim7', 'I']),

    'Diatonic Diminished': ScaleDegreeProgression.fromList(['VIIdim7', 'I']),

    'Minor-Based Diminished': ScaleDegreeProgression.fromList(['bII7', 'I']),

    'Two-SubFive-One': ScaleDegreeProgression.fromList(['ii', 'bII', 'I']),

    'Two(diminished)-SubFive-One':
        ScaleDegreeProgression.fromList(['iidim', 'bII', 'I']),

    'Simple Mixture Ascent':
        ScaleDegreeProgression.fromList(['bVI', 'bVII', 'I']),

    'Short Simple Mixture Ascent':
        ScaleDegreeProgression.fromList(['bVII', 'I']),

    'Augmented Authentic Cadence':
        ScaleDegreeProgression.fromList(['Vaug', 'I']),
  };
}

class ProgressionBankComputePass {
  final String version;
  final Map<String, Map<String, ProgressionBankEntry>> bank;
  final Map<int, String> substitutionsIDBank;
  final Map<int, List<int>> groupedBank;

  const ProgressionBankComputePass({
    required this.version,
    required this.bank,
    required this.substitutionsIDBank,
    required this.groupedBank,
  });
}

class EntryLocation {
  late final String package;
  late final String title;

  EntryLocation(this.package, this.title);

  static EntryLocation? fromLocation(String location,
      [String separator = ProgressionBank.packageSeparator]) {
    int index = location.indexOf(separator);
    if (index == -1 || index == location.length - 1) return null;
    return EntryLocation(
        location.substring(0, index), location.substring(index + 1));
  }

  @override
  bool operator ==(Object other) =>
      other is EntryLocation &&
      other.package == package &&
      other.title == title;

  @override
  String toString([String separator = ProgressionBank.packageSeparator]) =>
      package + separator + title;
}

class PackagedProgression {
  final EntryLocation location;
  final ScaleDegreeProgression progression;

  PackagedProgression({
    required this.location,
    required this.progression,
  });

  @override
  bool operator ==(Object other) =>
      other is PackagedProgression &&
      other.location == location &&
      other.progression == progression;
}
