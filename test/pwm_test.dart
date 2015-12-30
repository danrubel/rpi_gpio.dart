library test.rpi_gpio.pwm;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'test_util.dart';

main() async {
  await setupHardware();
  runTests();
}

/// Test PWM (Pulse Width Modulation) on pin 1
///
/// Current test hardware configuration:
/// pin 1 = an LED (1 = on, 0 = off)
/// pin 0 = a photo resistor detecting the state of the LED on pin 1
/// This test assumes that [Mode.output] from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
/// can be read as [Mode.input] on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
/// In addition, it assumes that at some point when the pin 1 pulse width
/// reaches some threshold, the [Mode.input] for pin 0 will transition from
/// one state to another.
runTests() {
  test('pwm', () async {
    // Setup
    Pin sensorPin = pin(0, Mode.input)..pull = Pull.down;
    Pin ledPin = pin(1, Mode.output)
      ..value = 0
      ..pulseWidth = 0;
    assertValue(sensorPin, 0);

    // Increase pulse width until the sensor registers the light
    int thresholdUp;
    for (int pulseWidth = 0; pulseWidth <= 1024; pulseWidth += 10) {
      ledPin.pulseWidth = pulseWidth;
      if (thresholdUp == null) await _delay(25);
      int value = sensorPin.value;
      if (thresholdUp == null && value == 1) thresholdUp = pulseWidth;
    }
    print('pin 1 pwm thresholdUp = $thresholdUp');

    // Decrease pulse width until the sensor stops registering the light
    int thresholdDown;
    for (int pulseWidth = 1024; pulseWidth >= 0; pulseWidth -= 10) {
      ledPin.pulseWidth = pulseWidth;
      if (thresholdDown == null) await _delay(25);
      int value = sensorPin.value;
      if (thresholdDown == null && value == 0) thresholdDown = pulseWidth;
    }
    print('pin 1 pwm thresholdDown = $thresholdDown');
  });
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}
