import 'degree_chord.dart';

class TonicizedDegreeChord extends DegreeChord {
  // This can't be just a degree because a tonicized scale degree chord where
  // tonicizedToTonic is I can be minor/major....
  @override
  final DegreeChord tonic;
  final DegreeChord tonicizedToTonic;

  TonicizedDegreeChord.raw({
    required this.tonic,
    required this.tonicizedToTonic,
    required DegreeChord tonicizedToMajorScale,
  }) : super.raw(
          tonicizedToMajorScale.pattern,
          tonicizedToMajorScale.root,
          bass: tonicizedToMajorScale.bass,
        );

  TonicizedDegreeChord({
    required DegreeChord tonic,
    required DegreeChord tonicizedToTonic,
    DegreeChord? tonicizedToMajorScale,
  }) : this.raw(
          tonic: tonic,
          tonicizedToTonic: tonicizedToTonic,
          tonicizedToMajorScale:
              tonicizedToMajorScale ?? tonicizedToTonic.tonicizedFor(tonic),
        );

  TonicizedDegreeChord.fromJson(Map<String, dynamic> json)
      : tonic = DegreeChord.fromJson(json['tonic']),
        tonicizedToTonic = DegreeChord.fromJson(json['toTonic']),
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
