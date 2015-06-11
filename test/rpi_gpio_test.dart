library test.rpi_gpio;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;
import 'package:unittest/unittest.dart';

import 'mock_hardware.dart';
import 'recording_hardware.dart';

main() async {

  // Load the Raspberry Pi native method library if running on the RPi
  // otherwise create mock hardware for testing code on other platforms.
  GpioHardware hardware;
  if (isRaspberryPi) {
    await rpi.loadLibrary();
    hardware = new rpi.RpiHardware();
  } else {
    hardware = new MockHardware();
  }

  // Wrap the low level or mock hardware to record, validate, and display
  // which pins are used and for what purpose.
  RecordingHardware recording = new RecordingHardware(hardware);
  Gpio.hardware = recording;

  // Current test hardware configuration:
  // pin 4 unconnected but with an internal pull up/down resistor setting
  // pin 3 = an LED (1 = on, 0 = off)
  // pin 2 = a photo resistor detecting the state of the LED on pin 3
  // pin 1 = an LED (1 = on, 0 = off)
  // pin 0 = a photo resistor detecting the state of the LED on pin 1
  group('Gpio', () {
    var gpio = Gpio.instance;

    // Assert wiringPi consts
    test('const', () {
      expect(input.index, 0);
      expect(output.index, 1);
      expect(pulsed.index, 2);
      expect(pullOff.index, 0);
      expect(pullDown.index, 1);
      expect(pullUp.index, 2);
    });

    // Assert that pins cannot be used contrary to their current mode
    test('mode', () {
      expectThrows(f()) {
        try {
          f();
          fail('expected exception');
        } on GpioException {
          // Expected... fall through
        }
      }
      expectThrows(() => gpio.pin(0, input).value = 1);
      expectThrows(() => gpio.pin(1, output).value);
      expectThrows(() => gpio.pin(1, output).pulseWidth = 10);
      expectThrows(() => Gpio.instance.pin(4, output).pull = pullUp);
//
//      fail('Does wiringPi throw an exception'
//          ' if PWM is used on a pin other than pin 1?');
//
//      fail('Does wiringPi throw an exception'
//          ' if clock mode is used on a pin other than pin X?');
//
//      fail('Does wiringPi throw an exception'
//          ' if value read from output pin or vise versa?');
//
//      fail('Does wiringPi throw an exception'
//          ' if pin is set to an invalid mode?');
    });

    // Assert that each pin is represented by a single instance
    // regardless of mode.
    test('identical', () {
      var pinA = gpio.pin(4, output);
      expect(pinA.mode, output);
      var pinB = gpio.pin(4, input);
      expect(pinB.mode, input);
      expect(identical(pinA, pinB), isTrue);
    });

    // Test the pull up and pull down resistor settings
    // on a disconnected pin
    test('pull up/down', () {
      var pin = gpio.pin(4, input);
      expect(pin.pull, pullOff);
      pin.pull = pullUp;
      _assertValue(pin, 1);
      expect(pin.pull, pullUp);
      pin.pull = null;
      expect(pin.pull, pullOff);
      pin.pull = pullDown;
      _assertValue(pin, 0);
      expect(pin.pull, pullDown);
      pin.pull = pullOff;
      expect(pin.pull, pullOff);
    });

    // This test assumes that output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
    // can be read as input on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
    test('digitalWrite and digitalRead', () {
      Pin sensorPin = gpio.pin(0, input)..pull = pullDown;
      Pin ledPin = gpio.pin(1, output)..value = 0;
      _assertValue(sensorPin, 0);
      for (int count = 0; count < 3; ++count) {
        ledPin.value = 1;
        _assertValue(sensorPin, 1);
        ledPin.value = 0;
        _assertValue(sensorPin, 0);
      }
    });

    // This test assumes that output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
    // can trigger an interrupt on wiringPi pin 0 (BMC_GPIO 17, Phys 11),
    // and output from wiringPi pin 3 (BMC_GPIO 22, Phys 15)
    // can be read as input on wiringPi pin 2  (BMC_GPIO 27, Phys 13).
    test('interrupts', () async {
      Pin sensorPin;
      Pin ledPin;

      testInterrupt() async {
        _assertValue(sensorPin, 0);
        var expectedSensorValue;
        var completer;
        var subscription = sensorPin.events.listen((PinEvent event) {
          if (!identical(event.pin, sensorPin)) fail('expected sensor pin');
          if (event.value == expectedSensorValue) completer.complete();
        });

        // When LED turns on, assert that a sensor pin interrupt occurred
        // and that the sensor value is 1.
        expectedSensorValue = 1;
        var waitTime = new Duration(milliseconds: 100);
        completer = new Completer();
        var future = completer.future.timeout(waitTime).catchError((e) {
          subscription.cancel();
          throw e;
        });
        ledPin.value = 1;
        await future;

        // When LED turns off, assert that a sensor pin interrupt occurred
        // and that the sensor value is 0.
        expectedSensorValue = 0;
        completer = new Completer();
        future = completer.future.timeout(waitTime).whenComplete(() {
          subscription.cancel();
        });
        ledPin.value = 0;
        await future;
      }

      sensorPin = gpio.pin(0, input)..pull = pullDown;
      ledPin = gpio.pin(1, output)..value = 0;
      await testInterrupt();

      sensorPin = gpio.pin(2, input)..pull = pullDown;
      ledPin = gpio.pin(3, output)..value = 0;
      await testInterrupt();
    });

    // This test assumes that output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
    // can be read as input on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
    // In addition, it assumes that at some point when the pin 1 pulse width
    // reaches some threshold, the input for pin 0 will transition from
    // one state to another.
    test('pulseWidth and digitalRead - hardware pwm gpio.1', () async {
      Pin sensorPin = gpio.pin(0, input)..pull = pullDown;
      Pin ledPin = gpio.pin(1, pulsed)..pulseWidth = 0;
      _assertValue(sensorPin, 0);

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
      _assertValue(sensorPin, 0);

      // Increase and note threshold at which pin 0 state changes
      int thresholdUp = await _pwmUp(ledPin, sensorPin);

      // Decrease and note threshold at which pin 0 state changes
      int thresholdDown = await _pwmDown(ledPin, sensorPin);
      //expect((thresholdDown - thresholdUp).abs(), lessThanOrEqualTo(20));

      print('software pwm thresholds - $thresholdUp, $thresholdDown');
    });

    test('pins used', () {
      if (recording != null) recording.printUsage(gpio);
    });
  });
}

DateTime get _now => new DateTime.now();

_assertValue(Pin pin, int expectedValue) {
  DateTime end = _now.add(new Duration(milliseconds: 250));
  while (_now.isBefore(end)) {
    if (pin.value == expectedValue) return;
  }
  fail('Expected $expectedValue on $pin');
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
