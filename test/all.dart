import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'basic_test.dart' as basic;
import 'io_test.dart' as io;
import 'pwm_test.dart' as pwm;

main() {
  RpiGpio gpio = new RpiGpio();
  group('basic', () => basic.runTests(gpio));
  group('io', () => io.runTests(gpio));
  group('pwm', () => pwm.runTests(gpio));
}
