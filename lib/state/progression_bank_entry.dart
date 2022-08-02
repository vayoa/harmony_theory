import '../modals/progression/degree_progression.dart';

class ProgressionBankEntry {
  final DegreeProgression progression;
  final bool usedInSubstitutions;
  final int? variationId;

  ProgressionBankEntry({
    required this.progression,
    this.usedInSubstitutions = false,
    int? variationId,
  }) : variationId = usedInSubstitutions
            ? variationId ?? progression.variationId()
            : null;

  ProgressionBankEntry copyWith({
    DegreeProgression? progression,
    bool? usedInSubstitutions,
    int? variationId,
  }) =>
      ProgressionBankEntry(
        progression: progression ?? this.progression,
        usedInSubstitutions: usedInSubstitutions ?? this.usedInSubstitutions,
        variationId:
            variationId != this.variationId ? variationId : this.variationId,
      );

  ProgressionBankEntry.fromJson({
    required Map<String, dynamic> json,
  })
      : usedInSubstitutions = json['s'],
        variationId = json['v'],
        progression = DegreeProgression.fromJson(json['p']);

  Map<String, dynamic> toJson() =>
      {
        's': usedInSubstitutions,
        'v': variationId,
        'p': progression.toJson(),
      };

  @override
  String toString() =>
      '(s: $usedInSubstitutions, v:$variationId)- $progression';
}
