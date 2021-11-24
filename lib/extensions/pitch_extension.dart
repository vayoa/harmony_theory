import 'package:tonic/tonic.dart';

extension PitchExtension on Pitch {
  int compareTo(Pitch other) => midiNumber.compareTo(other.midiNumber);

  bool operator >=(Pitch other) => compareTo(other) >= 0;

  bool operator <(Pitch other) => compareTo(other) < 0;

  bool operator >(Pitch other) => compareTo(other) > 0;
}
