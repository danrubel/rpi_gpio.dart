import 'dart:io';

import 'list_functions.dart';

void main() async {
  var actualFunctNames = listFunctions()..sort();
  var expectedFunctNames = File('lib/src/native/gpiod_ext.g.dart') //
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.startsWith('.lookup'))
      .map((line) => line.split("'")[1])
      .toList()
    ..sort();

  var errorCount = 0;
  var actualIndex = 0;
  var expectedIndex = 0;
  while (actualIndex < actualFunctNames.length &&
      expectedIndex < expectedFunctNames.length) {
    var actualName = actualFunctNames[actualIndex];
    var expectedName = expectedFunctNames[expectedIndex];
    if (actualName == expectedName) {
      ++actualIndex;
      ++expectedIndex;
    } else {
      ++errorCount;
      if (actualName.compareTo(expectedName) < 0) {
        print('  missing: $actualName');
        ++actualIndex;
      } else {
        print('  unknown: $expectedName');
        ++expectedIndex;
      }
    }
  }

  print('Found $errorCount missing or unknown functions');
}
