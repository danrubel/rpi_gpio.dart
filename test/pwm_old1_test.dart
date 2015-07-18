library test.rpi_gpio;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'test_util.dart';

main() async {
  await setupHardware();

  // Current test hardware configuration:
  // pin 4 unconnected but with an internal pull up/down resistor setting
  // pin 3 = an LED (1 = on, 0 = off)
  // pin 2 = a photo resistor detecting the state of the LED on pin 3
  // pin 1 = an LED (1 = on, 0 = off)
  // pin 0 = a photo resistor detecting the state of the LED on pin 1
  group('Gpio', () {
    var gpio = Gpio.instance;

    // This test assumes that output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
    // can be read as input on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
    // In addition, it assumes that at some point when the pin 1 pulse width
    // reaches some threshold, the input for pin 0 will transition from
    // one state to another.
    test('pulseWidth and digitalRead - hardware pwm gpio.1', () async {
      Pin sensorPin = gpio.pin(0, input)..pull = pullDown;
      Pin ledPin = gpio.pin(1, pulsed)..pulseWidth = 0;
      assertValue(sensorPin, 0);

      // Increase and note threshold at which pin 0 state changes
      int thresholdUp = await _pwmUp(ledPin, sensorPin);

      // Decrease and note threshold at which pin 0 state changes
      int thresholdDown = await _pwmDown(ledPin, sensorPin);
      expect((thresholdDown - thresholdUp).abs(), lessThanOrEqualTo(20));

      print('hardware pwm thresholds - $thresholdUp, $thresholdDown');
    });

    // This test assumes that output from wiringPi pin 3 (BMC_GPIO 22, Phys 15)
    // can be read as input on wiringPi pin 2  (BMC_GPIO 27, Phys 13).
    // In addition, it assumes that at some point when the pin 3 pulse width
    // reaches some threshold, the input for pin 2 will transition from
    // one state to another.
    test('pulseWidth and digitalRead - software pwm gpio.3', () async {
      Pin sensorPin = gpio.pin(2, input)..pull = pullDown;
      Pin ledPin = gpio.pin(3, pulsed)..pulseWidth = 0;
      assertValue(sensorPin, 0);

      // Increase and note threshold at which pin 0 state changes
      int thresholdUp = await _pwmUp(ledPin, sensorPin);

      // Decrease and note threshold at which pin 0 state changes
      int thresholdDown = await _pwmDown(ledPin, sensorPin);
      //expect((thresholdDown - thresholdUp).abs(), lessThanOrEqualTo(20));

      print('software pwm thresholds - $thresholdUp, $thresholdDown');
    });

    test('pins used', () {
      // Ensure LEDs are off
      gpio.pin(1, output)..value = 0;
      gpio.pin(3, output)..value = 0;
      // Print pin state changes
      if (recording != null) recording.printUsage(gpio);
    });
  });
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}

Future<int> _pwmDown(Pin ledPin, Pin sensorPin) async {
  int thresholdDown;
  for (int pulseWidth = 1024; pulseWidth >= 0; pulseWidth -= 10) {
    ledPin.pulseWidth = pulseWidth;
    if (thresholdDown == null) await _delay(25);
    int value = sensorPin.value;
    if (thresholdDown == null && value == 0) thresholdDown = pulseWidth;
  }
  expect(thresholdDown, isNotNull);
  expect(thresholdDown, greaterThan(0));
  expect(thresholdDown, lessThan(1000));
  return thresholdDown;
}

Future<int> _pwmUp(Pin ledPin, Pin sensorPin) async {
  int thresholdUp;
  for (int pulseWidth = 0; pulseWidth <= 1024; pulseWidth += 10) {
    ledPin.pulseWidth = pulseWidth;
    if (thresholdUp == null) await _delay(25);
    int value = sensorPin.value;
    if (thresholdUp == null && value == 1) thresholdUp = pulseWidth;
  }
  expect(thresholdUp, isNotNull);
  expect(thresholdUp, greaterThan(0));
  expect(thresholdUp, lessThan(1000));
  return thresholdUp;
}
