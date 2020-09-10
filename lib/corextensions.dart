import 'dart:math' as math show min;
import 'package:trotter/trotter.dart';
import 'package:collection/collection.dart';

extension ObjectExtension on Object {
  /// Returns `true` if `this` is `null`.
  bool get isNull => this == null;

  /// Returns `true` if `this` is not `null`.
  bool get isNotNull => !isNull;
}

extension IterableExtension<E> on Iterable<E> {
  /// Returns the first element that is not `null` (following the `fn` map).
  E firstWhereNotNull<L>(L Function(E element) fn) =>
      firstWhere((element) => fn(element).isNotNull);

  /// Returns another iterable where all the elements that are not `null` (following the `fn` map).
  Iterable<E> whereNotNull<L>(L Function(E element) fn) =>
      where((element) => fn(element).isNotNull);

  /// Given another list, checks whether every element in the two lists are equal.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers1 = [0, 1, 2];
  /// List<int> numbers2 = [0, 1, 2];
  /// List<int> numbers3 = [0, 1];
  /// print(numbers1.shallowEquals(numbers2)); // true
  /// print(numbers1.shallowEquals(numbers3)); // false
  ///
  /// List<List<int>> numbersOfNumbers1 = [[0, 1], [2, 3], [4, 5]];
  /// List<List<int>> numbersOfNumbers2 = [[0, 1], [2, 3], [4, 5]];
  /// // This will be false because the lists the two lists are made of aren't equal.
  /// print(numbersOfNumbers1.shallowEquals(numbersOfNumbers2)); // false
  /// ```
  ///
  /// This is done using the class [IterableEquality] from the `collection` package.
  /// The equality, when comparing two elements, is checked by [DefaultEquality], which checks the two elements using the operator [operator ==].
  ///
  /// This can be changed by providing another type of [Equality], such as [IdentityEquality], which checks the two elements are the same instance of an object,
  /// using the [identical] function. This can be provided as the `equality` property.
  bool shallowEquals(Iterable<Object> iterable,
          [Equality equality = const DefaultEquality()]) =>
      IterableEquality(equality).equals(this, iterable);

  /// Finds the single difference between the two values of the two iterators.
  int _findSingleDifference(Iterator<E> shorter, Iterator<E> longer,
      String shorterLabel, String longerLabel) {
    bool endOfBothList;
    int index;
    bool couldMoveShorter;
    bool couldMoveLonger;
    var i = 0;
    do {
      couldMoveShorter = shorter.moveNext();
      couldMoveLonger = longer.moveNext();
      if (!couldMoveShorter && couldMoveLonger) {
        if (index.isNotNull) {
          throw StateError(
              "The two iterables don't just have one missing element!");
        }
        index = i;
        couldMoveLonger = longer.moveNext();
      }
      if (shorter.current != longer.current) {
        if (!couldMoveLonger) {
          throw StateError(
              'The length of $shorterLabel iterable is not one more than the length of $longerLabel iterable!');
        }
        if (index.isNotNull) {
          throw StateError(
              "The two iterables don't just have one missing element!");
        }
        index = i;
        couldMoveLonger = longer.moveNext();
      }
      if (couldMoveLonger != couldMoveShorter) {
        throw StateError(
            'The length of $shorterLabel iterable is not one more than the length of $longerLabel iterable!');
      }
      if (shorter.current != longer.current) {
        throw StateError('The two lists have more than one different element!');
      }
      endOfBothList = couldMoveLonger == false && couldMoveShorter == false;
      i++;
    } while (!endOfBothList);

    if (index.isNull) {
      throw StateError('The two lists have the same elements!');
    }
    return index;
  }

  /// Finds the index of the single element missing from `this` that is present in the provided `iterable`.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2, 3, 4];
  /// List<int> numbersFragment = [1, 2, 4];
  /// int missingNumberIndex = numbersFragment.findSingleMissingFrom(numbers);
  /// print(missingNumberIndex); // 2
  /// print(numbers[missingNumberIndex]); // 3
  /// ```
  ///
  /// Since `this` is missing an element from the provided `iterable`, it is expected for the length of `this` to be one less than the `iterable`.
  ///
  /// Also, the order in which the elements occur in both iterables must be the same for the returned element to be the only difference.
  int findSingleMissingFrom(Iterable<E> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');

    final thisIterator = iterator;
    final thatIterator = iterable.iterator;
    return _findSingleDifference(
        thisIterator, thatIterator, 'this', 'the provided');
  }

  /// Finds the index of the single extra element in `this` that is present in the provided `iterable`.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2, 3, 4];
  /// List<int> numbersFragment = [1, 2, 4];
  /// int extraNumberIndex = numbers.findSingleExtraFrom(numbersFragment);
  /// print(extraNumberIndex); // 2
  /// print(numbers[extraNumberIndex]); // 3
  /// ```
  ///
  /// Since `this` has an extra element from the provided `iterable`, it is expected for the length of `this` to be one more than the `iterable`.
  ///
  /// Also, the order in which the elements occur in both iterables must be the same for the returned element to be the only difference.
  int findSingleExtraFrom(Iterable<E> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');

    final thisIterator = iterator;
    final thatIterator = iterable.iterator;
    return _findSingleDifference(
        thatIterator, thisIterator, 'the provided', 'this');
  }

  /// Finds the index of the single different element from `this` that is present in the provided `iterable`.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2, 3];
  /// int differentElementIndex = numbers.findSingleSwappedFrom([1, 2, 4]);
  /// print(differentElementIndex); // 2
  /// ```
  /// It is expected for the length of `this` to be the same as that of the `iterable`.
  ///
  /// Also, the order in which the elements occur in both iterables must be the same for the returned element to be the only difference.
  int findSingleSwappedFrom(Iterable<E> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');

    final thisIterator = iterator;
    final thatIterator = iterable.iterator;
    bool endOfBothList;
    int differentElementIndex;
    bool couldMoveThis;
    bool couldMoveThat;
    var i = 0;
    do {
      couldMoveThis = thisIterator.moveNext();
      couldMoveThat = thatIterator.moveNext();
      if (couldMoveThis != couldMoveThat) {
        throw StateError("The length of the two iterables isn't equal!");
      }
      if (thisIterator.current != thatIterator.current) {
        if (differentElementIndex.isNotNull) {
          throw StateError(
              "There's more than one different element in the two iterables!");
        }
        differentElementIndex = i;
      }
      endOfBothList = couldMoveThat == false && couldMoveThis == false;
      i++;
    } while (!endOfBothList);
    if (differentElementIndex.isNull) {
      throw StateError('The two lists have the same elements!');
    }
    return differentElementIndex;
  }

  /// Returns `true` if the length of the iterable is 1.
  bool get isSingle {
    final it = iterator;
    if (!it.moveNext()) return false;
    return !it.moveNext();
  }

  /// Returns true if any of the elements in `this` is of the given type.
  bool anyOfType<L>() => any((elt) => elt is L);

  /// Returns true if all the elements in `this` are of the given type.
  bool allOfType<L>() => every((elt) => elt is L);

  /// Returns the first element that is of the given type.
  ///
  /// If there is no element of the given type, the result of invoking the `orElse` function is returned.
  /// If `orElse` is omitted, it defaults to throwing a [StateError].
  L firstWhereType<L>([L Function() orElse]) {
    for (final elt in this) {
      if (elt is L) return elt;
    }
    if (orElse.isNotNull) return orElse();
    throw StateError('No element!');
  }

  /// Given a function that returns a number, returns the element in `this` that returns the smallest value.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [-2, 15, -10, 4];
  /// int smallestAbsolute = numbers.findSmallestWhere.((element) => element.abs());
  /// print(smallestAbsolute); // -2
  /// ```
  E findSmallestWhere(num Function(E element) function) =>
      reduce((value, element) =>
          function(value) < function(element) ? value : element);

  /// Given a function that returns a number, returns the element in `this` that returns the largest value.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [-2, 15, -10, 4];
  /// int largestAbsolute = numbers.findSmallestWhere.((element) => element.abs());
  /// print(largestAbsolute); // 15
  /// ```
  E findLargestWhere(num Function(E element) function) =>
      reduce((value, element) =>
          function(value) < function(element) ? element : value);

  /// Returns `true` if the length of `this` is the same as the length of the provided `iterable`.
  ///
  /// This method could take long to compute, since it assumes that getting the length isn't an efficient process here.
  bool hasSameLengthAs<L>(Iterable<L> iterable) {
    final thisIterator = iterator;
    final thatIterator = iterable.iterator;
    bool hasSameLength;
    bool canMoveThis;
    bool canMoveThat;
    do {
      canMoveThis = thisIterator.moveNext();
      canMoveThat = thatIterator.moveNext();
      hasSameLength = canMoveThat == canMoveThis;
    } while (canMoveThis && canMoveThat);
    return hasSameLength;
  }

  /// Returns `true` if `this` starts with the same elements as the iterable.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2, 1, 1, 3];
  /// List<int> numbersSubset1 = [1, 2, 1];
  /// List<int> numbersSubset2 = [1, 2, 3];
  /// print(numbers.startsWith(numbersSubset1)); // true
  /// print(numbers.startsWith(numbersSubset2)); // false
  /// ```
  ///
  /// Checks by iterating over all the elements.
  bool startsWith(Iterable<E> iterable) {
    final thisIterator = iterator;
    final thatIterator = iterable.iterator;
    bool canMoveThis;
    bool canMoveThat;
    var startsWithSame = true;
    do {
      canMoveThis = thisIterator.moveNext();
      canMoveThat = thatIterator.moveNext();
      if (!canMoveThis) return false;
      if (!canMoveThat) return startsWithSame;
      startsWithSame = thisIterator.current == thatIterator.current;
    } while (canMoveThis && canMoveThat && startsWithSame);
    return startsWithSame;
  }

  /// Returns `true` if the provided elements are found in the list, in the specified order.
  ///
  /// For example,
  /// ```
  /// Iterable<int> numbers = [1, 2, 3, 4, 2];
  /// Iterable<int> numbersSubset1 = [2, 3, 4];
  /// Iterable<int> numbersSubset1 = [1, 3, 4];
  /// print(numbers.containsInOrder(numbersSubset1)); // true
  /// print(numbers.containsInOrder(numbersSubset2)); // false
  /// ```
  bool containsInOrder(Iterable<E> subset) {
    final thisIterator = iterator;
    var thatIterator = subset.iterator;

    if (!thatIterator.moveNext()) return isEmpty;
    while (thisIterator.moveNext()) {
      if (thisIterator.current == thatIterator.current) {
        if (!thatIterator.moveNext()) return true;
      } else {
        thatIterator = subset.iterator;
        thatIterator.moveNext();
        if (thisIterator.current == thatIterator.current) {
          thatIterator.moveNext();
        }
      }
    }
    return !thatIterator.moveNext();
  }

  /// Counts the number of times the value is present in the iterable.
  int count(E element) {
    var count = 0;
    for (var item in this) {
      if (element == item) {
        count++;
      }
    }
    return count;
  }

  /// Counts the number of elements in the iterable that satisfy the `fn`.
  int countWhere(bool Function(E element) fn) {
    var count = 0;
    for (var item in this) {
      if (fn(item)) {
        count++;
      }
    }
    return count;
  }
}

class _MappedListIterable<S, E> extends Iterable<S> {
  const _MappedListIterable(this.list, this.transform);

  final S Function(E element, int i) transform;
  final List<E> list;

  @override
  Iterator<S> get iterator => _MappedListIterator(list, transform);

  @override
  int get length => list.length;

  @override
  S elementAt(int i) => transform(list[i], i);
}

class _MappedListIterator<S, E> extends Iterator<S> {
  _MappedListIterator(this.list, this.transform) : i = -1;
  int i;
  final S Function(E element, int i) transform;
  final List<E> list;
  @override
  bool moveNext() {
    i++;
    return i < list.length;
  }

  @override
  S get current => i < list.length && i >= 0 ? transform(list[i], i) : null;
}

extension ListExtension<E> on List<E> {
  /// Returns a new lazy iterable with elements that are created by calling `f` on each element of this `List` in iteration order.
  ///
  /// Unlike the [map] method, we are also provided with the index at which the value is.
  Iterable<S> mapWithIndex<S>(S Function(E element, int i) f) =>
      _MappedListIterable(this, f);

  /// Returns `true` if there is only one element in `this`.
  bool get isSingle => length == 1;

  /// Returns `true` if the length of `this` is the same as the length of the provided `iterable`.
  ///
  /// Can be slow if the provided iterable isn't a list/set, or something that can efficiently index/calculate the `length`.
  bool hasSameLengthAs<L>(Iterable<L> iterable) => length == iterable.length;

  /// Returns `true` if `this` has any duplicates present.
  ///
  /// This is done via comparing the length of `this` as a list and as a set.
  /// Therefore, it uses the equality operator [Object.==] for each element in `this` to determine whether there are duplicates.
  bool get hasDuplicates => toSet().length != length;

  /// Returns `true` if the elements within `this` and the other list are the same. The order in which they appear is irrelevant.
  ///
  /// This is checked by computing the equality between the two lists as sets. The equality used is from the operator [Object.==].
  bool hasSameElementsAs(List<E> list) => toSet().equals(list.toSet());

  /// Returns a new list where the provided `addition` is added in between every 2 elements in `this`.
  ///
  /// The element is not added to the start or the end of the list.
  ///
  /// For example,
  ///
  ///```
  ///  List<int> numbers = [1, 2, 3];
  ///  numbers.addWithin(5);
  ///  print(numbers); // [1, 5, 2, 5, 3]
  /// ```
  void addWithin(E addition) {
    ArgumentError.checkNotNull(addition, 'addition');

    // make a copy of length so that this val affects the loop, not the len of the growing list
    final length = this.length;
    for (var i = 0; i < length - 1; i++) {
      insert(2 * i + 1, addition);
    }
    // final added = <E>[];
    // for (var i = 0; i < length; i++) {
    //   added.add(this[i]);
    //   if (i < length - 1) {
    //     added.add(addition);
    //   }
    // }
    // return added;
  }

  /// Given two indices in `this`, swaps elements at those indices within this list.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3];
  /// numbers.swap(0, 1);
  /// print(numbers); // [2, 1, 3]
  /// ```
  void swap(int i, int j) {
    ArgumentError.checkNotNull(i, 'i');
    ArgumentError.checkNotNull(j, 'j');
    RangeError.checkValidIndex(i, this, 'i');
    RangeError.checkValidIndex(j, this, 'j');

    if (i == j) return;

    final value = this[i];
    this[i] = this[j];
    this[j] = value;
  }

  /// Permutes the elements in the list given a list of indices, in that order.
  ///
  /// So, if the indices list is `[0, 2, 1]`,
  ///
  /// * `this[0]` becomes `this[2]`;
  /// * `this[2]` becomes `this[i]`; and
  /// * `this[1]` becomes `this[0]`.
  ///
  /// Every index can only appear once in the list. Any index not appearing in the list remains unaffected.
  ///
  /// For example,
  ///
  /// ```
  /// List<String> sentence = ['I', 'would', 'have', 'known', 'not', 'that'];
  /// sentence.permute([2, 3, 4]);
  /// print(sentences); // ['I', 'would', 'not', 'have', 'known', 'that']
  /// ```
  void permute(List<int> indices) {
    ArgumentError.checkNotNull(indices, 'indices');

    if (indices.isEmpty || indices.isSingle) return;
    if (indices.hasDuplicates) {
      throw ArgumentError('The list of indices has duplicates!');
    }

    ArgumentError.checkNotNull(indices.first, 'indices[0]');
    RangeError.checkValidIndex(indices.first, this, 'indices[0]');

    final value = this[indices[indices.length - 1]];
    for (var i = indices.length - 2; i >= 0; i--) {
      ArgumentError.checkNotNull(indices[i + 1], 'indices[${i + 1}]');
      RangeError.checkValidIndex(indices[i + 1], this, 'indices[${i + 1}]');
      this[indices[i + 1]] = this[indices[i]];
    }
    this[indices[0]] = value;
  }

  /// Given a function that we can run 2 consecutive elements of `this`, partitions the list by the result.
  ///
  /// If `true`, the two elements lie in the same partition.
  ///
  /// If `false`, the first element and the second element lie in a different partition.
  ///
  /// For example,
  ///
  /// ```
  ///  List<int> numbers = [1, 2, 3, 5, 6, 10, 12, 13];
  ///  List<List<int>> numbersPartitioned = numbers.partitionInOrder(
  ///    // in the same partition if their difference is 1.
  ///    (previousValue, thisValue, i, thisPartition) => previousValue + 1 == thisValue
  ///  );
  ///  print(numbersPartitioned); // [[1, 2, 3], [5, 6], [10], [12, 13]]
  /// ```
  List<List<E>> partitionInOrder(
      bool Function(E previousValue, E thisValue, int i, List<E> thisPartition)
          function) {
    ArgumentError.checkNotNull(function, 'function');

    if (isEmpty) return [];
    final partitioned = <List<E>>[];
    var thisPartition = [first];
    for (var i = 0; i < length - 1; i++) {
      if (function(this[i], this[i + 1], i, thisPartition)) {
        thisPartition.add(this[i + 1]);
      } else {
        partitioned.add(thisPartition);
        thisPartition = [this[i + 1]];
      }
    }
    partitioned.add(thisPartition);
    return partitioned;
  }

  /// Returns all the permutations of `this`.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3];
  /// Iterable<List<int>> numberPermutations = number.allPermutations();
  /// print(numberPermutations); // ([1, 2, 3], [1, 3, 2], .., [3, 2, 1])
  /// ```
  ///
  /// This uses the [Permutations] class from the `trotter` package.
  Iterable<List<E>> allPermutations() => Permutations(length, this)();

  /// Returns all the permutations of `this`, excluding this one.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3];
  /// Iterable<List<int>> numberPermutations = number.otherPermutations();
  /// print(numberPermutations.toList()); // ([1, 3, 2], [2, 3, 1], .., [3, 2, 1])
  /// ```
  Iterable<List<E>> otherPermutations() =>
      allPermutations().where((element) => !shallowEquals(element));

  /// Returns a version of `this` where the elements in the list appear in the provided `newOrder`.
  ///
  /// For example,
  ///
  /// ```
  /// List<String> sentence = ['I', 'went', 'there', 'yesterday'];
  /// List<String> reOrderedSentence = sentence.withOrder([3, 0, 1, 2]);
  /// print(reOrderedSentence); // ['yesterday', 'I', 'went', 'there']
  /// ```
  ///
  /// The list provided must be made of all the indices from `0` to `length - 1` precisely once.
  List<E> withOrder(List<int> newOrder) {
    if (newOrder.hasDuplicates) throw ArgumentError('The list has duplicates!');
    if (!hasSameLengthAs(newOrder)) {
      throw ArgumentError(
          "The list of indices doesn't contain all the indices in this list!");
    }
    final reordered = <E>[];
    for (var i = 0; i < length; i++) {
      final j = newOrder[i];
      RangeError.checkValidIndex(j, this, 'newOrder[$i]');
      reordered.add(this[j]);
    }
    return reordered;
  }

  /// Finds the index of the first difference between `this` and a `permutation` provided.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3, 4];
  /// List<int> numbersPermuted = [1, 3, 2, 4];
  /// int firstDifferenceIndex = numbers.firstDifferenceTo(numbersPermuted);
  /// print(firstDifferenceIndex); // 1
  /// ```
  int firstDifferenceTo(List<E> permutation) {
    ArgumentError.checkNotNull(permutation, 'permutation');
    if (!hasSameLengthAs(permutation)) {
      throw ArgumentError("The two lists don't have the same length!");
    }

    for (var i = 0; i < length; i++) {
      if (this[i] != permutation[i]) return i;
    }
    throw StateError(
        'The two lists are the same or aren\'t permutations of each other!');
  }

  /// Finds the distance between `this` and its `permutation`.
  ///
  /// This is done by counting the number of indices where the elements in the two lists is different.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3, 4];
  /// List<int> numbersPermuted = [1, 3, 2, 4];
  /// int distance = numbers.distanceTo(numbersPermuted);
  /// print(distance); // 2
  ///```
  int distanceTo(List<E> permutation) {
    ArgumentError.checkNotNull(permutation, 'permutation');

    var distance = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] != permutation[i]) {
        distance++;
      }
    }
    return distance;
  }

  /// Finds all the indices of the element in `this`.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 1, 2, 3, 1, 5];
  /// List<int> indicesOf1 = numbers.allIndicesOf(1);
  /// print(indicesOf1); // [0, 1, 4]
  /// List<int> indicesOf4 = numbers.allIndicesOf(4);
  /// print(indicesOf4); // []
  /// ```
  List<int> allIndicesOf(E element) {
    final matches = <int>[];
    for (var i = 0; i < length; i++) {
      if (this[i] == element) {
        matches.add(i);
      }
    }
    return matches;
  }

  /// Finds all the indices of the elements in `this` that satisfy the provided `function`.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 1, 2, 3, 1, 5];
  /// List<int> evenIndices = numbers.allIndicesWhere((element) => element.isEven);
  /// print(evenIndices); // [2]
  /// List<int> negativeIndices = numbers.allIndicesOf((element) => element.isNegative);
  /// print(negativeIndices); // []
  /// ```
  List<int> allIndicesWhere(bool Function(E element) f) {
    final matches = <int>[];
    for (var i = 0; i < length; i++) {
      if (f(this[i])) {
        matches.add(i);
      }
    }
    return matches;
  }

  /// Gets all the possible choices from `this`.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2];
  /// List<List<int>> choicesOfNumber = numbers.allChoices;
  /// print(choicesOfNumber); // [[], [1], [2], [1, 2]]
  /// ```
  ///
  /// This is done with help of the class [Combinations] from the `trotter` package.
  List<List<E>> get allChoices {
    final choices = <List<E>>[];
    for (var i = 0; i <= length; i++) {
      choices.addAll(Combinations(i, this)());
    }
    return choices;
  }

  /// Replace elements within `this` by reorganising the elements.
  ///
  /// The elements between the `startIndex` (inclusive) and the `endIndex` (exclusive) will be replaced by elements at indices within the `changeArray`.
  ///
  /// For example,
  ///
  /// ```
  /// List<String> fruits = ['apple', 'banana', 'carrot', 'mango', 'pineapple'];
  /// fruits.replaceElementsByReorganisation(1, 3, [1, 0]);
  /// print(fruits); // ['apple', 'carrot', 'banana', 'mango', 'pineapple']
  /// fruits.replaceElementsByReorganisation(1, 4, [2, 2]);
  /// print(fruits); // ['apple', 'mango', 'mango', 'pineapple']
  /// ```
  ///
  /// The indices within `changeArray` must be between `0` (inclusive) and `endIndex - startIndex` (exclusive).
  /// They are added with the start index when reorganised.
  void replaceElementsByReorganisation(
      int startIndex, int endIndex, List<int> changeArray) {
    RangeError.checkValidRange(startIndex, endIndex, length);

    if (changeArray
        .any((element) => element < 0 || element >= endIndex - startIndex)) {
      throw RangeError(
          'The change array must be made of elements within the replacing part!');
    }
    final replacement = changeArray.map((i) => this[startIndex + i]);
    replaceRange(startIndex, endIndex, replacement);
  }

  /// Returns `true` if `this` starts with the elements in the provided list `values`.
  /// The equality of the values is evaluated directly.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [1, 2, 1, 1, 3];
  /// List<int> numbersSubset1 = [1, 2, 1];
  /// List<int> numbersSubset2 = [1, 2, 3];
  /// print(numbers.startsWith(numbersSubset1)); // true
  /// print(numbers.startsWith(numbersSubset2)); // false
  /// ```
  bool startsWith(List<E> values) {
    ArgumentError.checkNotNull(values, 'values');

    if (length < values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (this[i] != values[i]) return false;
    }
    return true;
  }

  /// Returns `true` if `this` ends with the elements in the provided list `values`.
  /// The equality of the values is evaluated directly.
  ///
  /// For example,
  /// ```
  /// List<int> numbers = [1, 2, 1, 1, 3];
  /// List<int> numbersSubset1 = [1, 1, 1];
  /// List<int> numbersSubset2 = [1, 1, 3];
  /// print(numbers.endsWith(numbersSubset1)); // false
  /// print(numbers.endsWith(numbersSubset2)); // true
  /// ```
  bool endsWith(List<E> values) {
    ArgumentError.checkNotNull(values, 'values');

    if (length < values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (this[length - 1 - i] != values[values.length - 1 - i]) return false;
    }
    return true;
  }

  /// Returns `true` if the provided elements are found in the list, in the specified order.
  ///
  /// For example,
  ///
  ///```
  /// List<int> numbers = [1, 2, 3, 4, 2];
  /// List<int> numbersSubset1 = [2, 3, 4];
  /// List<int> numbersSubset1 = [1, 3, 4];
  /// print(numbers.containsInOrder(numbersSubset1)); // true
  /// print(numbers.containsInOrder(numbersSubset2)); // false
  /// ```
  bool containsInOrder(List<E> subset) {
    if (subset.isEmpty) return isEmpty;

    var j = 0;
    for (var i = 0; i < length; i++) {
      if (this[i] == subset[j]) {
        if (j == subset.length - 1) return true;
        j++;
      } else {
        j = this[i] == subset[0] ? 1 : 0;
      }
    }
    return j == subset.length - 1;
  }

  /// Updates the value of all the elements in `this` using the function.
  ///
  /// For example,
  /// ````
  ///  List<int> numbers = [0, 1, 2, 3];
  ///  numbers.updateAll((value) => value * 2);
  ///  print(numbers); // [0, 2, 4, 6]
  /// ````
  void updateAll(E Function(E element) f) {
    for (var i = 0; i < length; i++) {
      this[i] = f(this[i]);
    }
  }

  /// Counts the number of times the value is present in the iterable.
  int count(E element) {
    var count = 0;
    for (var i = 0; i < length; i++) {
      if (element == this[i]) {
        count++;
      }
    }
    return count;
  }

  /// Counts the number of elements in the iterable that satisfy the `fn`.
  int countWhere(bool Function(E element) fn) {
    var count = 0;
    for (var i = 0; i < length; i++) {
      if (fn(this[i])) {
        count++;
      }
    }
    return count;
  }
}

extension ListOfListExtension<E> on List<List<E>> {
  /// Spreads and combines the lists with respect to their index.
  ///
  /// For example:
  ///
  /// ```
  /// List<List<int>> numbersOrganised = [[1, 2], [3], [4, 5, 6]];
  /// List<List<int>> numbersReorganised = numbersOrganised.spreadAndCombine();
  /// print(numbersReorganised); // [[1, 3, 4], [1, 3, 5], [1, 3, 6], [2, 3, 4], [2, 3, 5], [2, 3, 6]]
  /// ```
  ///
  /// The original list determines the position in which the element will end up after being spread.
  /// So, those in the first list will end up at the first index, and so on.
  ///
  /// It forms all the possible combinations when this reorganisation happens.
  ///
  /// None of the lists can be empty.
  List<List<E>> spreadAndCombine() {
    var list = this[0].map((elt) => [elt]).toList();
    for (var i = 1; i < length; i++) {
      if (this[i].length == 0) throw StateError('The list cannot be empty!');
      final spread = <List<E>>[];
      for (var j = 0; j < list.length; j++) {
        for (var k = 0; k < this[i].length; k++) {
          spread.add(list[j] + [this[i][k]]);
        }
      }
      list = spread;
    }
    return list;
  }

  /// Given a valid `index`, returns the value which would be at the provided index following spread and combine.
  ///
  /// See [spreadAndCombine] for more information about the function.
  List<E> spreadAndCombineAtIndex(int index) {
    ArgumentError.checkNotNull(index, 'index');
    var totalLength = fold<int>(
        1, (previousValue, element) => previousValue * element.length);
    RangeError.checkValueInInterval(index, 0, totalLength - 1, 'index');

    final content = <E>[];
    int i;
    for (final values in this) {
      i = index % totalLength;
      totalLength = totalLength ~/ values.length;
      i = i ~/ totalLength;
      content.add(values[i]);
    }
    return content;
  }

  /// Given an element from the spread and combined version of `this`, returns the index where this spread would lie in the spread and combine list.
  ///
  /// See [spreadAndCombine] for more information about the function.
  int spreadAndCombineToIndex(List<E> spread) {
    ArgumentError.checkNotNull(spread, 'spread');

    var index = 0;
    var totalLength = fold<int>(
        1, (previousValue, element) => previousValue * element.length);
    spread.asMap().forEach((i, value) {
      totalLength ~/= this[i].length;
      final j = this[i].indexOf(value);
      if (j == -1) {
        throw StateError(
            "The element in index $i isn't found in list number $j!");
      }
      index += totalLength * j;
    });
    return index;
  }
}

extension SetExtension<E> on Set<E> {
  /// Returns `true` if there is only one element in `this`.
  bool get isSingle => length == 1;

  /// Returns `true` if the length of `this` is the same as the length of the provided `iterable`.
  ///
  /// Can be slow if the provided iterable isn't a list/set, or something that can efficiently index/calculate the length.
  bool hasSameLengthAs<L>(Iterable<L> iterable) => length == iterable.length;

  /// Returns `true` if `this` is equal to the another set provided.
  ///
  /// This is calculated by equating two elements within the two sets in some order, i.e. using [Object.==].
  bool equals(Set<E> another) => SetEquality().equals(this, another);
}

/// Creates a [RegExp] that matches all the [sources].
RegExp regExpForMultipleMatches(Iterable<String> sources,
    {bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false}) {
  final value = sources.fold<String>(
      '',
      (previousValue, element) =>
          previousValue.isEmpty ? '$element' : '$previousValue|\\$element');
  return RegExp(value,
      multiLine: multiLine,
      caseSensitive: caseSensitive,
      unicode: unicode,
      dotAll: dotAll);
}

extension StringExtension on String {
  /// Capitalises the first letter of `this` and returns that value.
  ///
  /// If this string is empty, returns the same empty string.
  String capitalise() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Splits the string by the first occurence of the provided pattern.
  ///
  /// If the pattern is not found, a list with only this element will be provided.
  ///
  /// For example,
  ///
  /// ```
  /// String word = 'happy';
  /// print(word.splitFirst('p')); // ['ha', 'py']
  /// print(word.splitFirst('pp')); // ['ha', 'y']
  /// print(word.splitFirst('z')); // ['happy']
  /// ```
  List<String> splitFirst(String pattern) {
    for (var i = 0; i < length; i++) {
      if (startsWith(pattern, i)) {
        return [substring(0, i), substring(i + pattern.length)];
      }
    }
    return [this];
  }

  /// Splits the string by the last occurence of the provided pattern.
  ///
  /// For example,
  ///
  /// ```
  /// String word = 'happy';
  /// print(word.splitLast('p')); // ['hap', 'y']
  /// print(word.splitLast('pp')); // ['ha', 'y']
  /// print(word.splitLast('z')); // ['happy']
  /// ```
  /// If the pattern is not found, a list with only this element will be provided.
  List<String> splitLast(String pattern) {
    for (var i = length; i > 0; i--) {
      if (substring(0, i).endsWith(pattern)) {
        return [substring(0, i - pattern.length), substring(i)];
      }
    }
    return [this];
  }

  /// Removes most of the whitespace within the string.
  ///
  /// Breaks the word by the space ' ', and trims each of the result, and join back by the space ' '.
  ///
  /// For example,
  ///
  /// ```
  /// String sentence = 'I want   to   be  free.    ';
  /// String trimmedSentence = sentence.removeSpace();
  /// print(trimmedSentence); // 'I want to be free.'
  /// ```
  String removeExtraSpace() {
    final trimmedSentence = <String>[];
    for (var word in split(' ')) {
      word = word.trim();
      if (word.isNotEmpty) {
        trimmedSentence.add(word);
      }
    }
    return trimmedSentence.join(' ');
  }

  /// Splits `this` by all the provided delimiters.
  ///
  /// The empty delimiter ('') cannot be used, and is implictly removed from the provided list.
  ///
  /// Also removes any empty strings from the list before returning.
  ///
  /// For example,
  ///
  /// ```
  ///  String sentence = 'Happy, sad and angry';
  ///  Iterable<String> splittedSentence = sentence.splitByAll([',', ' ']);
  ///  print(splittedSentence); // ('Happy', 'sad', 'and', 'angry')
  /// ```
  Iterable<String> splitByAll(Iterable<String> delimiters) {
    ArgumentError.checkNotNull(delimiters, 'delimiters');
    if (delimiters.isEmpty) {
      throw ArgumentError('The list of delimiters cannot be empty!');
    }

    delimiters = delimiters.where((element) => element.isNotEmpty);
    final exp = regExpForMultipleMatches(delimiters);
    return split(exp).where((element) => element.isNotEmpty).map((word) =>
        word.endsWithOneOf(delimiters)
            ? word.substring(0, word.length - 1)
            : word);
  }

  /// Checks whether some element in the iterable starts with this string.
  ///
  /// For example,
  ///
  /// ```
  /// String value = 'value';
  /// List<String> consonants = ['b', 'v', 'l', 'n', 'w'];
  /// List<String> vowels = ['a', 'e', 'i', 'o'];
  /// print(value.startsWithOneOf(consonants)); // true
  /// print(value.startsWithOneOf(vowels)); // false
  /// ```
  bool startsWithOneOf(Iterable<String> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');
    return iterable.any((String string) => startsWith(string));
  }

  /// Checks whether some element in the iterable ends with this string.
  ///
  /// For example,
  ///
  /// ```
  /// String value = 'value';
  /// List<String> consonants = ['b', 'v', 'l', 'n', 'w'];
  /// List<String> vowels = ['a', 'e', 'i', 'o'];
  /// print(value.endsWithOneOf(consonants)); // true
  /// print(value.endsWithOneOf(vowels)); // false
  /// ```
  bool endsWithOneOf(Iterable<String> iterable) {
    ArgumentError.checkNotNull(iterable, 'iterable');
    return iterable.any((String string) => endsWith(string));
  }

  /// Returns a new string in which the last occurrence of `from` in this string is replaced with `to`, going back from at `endIndex`:
  ///
  /// ```
  /// '0.0001'.replaceFirst(new RegExp(r'0'), ''); // '0.001'
  /// '0.0001'.replaceFirst(new RegExp(r'0'), '7', 3); // '0.0701'
  /// ```
  String replaceLast(Pattern from, String to, [int endIndex]) {
    ArgumentError.checkNotNull(from, 'from');
    ArgumentError.checkNotNull(to, 'to');

    endIndex ??= length - 1;
    final lastIndex = lastIndexOf(from, endIndex);
    if (lastIndex == -1) return this;
    return replaceFirst(from, to, lastIndex);
  }

  /// Finds the indices of the start of all the matches of all the provided values.
  ///
  /// For example,
  ///
  /// ```
  /// String sentence = 'I am here';
  /// List<RegExpMatch> matches = sentence.matchAll(['a', 'e']).toList();
  /// print(matches.map((match) => match.start)); // (2, 6, 8)
  /// ```
  Iterable<RegExpMatch> matchAll(Iterable<String> values) {
    final exp = regExpForMultipleMatches(values);
    return exp.allMatches(this);
  }
}

extension ListIntExtension<T extends num> on Iterable<T> {
  /// Returns the sum of the numbers.
  T get sum {
    return reduce((value, element) => value + element);
  }

  /// Returns the product of the numbers.
  T get product {
    return reduce((value, element) => value * element);
  }

  /// Returns the smallest value in the list.
  T get min {
    return reduce((value, element) => math.min(value, element));
  }

  /// Returns the largest value in the list.
  T get max {
    return reduce((value, element) => math.min(value, element));
  }
}

extension IterableBigInt on Iterable<BigInt> {
  /// Lowers an iterable numbers from `this` to its lowest factor, i.e. the resulting gcd will be 1.
  ///
  /// For example,
  ///
  /// ```
  /// List<BigInt> numbers = [BigInt.two, BigInt.from(111111111111111111111111111111112), BigInt.from(20)];
  /// List<BigInt> numbersAtLowest = numbers.atLowestFactors;
  /// print(numbersAtLowest); // (1, 55555555555555555555555555555556, 10)
  /// ```
  /// None of the numbers can be `0`.
  Iterable<BigInt> get atLowestFactors {
    final gcd = reduce((value, element) {
      if (value == BigInt.zero || element == BigInt.zero) {
        throw StateError('None of the numbers can be zero!');
      }
      return value.gcd(element);
    });
    return map((number) => number ~/ gcd);
  }
}

extension IterableInt on Iterable<int> {
  /// Lowers an iterable numbers from `this` to its lowest factor, i.e. the resulting gcd will be 1.
  ///
  /// For example,
  /// ```
  /// List<int> numbers = [2, 112, 20];
  /// Iterable<int> numbersAtLowest = numbers.atLowestFactors;
  /// print(numbersAtLowest); // (1, 56, 10)
  /// ```
  /// None of the numbers can be `0`.
  Iterable<int> get atLowestFactors {
    final gcd = reduce((value, element) {
      if (value == 0 || element == 0) {
        throw StateError('None of the numbers can be zero!');
      }
      return value.gcd(element);
    });
    return map((number) => number ~/ gcd);
  }
}

extension MapExtension<K, V> on Map<K, V> {
  /// Returns `true` if there's precisely one key/value pair in the map.
  bool get isSingle => length == 1;

  /// Returns the first entry that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  MapEntry<K, V> firstEntryWhere(bool Function(K key, V value) f,
      {MapEntry<K, V> Function() orElse}) {
    for (final entry in entries) {
      if (f(entry.key, entry.value)) return entry;
    }
    if (orElse.isNotNull) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the first key that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  K firstKeyWhere(bool Function(K key, V value) f, {K Function() orElse}) {
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        return entry.key;
      }
    }
    if (orElse.isNotNull) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the first value that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  V firstValueWhere(bool Function(K key, V value) f, {V Function() orElse}) {
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        return entry.value;
      }
    }
    if (orElse.isNotNull) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the single entry that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  ///
  /// Multiple matches will always throw a [StateError].
  MapEntry<K, V> singleEntryWhere(bool Function(K key, V value) f,
      {MapEntry<K, V> Function() orElse}) {
    var alreadyFound = false;
    MapEntry<K, V> match;
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        if (alreadyFound == true) throw StateError('Too many matches!');
        match = entry;
        alreadyFound = true;
      }
    }
    if (alreadyFound) return match;
    if (orElse.isNotNull) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the single key that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  ///
  /// Multiple matches will always throw a [StateError].
  K singleKeyWhere(bool Function(K key, V value) f, {K Function() orElse}) {
    var alreadyFound = false;
    K match;
    for (final entry in entries) {
      if (f(entry.key, entry.value)) {
        if (alreadyFound == true) throw StateError('Too many matches!');
        match = entry.key;
        alreadyFound = true;
      }
    }
    if (alreadyFound) return match;
    if (orElse.isNotNull) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the single value that satisfies the predicate.
  ///
  /// If none match, the `orElse` function will be run. If not provided, a [StateError] is thrown.
  ///
  /// Multiple matches will always throw a [StateError].
  V singleValueWhere(bool Function(K key, V value) f, {V Function() orElse}) {
    var alreadyFound = false;
    V match;
    for (final key in keys) {
      if (f(key, this[key])) {
        if (alreadyFound == true) throw StateError('Too many matches!');
        match = this[key];
        alreadyFound = true;
      }
    }
    if (alreadyFound) return match;
    if (orElse.isNotNull) return orElse();
    throw StateError('No entry satisfies the function!');
  }

  /// Returns the map where the keys and values within `this` are returned.
  ///
  /// If the values aren't unique, the key associated with the final occurence of the value becomes the value of the new map.
  ///
  /// For exmaple,
  ///
  /// ````
  ///  Map<String, int> stringToNumber = {'one': 1, 'two': 2, 'three': 3, 'four': 4};
  ///  Map<int, String> numbersToString = stringToNumber.reverse();
  ///  print(numbersToString); // {1: 'one', 2: 'two', 3: 'three', 4: 'four'}
  /// ````
  Map<V, K> reverse() {
    final map = <V, K>{};
    for (final key in keys) {
      map[this[key]] = key;
    }
    return map;
  }

  /// Expands a [Map] by iterating over every entry and replacing it with another [Map].
  ///
  /// Doesn't modify `this`.
  Map<RK, RV> expand<RK, RV>(Map<RK, RV> Function(K key, V value) f) {
    final map = <RK, RV>{};
    forEach((key, value) {
      map.addAll(f(key, value));
    });
    return map;
  }
}

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
