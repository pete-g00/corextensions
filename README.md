# Corextensions

The corextensions package is made up of many extensions on core classes such as `String`, `List` and `Iterable`.

## Getting Started

To import this package, include the following code:

``` dart
import 'package:corextensions/corextensions.dart';
```

## Example Properties

For example, the following lists a few of these extensions:

* `Iterable.isSingle` returns `true` if an iterable has length 1.
* `Iterable.smallestWhere` returns the smallest value in this iterable following a mapping to `num`.
* `Iterable.hasSameLengthAs` returns `true` if the length of this iterable is the same as the other iterable provided.
* `Iterable.count` returns the number of times a value is present in the iterable.
* `List.mapWithIndex` returns an iterable which has been mapped using this list, where we are provided with both the value at the index, and the index itself.
* `List.hasDuplicates` returns `true` if the list has an element present more than once, checked by the equality `operator ==`.
* `List.swap` swaps two elements within the list.
* `List.allIndicesOf` returns all the indices of a value in the list.
* `Set.equals` returns `true` if this set has the same values as the other set, in any order.
* `Iterable.sumWhere` returns the sum of elements in the iterable following a function returning a number.
* `String.capitalise` returns the string with the first letter replaced with the original one in upper case.
* `String.removeExtraSpace` returns the string with whitespace removed from not just the start and the end, but also the middle, with the assumption that there should only be 1 space between 2 words.
* `String.splitByAll` splits the string by all the delimiters provided.
* `String.replaceLast` replaces the last occurence of a substring from the string.
* `Map.firstValueWhere` returns the first value that satisfies the provided function.
* `Map.reverse` flips keys and values.

On top of these, there is also the function `zipTwoLists` which zips two lists in the provided order.

Examples using these properties can be found in the [example](https://pub.dev/packages/corextensions/example) section.

Documentation on the package can be found [here](https://pub.dev/documentation/corextensions/latest/corextensions/corextensions-library.html).

## Features and bugs 

To suggest additional properties or report bugs, report it [here](https://github.com/pete-g00/corextensions/issues).