import 'package:tonic/tonic.dart';

extension PitchExtension on Pitch {
  String get commonName => letterName + accidentalsString;

  bool octavelessEqual(Pitch other) =>
      semitones % 12 == other.semitones % 12 &&
      accidentalSemitones == other.accidentalSemitones;

  int compareTo(Pitch other) => midiNumber.compareTo(other.midiNumber);

  bool operator >=(Pitch other) => compareTo(other) >= 0;

  bool operator <(Pitch other) => compareTo(other) < 0;

  bool operator >(Pitch other) => compareTo(other) > 0;

  Interval numberlessFrom(Pitch other) {
    return Interval.fromSemitones((semitones - other.semitones) % 12);
  }
}
