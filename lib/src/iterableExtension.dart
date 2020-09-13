part of '../corextensions.dart';

extension IterableCorextension<E> on Iterable<E> {
  /// Returns the first element that is not `null` following the `fn` map.
  E firstWhereNotNull<L>(L Function(E element) fn) =>
      firstWhere((element) => fn(element) != null);

  /// Returns another iterable where all the elements that are not `null` (following the `fn` map).
  Iterable<E> whereNotNull<L>(L Function(E element) fn) =>
    where((element) => fn(element) != null);

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
        if (index != null) {
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
        if (index != null) {
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

    if (index == null) {
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
        if (differentElementIndex != null) {
          throw StateError(
              "There's more than one different element in the two iterables!");
        }
        differentElementIndex = i;
      }
      endOfBothList = couldMoveThat == false && couldMoveThis == false;
      i++;
    } while (!endOfBothList);
    if (differentElementIndex == null) {
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
    if (orElse != null) return orElse();
    throw StateError('No element!');
  }

  /// Given a function that returns a [num], returns the element in `this` that returns the smallest value.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [-2, 15, -10, 4];
  /// int smallestAbsolute = numbers.smallestWhere.((element) => element.abs());
  /// print(smallestAbsolute); // -2
  /// ```
  E smallestWhere(num Function(E element) function) =>
      reduce((value, element) =>
          function(value) < function(element) ? value : element);

  /// Given a function that returns a [num], returns the element in `this` that returns the largest value.
  ///
  /// For example,
  ///
  /// ```
  /// List<int> numbers = [-2, 15, -10, 4];
  /// int largestAbsolute = numbers.largestWhere.((element) => element.abs());
  /// print(largestAbsolute); // 15
  /// ```
  E largestWhere(num Function(E element) function) =>
      reduce((value, element) =>
          function(value) < function(element) ? element : value);

  /// Give a function that returns an [int] or [double], returns the sum of all the values.
  /// 
  /// For example,
  /// ```
  /// List<int> numbers = [1, 5, 8];
  /// int sum = numbers.sumWhere((element) => element);
  /// print(sum); // 14
  /// ```
  T sumWhere<T extends num>(T Function(E element) function){
    final zero = T == int ? 0 as T: 0.0 as T;
    return fold(zero, (previousValue, element) => previousValue + function(element));
  }

  
  /// Give a function that returns an [int] or [double], returns the product of all the values.
  /// 
  /// For example,
  /// ```
  /// List<int> numbers = [1, 5, 8];
  /// int sum = numbers.productWhere((element) => element);
  /// print(sum); // 40
  /// ```
  T productWhere<T extends num>(T Function(E element) function){
    final one = T == int ? 1 as T : 1.0 as T;
    return fold(one, (previousValue, element) => previousValue * function(element));
  }

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
