import 'package:corextensions/corextensions.dart';

void main(List<String> args) {  
  // string
  String rawValue = '  I       want  to     leave.       ';
  List<String> vowels = ['a', 'e', 'i', 'o', 'u'];
  String value = rawValue.removeExtraSpace();
  print(value); // 'I want to leave.'
  Iterable<RegExpMatch> matches = value.matchAll(vowels);
  print(matches.map((match) => match.start)); // (3, 8, 11, 14)
  print(value.startsWithOneOf(vowels)); // false

  // iterable/list
  List<int> numbers = [5, 10, 12, 8, 5];
  print(numbers.isSingle); // false
  print(numbers.hasDuplicates); // true
  print(numbers.count(-2)); // 0
  print(numbers.count(5)); // 2
  print(numbers.count(8)); // 1
  Iterable<int> mappedNumbers = numbers.mapWithIndex((element, i) => element * i);
  print(mappedNumbers); // (0, 10, 24, 24, 20)
  numbers.swap(0, 2);
  print(numbers); // [12, 10, 5, 8, 5]

  // iterable/set
  Set<int> values = {1, 3, 5, -2};
  print(values.equals({-2, 5, 1, 3})); // true
  print(values.countWhere((value) => value.abs() > 2)); // 2
  print(values.findLargestWhere((value) => (value - 2).abs())); // -2

  // map
  Map<String, int> map = {'first': 1, 'second': 2, 'third': 3, 'fourth': 4};
  print(map.singleEntryWhere((key, value) => key.length == 6)); // MapEntry('second': 2)
  print(map.firstKeyWhere((key, value) => value.isEven)); // second
  print(map.reverse()); // {1: 'first', 2: 'second', 3: 'third', 4: 'fourth'}
}