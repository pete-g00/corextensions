library corextensions;

import 'package:trotter/trotter.dart';
import 'package:collection/collection.dart' show Equality, DefaultEquality, SetEquality, IterableEquality;

part 'src/iterableExtension.dart';
part 'src/listExtension.dart';
part 'src/setExtension.dart';
part 'src/stringExtension.dart';
part 'src/mapExtension.dart';

/// A zipped content contains a single zipped value
///
/// The zipped value from the first list is given by the `first` property, and the value from the second list is given by the `second` property.
class ZippedContent<A, B> {
  const ZippedContent(this.first, this.second);

  /// Returns the first element in the zip.
  final A first;

  /// Returns the second element in the zip.
  final B second;

  @override
  String toString() => '($first, $second)';
}

/// Creates a lazy iterable zipping the two lists.
///
/// For example,
/// ```
///   List<int> numbersAsInt = [0, 1, 2, 3, 4];
///   List<String> numbersAsString = ['zero', 'one', 'two', 'three', 'four'];
///   List<ZippedContent<int, String>> zipped = zipTwoLists(numbersAsInt, numbersAsString).toList();
///   print(zipped); // [(0, 'zero'), (1, 'one'), (2, 'two'), (3, 'three')]
///   print(zipped[2].first); // 2
///   print(zipped[1].second); // one
/// ```
Iterable<ZippedContent<A, B>> zipTwoLists<A, B>(
    List<A> firstList, List<B> secondList) {
  if (firstList.length == secondList.length) {
    return _ZippedContentIterable(firstList, secondList);
  } else {
    throw StateError('The length of the two lists isn\'t the same!');
  }
}

class _ZippedContentIterable<A, B> extends Iterable<ZippedContent<A, B>> {
  const _ZippedContentIterable(this.firstList, this.secondList);

  final List<A> firstList;
  final List<B> secondList;

  @override
  Iterator<ZippedContent<A, B>> get iterator =>
      _ZippedContentIterator(firstList, secondList);

  @override
  int get length {
    final firstLength = firstList.length;
    final secondLength = secondList.length;
    if (firstLength == secondLength) {
      return firstLength;
    } else {
      throw StateError('The length of the two lists isn\'t the same!');
    }
  }
}

class _ZippedContentIterator<A, B> extends Iterator<ZippedContent<A, B>> {
  _ZippedContentIterator(this.firstList, this.secondList) : i = -1;

  int i;
  final List<A> firstList;
  final List<B> secondList;

  int get length {
    final firstLength = firstList.length;
    final secondLength = secondList.length;
    if (firstLength == secondLength) {
      return firstLength;
    } else {
      throw StateError('The length of the two lists isn\'t the same!');
    }
  }

  @override
  bool moveNext() {
    i++;
    return i < length;
  }

  @override
  ZippedContent<A, B> get current =>
      i < length && i >= 0 ? ZippedContent(firstList[i], secondList[i]) : null;
}
