import '../modals/identifiable.dart';
import '../modals/progression/degree_progression.dart';
import '../modals/progression/progression.dart';
import '../modals/theory_base/scale_degree/degree_chord.dart';
import 'progression_bank_entry.dart';

abstract class ProgressionBank {
  static const List<String> allBankVersions = ['beta', '1.0'];
  static const String defaultPackageName = 'General';
  static const String builtInPackageName = 'Built-In';
  static const String packageSeparator = r'\';
  static const int maxTitleCharacters = 35;

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

  static final int _tonicID = DegreeChord.majorTonicTriad.weakID;

  static final int tonicizationID = Identifiable.hash2(_tonicID, true.hashCode);

  static Map<int, String> get substitutionsIDBank => _substitutionsIDBank;

  static Map<String, Map<String, ProgressionBankEntry>> get bank => _bank;

  static Map<int, List<int>> get groupedBank => _groupedBank;

  /// Returns all saved progressions that have a
  /// [DegreeChord.majorTonicTriad] as their last chord.
  static List<PackagedProgression> get tonicizations {
    if (_groupedBank.containsKey(tonicizationID)) {
      List<PackagedProgression> results = [];
      for (int id in _groupedBank[tonicizationID]!) {
        EntryLocation location =
            EntryLocation.fromLocation(_substitutionsIDBank[id]!)!;
        results.add(
          PackagedProgression(
              location: location,
              progression: getAtLocation(location)!.progression),
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
    for (MapEntry<String, DegreeProgression> mapEntry in _builtInBank.entries) {
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
    _version = jsonVersion(json);
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

  // During the beta version the version field wasn't saved, and so this
  // initializes it...
  static String jsonVersion(Map<String, dynamic> json) =>
      json['ver'] ?? allBankVersions[0];

  // If the version the database saved isn't the last version out, we need
  // to migrate...
  static bool migrationRequired(Map<String, dynamic> json) =>
      jsonVersion(json) != allBankVersions.last;

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

  /* TODO: Maybe save substitutions and groups also when exporting to save
          calculation time... */
  static void importPackages(Map<String, dynamic> json) {
    // We use the bank of the exported package...
    json = Map<String, dynamic>.from(json['bank']);

    // Merge all entries -> no complications, if theres already one used in
    // substitutions don't use the other, if theres already one named like
    // another add a number to the last (if can't trim and add).
    for (MapEntry<String, dynamic> package in json.entries) {
      final bool existingPackage = bank.containsKey(package.key);
      Map<String, dynamic> packageJson =
          Map<String, dynamic>.from(package.value);
      for (MapEntry<String, dynamic> savedEntry in packageJson.entries) {
        String title = savedEntry.key;
        ProgressionBankEntry entry =
            ProgressionBankEntry.fromJson(json: savedEntry.value);
        int id = entry.progression.id;
        if (entry.usedInSubstitutions && _substitutionsIDBank.containsKey(id)) {
          entry = entry.copyWith(usedInSubstitutions: false);
        }
        if (existingPackage && bank[package.key]!.containsKey(savedEntry.key)) {
          int otherID = bank[package.key]![savedEntry.key]!.progression.id;
          if (otherID == id) {
            break;
          }
          int num = (int.tryParse(title[title.length - 1]) ?? 1) + 1;
          String add = ' $num';
          if (title.length + add.length > maxTitleCharacters) {
            title =
                '${title.substring(0, title.length - add.length - 3)}...$add';
          }
        }

        add(package: package.key, title: title, entry: entry, id: id);
      }
    }
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

  static Map<String, dynamic> exportPackages(
      Map<String, List<String>> packages) {
    Map<String, dynamic> json = {'ver': _version, 'bank': {}};
    for (String package in packages.keys) {
      Map<String, dynamic> packageJson = {};
      for (String entry in packages[package]!) {
        packageJson[entry] = _bank[package]![entry]!.toJson();
      }
      json['bank'][package] = packageJson;
    }
    return json;
  }

  static String nameToLocation(String package, String name) =>
      package + packageSeparator + name;

  static bool packageNameValid(String package) =>
      package.trim().isNotEmpty && !package.contains(packageSeparator);

  static bool newPackageNameValid(String package) =>
      packageNameValid(package) && !bank.containsKey(package);

  static ProgressionBankEntry? getAtLocation(EntryLocation location) =>
      _bank[location.package]?[location.title];

  static bool isBuiltIn(EntryLocation location) =>
      location.package == ProgressionBank.builtInPackageName;

  /// Moves the entry at [location] to [newPackage].
  /// If [newPackage] doesn't exists, creates it.
  static int move({
    required EntryLocation location,
    required String newPackage,
  }) {
    ProgressionBankEntry entry = getAtLocation(location)!;
    int? id = remove(
      package: location.package,
      title: location.title,
      removeFromGroups: false,
    );
    id = add(
      package: newPackage,
      title: location.title,
      entry: entry,
      id: id,
      addToGroups: false,
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
  /// If [addToGroups] is false, we won't add the progression to [_groupedBank].
  ///
  /// Will return the id of the progression.
  static int add({
    String package = defaultPackageName,
    required String title,
    required ProgressionBankEntry entry,
    int? id,
    bool addToGroups = true,
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
        id: id,
        addToGroups: addToGroups,
      );
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
  /// If [removeFromGroups] is false, we won't remove the progression from
  /// [_groupedBank].
  ///
  /// Will return the id of the progression if removed.
  static int? remove({
    required String package,
    required String title,
    int? id,
    bool removeFromGroups = true,
    bool removeFromBank = true,
  }) {
    if (_bank.containsKey(package) && _bank[package]!.containsKey(title)) {
      ProgressionBankEntry entry = _bank[package]![title]!;
      id ??= entry.progression.id;
      if (removeFromBank) _bank[package]!.remove(title);
      if (entry.usedInSubstitutions &&
          nameToLocation(package, title) == _substitutionsIDBank[id]) {
        _substitutionsIDBank.remove(id);
        if (removeFromGroups) {
          _removeProgFromGroups(entry.progression, id);
        }
      }
      return id;
    }
    return null;
  }

  /// Removes [package] and all of the entries it contains.
  static void removePackage(String package) {
    // To avoid concurrent modification during iteration error (this function
    // copies the keys to remove for us...).
    _bank[package]!.removeWhere((key, value) {
      remove(package: package, title: key, removeFromBank: false);
      return true;
    });
    _bank.remove(package);
  }

  /// Gets [progression] and [location] (entry's LOCATION).
  /// Adds the progression to it's relevant groups ([_groupedBank]) and to
  /// [_substitutionsIDBank] to be later used in substitutions.
  ///
  /// If [addToGroups] is false, we won't add the progression to [_groupedBank].
  static void _addProgToGroups({
    required DegreeProgression progression,
    required String location,
    int? id,
    bool addToGroups = true,
  }) {
    id ??= progression.id;
    if (!_substitutionsIDBank.containsKey(location)) {
      _substitutionsIDBank[id] = location;
    }
    if (addToGroups) {
      for (int i = 0; i < progression.length; i++) {
        DegreeChord? chord = progression[i];
        final Map<int, DegreeChord> addedChords = {};
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
  }

  static void _removeProgFromGroups(DegreeProgression progression, [int? id]) {
    id ??= progression.id;
    _substitutionsIDBank.remove(id);
    for (int i = 0; i < progression.length; i++) {
      DegreeChord? chord = progression[i];
      final Map<int, DegreeChord> addedChords = {};
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
  /// [DegreeChord.majorTonicTriad]'s weak hash.
  static int weakIDWithPlace(DegreeChord chord, [bool last = false]) {
    int weakID = chord.weakID;
    return Identifiable.hash2(
        weakID, weakID == _tonicID ? last.hashCode : false.hashCode);
  }

  /// Returns all saved progressions from [_bank] containing the
  /// [DegreeChord.id] of [chord].
  /// If [withTonicization] is true, returns also all saved progressions that
  /// have a [DegreeChord.majorTonicTriad] as their last chord.
  static List<PackagedProgression>? getByGroup(
      {required DegreeChord chord, required bool withTonicization}) {
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

  static final Map<String, DegreeProgression> _builtInBank = {
    'Deceptive Cadence': DegreeProgression.fromList(['V', 'vi']),
    // V I
    'Authentic Cadence': DegreeProgression.fromList(['V', 'I']),
    'Authentic Cadence 2':
        DegreeProgression.fromList(['V', 'I'], durations: [1 / 4, 1 / 2]),
    // ii V I
    'Two-Five-One': DegreeProgression.fromList(['ii', 'V', 'I']),
    'Two-Five-One 2': DegreeProgression.fromList(['ii', 'V', 'I'],
        durations: [1 / 4, 1 / 4, 1 / 2]),
    'Altered Two-Five-One in Minor': DegreeProgression.fromList(
        ['viidim', 'iii', 'III', 'vi'],
        durations: [1 / 4, 1 / 4, 1 / 4, 1 / 4]),
    'Two(diminished)-Five-One': DegreeProgression.fromList(['iidim', 'V', 'I']),
    'Two(half-diminished)-Five-One':
        DegreeProgression.fromList(['iim7b5', 'V', 'I']),

    'Two-Five-One with 7ths': DegreeProgression.fromList(['iim7b5', 'V7', 'I']),

    // IV V I
    'Four-Five-One': DegreeProgression.fromList(['IV', 'V', 'I']),

    'Four(minor)-Five-One': DegreeProgression.fromList(['iv', 'V', 'I']),

    'Altered Minor Plagal Cadence':
        DegreeProgression.fromList(['IV', 'iv', 'I']),

    // IV I
    'Plagal Cadence': DegreeProgression.fromList(['IV', 'I']),

    'Minor Plagal Cadence': DegreeProgression.fromList(['iv', 'I']),

    // Added
    'Altered Authentic Cadence in Minor':
        DegreeProgression.fromList(['iii', 'III', 'vi']),

    'Altered Authentic Cadence in Minor 2':
        DegreeProgression.fromList(['iii', 'III', 'vi', 'vi']),

    'Diminished Resolution with 7ths':
        DegreeProgression.fromList(['iim7b5', 'I']),

    'Diminished Resolution': DegreeProgression.fromList(['iidim', 'I']),

    'Diatonic Quartal Harmony':
        DegreeProgression.fromList(['IV', 'II', 'V', 'III', 'vi']),

    'Reversed Diatonic Quartal Harmony':
        DegreeProgression.fromList(['vi', 'III', 'V', 'II', 'IV']),

    'Mix Pre-Dominant': DegreeProgression.fromList(['bVII', 'V', 'I']),

    'Long Chromatic Inner Voice':
        DegreeProgression.fromList(['bVI', 'IV', 'bVII', 'V', 'I']),

    'One-Four-One': DegreeProgression.fromList(['I', 'IV', 'I']),

    'One-Four-One Altered': DegreeProgression.fromList(['I', 'iv', 'I']),

    'Neapolitan Cadence': DegreeProgression.fromList(['bII', 'V', 'I']),

    'Short Chromatic Inner Voice (dim)':
        DegreeProgression.fromList(['bVII', 'VIIdim7', 'I']),

    'Diatonic Diminished': DegreeProgression.fromList(['VIIdim7', 'I']),

    'Minor-Based Diminished': DegreeProgression.fromList(['bII7', 'I']),

    'Two-SubFive-One': DegreeProgression.fromList(['ii', 'bII', 'I']),

    'Two(diminished)-SubFive-One':
        DegreeProgression.fromList(['iidim', 'bII', 'I']),

    'Simple Mixture Ascent': DegreeProgression.fromList(['bVI', 'bVII', 'I']),

    'Short Simple Mixture Ascent': DegreeProgression.fromList(['bVII', 'I']),

    'Augmented Authentic Cadence': DegreeProgression.fromList(['Vaug', 'I']),
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
  int get hashCode => Object.hash(package, title);

  @override
  String toString([String separator = ProgressionBank.packageSeparator]) =>
      package + separator + title;
}

class PackagedProgression {
  final EntryLocation location;
  final DegreeProgression progression;

  PackagedProgression({
    required this.location,
    required this.progression,
  });

  @override
  bool operator ==(Object other) =>
      other is PackagedProgression &&
      other.location == location &&
      other.progression == progression;

  @override
  int get hashCode => Object.hash(location, progression);
}
