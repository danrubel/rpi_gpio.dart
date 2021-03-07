import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'basic_test.dart' as basic;
import 'debouncer_test.dart' as debouncer;
import 'example_test.dart' as example;
import 'io_test.dart' as io;
import 'test_util.dart';

main() {
  group('basic', () => basic.main());
  test('instantiate', () => gpio = RpiGpio());
  group('io', () => io.runTests());
  test('dispose', () => gpio.dispose());
  // example
  group('debouncer', () => debouncer.main());
  group('example', () => example.main());
}
