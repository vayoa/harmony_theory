import '../modals/progression/degree_progression.dart';

class ProgressionBankEntry {
  final DegreeProgression progression;
  final bool usedInSubstitutions;

  ProgressionBankEntry({
    required this.progression,
    this.usedInSubstitutions = false,
  });

  ProgressionBankEntry copyWith({
    DegreeProgression? progression,
    bool? usedInSubstitutions,
  }) =>
      ProgressionBankEntry(
        progression: progression ?? this.progression,
        usedInSubstitutions: usedInSubstitutions ?? this.usedInSubstitutions,
      );

  ProgressionBankEntry.fromJson({
    required Map<String, dynamic> json,
  })  : usedInSubstitutions = json['s'],
        progression = DegreeProgression.fromJson(json['p']);

  Map<String, dynamic> toJson() => {
        's': usedInSubstitutions,
        'p': progression.toJson(),
      };

  @override
  String toString() => '(s: $usedInSubstitutions)- $progression';
}
