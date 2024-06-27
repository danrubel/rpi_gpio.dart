import 'dart:io';

import 'package:rpi_gpio/src/native/gpiod_ext.dart' as gpio;

void main() async {
  var functNames = listFunctions()..sort();
  for (var name in functNames) {
    print('  $name');
  }
  print('${functNames.length} functions');
}

List<String> listFunctions() {
  var libPath = gpio.findNativePkgLibPath();
  print('Found GPIO library: $libPath');

  ProcessResult result = Process.runSync('nm', ['-D', libPath]);
  if (result.exitCode != 0) {
    throw Exception('Failed to list GPIO functions: ${result.exitCode}'
        '\n${result.stdout}\n${result.stderr}');
  }

  return result.stdout //
      .toString()
      .split('\n')
      .where((line) => line.contains(' T '))
      .map((line) => line.split(' T ')[1])
      .toList();
}
