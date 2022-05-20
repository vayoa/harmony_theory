import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:thoery_test/state/krumhansl_schmuckler_scale_detection.dart';
import 'package:tonic/tonic.dart';

class ChordProgression extends Progression<Chord> {
  ChordProgression(
      {required List<Chord?> chords,
      required List<double> durations,
      TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super(chords, durations, timeSignature: timeSignature);

  /// Returns a new [ChordProgression] where all the chords are of 1/4 duration.
  ChordProgression.evenTime(List<Chord?> chords,
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super.evenTime(chords, timeSignature: timeSignature);

  ChordProgression.empty(
      {TimeSignature timeSignature = const TimeSignature.evenTime()})
      : super.empty(timeSignature: timeSignature);

  ChordProgression.fromProgression(Progression<Chord?> progression)
      : super.raw(
          values: progression.values,
          durations: progression.durations,
          timeSignature: progression.timeSignature,
          hasNull: progression.hasNull,
        );

  List<PitchScale> get krumhanslSchmucklerScales {
    KrumhanslSchmucklerScaleDetection.initialize();
    return KrumhanslSchmucklerScaleDetection.correlateChordProgression(this);
  }

  List<double> get krumhanslSchmucklerInput {
    List<double> input = List.generate(12, (index) => 0);
    for (int i = 0; i < length; i++) {
      Chord? chord = this[i];
      double dur = durations[i];
      if (chord != null) {
        List<Pitch> pitches = chord.pitches;
        for (Pitch pitch in pitches) {
          input[pitch.pitchClass.integer] += dur;
        }
      }
    }
    return input;
  }

  @override
  String notNullValueFormat(Chord value) => value.commonName;

  @override
  ChordProgression inTimeSignature(TimeSignature timeSignature) =>
      ChordProgression.fromProgression(super.inTimeSignature(timeSignature));
}
