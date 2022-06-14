import 'package:harmony_theory/modals/identifiable.dart';

import 'scale_degree_chord.dart';

class TonicizedScaleDegreeChord extends ScaleDegreeChord
    implements Identifiable {
  // This can't be just a degree because a tonicized scale degree chord where
  // tonicizedToTonic is I can be minor/major....
  final ScaleDegreeChord tonic;
  final ScaleDegreeChord tonicizedToTonic;

  TonicizedScaleDegreeChord.raw(
      {required this.tonic,
      required this.tonicizedToTonic,
      required ScaleDegreeChord tonicizedToMajorScale})
      : super.raw(tonicizedToMajorScale.pattern, tonicizedToMajorScale.root);

  TonicizedScaleDegreeChord(
      {required ScaleDegreeChord tonic,
      required ScaleDegreeChord tonicizedToTonic,
      ScaleDegreeChord? tonicizedToMajorScale})
      : this.raw(
            tonic: tonic,
            tonicizedToTonic: tonicizedToTonic,
            tonicizedToMajorScale:
                tonicizedToMajorScale ?? tonicizedToTonic.tonicizedFor(tonic));

  TonicizedScaleDegreeChord.fromJson(Map<String, dynamic> json)
      : tonic = ScaleDegreeChord.fromJson(json['tonic']),
        tonicizedToTonic = ScaleDegreeChord.fromJson(json['toTonic']),
        super.fromJson(json['toMajor']);

  @override
  Map<String, dynamic> toJson() => {
        'tonic': tonic.toJson(),
        'toTonic': tonicizedToTonic.toJson(),
        'toMajor': super.toJson(),
      };

  @override
  String toString() => '$tonicizedToTonic/${tonic.rootString}';
}
