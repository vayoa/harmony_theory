import 'package:thoery_test/modals/scale_degree_progression.dart';

class ProgressionBankEntry {
  final String title;
  final ScaleDegreeProgression progression;
  final bool builtIn;

  const ProgressionBankEntry({
    required this.title,
    required this.progression,
    this.builtIn = false,
  });

  ProgressionBankEntry.fromJson(Map<String, dynamic> json)
      : title = json['t'],
        builtIn = json['b'],
        progression = json['p'];

  Map<String, dynamic> toJson() => {
        't': title,
        'b': builtIn,
        'p': progression,
      };
}
