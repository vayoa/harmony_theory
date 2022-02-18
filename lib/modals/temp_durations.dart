import 'dart:collection';
//
// class Durations with IterableMixin<DurationsIterator> {
//   final List<double> durations;
//
//   Durations(this.durations);
//
//   Durations.empty() : this([]);
//
//   double operator [](int index) =>
//       index == 0 ? durations.first : durations[index] - durations[index - 1];
//
//   double real(int index) => durations[index];
//
//   @override
//   Iterator<DurationsIterator> get iterator => DurationsIterator(this);
// }
//
// class DurationsIterator extends Iterator<double> {
//   int _index;
//
//   final Durations durations;
//
//   DurationsIterator(this.durations) : _index = -1;
//
//   @override
//   double get current => durations[_index];
//
//   @override
//   bool moveNext() {
//     if (_index > -2 && _index < durations.durations.length) {
//       _index++;
//       return true;
//     }
//     return false;
//   }
// }
