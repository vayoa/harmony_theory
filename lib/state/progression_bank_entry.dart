import 'package:thoery_test/modals/scale_degree_progression.dart';

class ProgressionBankEntry {
  final ScaleDegreeProgression progression;
  final bool builtIn;
  final bool usedInSubstitutions;

  const ProgressionBankEntry({
    required this.progression,
    this.builtIn = false,
    this.usedInSubstitutions = false,
  });

  ProgressionBankEntry copyWith({
    ScaleDegreeProgression? progression,
    bool? builtIn,
    bool? usedInSubstitutions,
  }) =>
      ProgressionBankEntry(
        progression: progression ?? this.progression,
        builtIn: builtIn ?? this.builtIn,
        usedInSubstitutions: usedInSubstitutions ?? this.usedInSubstitutions,
      );

  ProgressionBankEntry.fromJson({
    required Map<String, dynamic> json,
  })  : builtIn = json['b'],
        usedInSubstitutions = json['s'],
        progression = ScaleDegreeProgression.fromJson(json['p']);

  Map<String, dynamic> toJson() => {
        'b': builtIn,
        's': usedInSubstitutions,
        'p': progression.toJson(),
      };

  @override
  String toString() => '(b: $builtIn, s: $usedInSubstitutions)- $progression';
}
