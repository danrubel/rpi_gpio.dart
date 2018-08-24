import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

main() => runTests(new RpiGpio());

runTests(Gpio gpio) {
  // Current test hardware configuration:
  // pin 12 = output connected to a 1K resistor to an LED to GND

  test('fade on/off', () async {
    GpioPwmOutput pwm = gpio.pwmOutput(12);
    final delay = new Duration(milliseconds: 1);

    for (int count = 0; count < 2; ++count) {
      for (int value = 0; value <= 1024; ++value) {
        pwm.pwmValue = value;
        await new Future.delayed(delay);
      }
      for (int value = 1024; value >= 0; --value) {
        pwm.pwmValue = value;
        await new Future.delayed(delay);
      }
    }
  });
}
