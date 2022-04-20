import 'package:thoery_test/modals/scale_degree_progression.dart';

class ProgressionBankEntry {
  final String title;
  final ScaleDegreeProgression progression;
  final bool builtIn;
  final bool usedInSubstitutions;

  ProgressionBankEntry({
    required this.title,
    required this.progression,
    this.builtIn = false,
    this.usedInSubstitutions = false,
  });

  ProgressionBankEntry copyWith({
    String? title,
    ScaleDegreeProgression? progression,
    bool? builtIn,
    bool? usedInSubstitutions,
  }) =>
      ProgressionBankEntry(
        title: title ?? this.title,
        progression: progression ?? this.progression,
        builtIn: builtIn ?? this.builtIn,
        usedInSubstitutions: usedInSubstitutions ?? this.usedInSubstitutions,
      );

  ProgressionBankEntry.fromJson({
    required Map<String, dynamic> json,
    required this.title,
  })  : builtIn = json['b'],
        usedInSubstitutions = json['s'],
        progression = ScaleDegreeProgression.fromJson(json['p']);

  Map<String, dynamic> toJson() => {
        'b': builtIn,
        's': usedInSubstitutions,
        'p': progression.toJson(),
      };

  @override
  String toString() =>
      '"$title" (b: $builtIn, s: $usedInSubstitutions)- $progression';
}
