library test.rpi_gpio;

import 'dart:async';
import 'dart:isolate';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;
import 'package:rpi_gpio/rpi_isolate.dart';
import 'package:unittest/unittest.dart';

import 'recording_hardware.dart';

main() async {
  GpioClient client = new GpioClient();
  await client.spawn(_runGpioServer);
  RecordingHardware hardware = new RecordingHardware(client);
  Gpio.hardware = hardware;

  // Current test hardware configuration:
  // pin 0 (BMC_GPIO 17, Phys 11) uses a photo resistor to measure
  //     the brightness of the LED driven by pin 1.
  // pin 1 (BMC_GPIO 18, Phys 12) drives an LED where 0 is off.
  group('rpi_gpio', () {
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
    test('pull up/down', () async {
      var pin = gpio.pin(4, input);
      expect(pin.pull, pullOff);
      pin.pull = pullUp;
      await _delay(5);
      expect(pin.value, 1);
      expect(pin.pull, pullUp);
      pin.pull = null;
      expect(pin.pull, pullOff);
      pin.pull = pullDown;
      await _delay(5);
      expect(pin.value, 0);
      expect(pin.pull, pullDown);
      pin.pull = pullOff;
      expect(pin.pull, pullOff);
    });

    // This test assumes that output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
    // can be read as input on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
    test('digitalWrite and digitalRead', () async {
      Pin sensorPin = gpio.pin(0, input)..pull = pullDown;
      Pin ledPin = gpio.pin(1, output)..value = 0;
      await _delay(5);
      expect(sensorPin.value, 0);
      for (int count = 0; count < 3; ++count) {
        ledPin.value = 1;
        await _delay(250);
        expect(sensorPin.value, 1);
        ledPin.value = 0;
        await _delay(250);
        expect(sensorPin.value, 0);
      }
    });

    // This test assumes that output from wiringPi pin 1 (BMC_GPIO 18, Phys 12)
    // can be read as input on wiringPi pin 0 (BMC_GPIO 17, Phys 11).
    // In addition, it assumes that at some point when the pin 1 pulse width
    // reaches some threshold, the input for pin 0 will transition from
    // one state to another.
    test('pulseWidth and digitalRead - hardware pwm gpio.1', () async {
      Pin sensorPin = gpio.pin(0, input)..pull = pullDown;
      Pin ledPin = gpio.pin(1, pulsed)..pulseWidth = 0;
      await _delay(250);
      expect(sensorPin.value, 0);

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
      await _delay(250);
      expect(sensorPin.value, 0);

      // Increase and note threshold at which pin 0 state changes
      int thresholdUp = await _pwmUp(ledPin, sensorPin);

      // Decrease and note threshold at which pin 0 state changes
      int thresholdDown = await _pwmDown(ledPin, sensorPin);
      //expect((thresholdDown - thresholdUp).abs(), lessThanOrEqualTo(20));

      print('software pwm thresholds - $thresholdUp, $thresholdDown');
    });

    test('pins used', () {
      if (hardware != null) hardware.printUsage(gpio);
    });

    // must be the last test to stop the GPIO isolate
    test('stop isolate', () {
      client.stop();
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
    if (thresholdDown == null) await _delay(250);
    int value = sensorPin.value;
    if (thresholdDown == null && value == 0) thresholdDown = pulseWidth;
    expect(value, thresholdDown == null ? 1 : 0);
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
    if (thresholdUp == null) await _delay(250);
    int value = sensorPin.value;
    if (thresholdUp == null && value == 1) thresholdUp = pulseWidth;
    expect(value, thresholdUp == null ? 0 : 1);
  }
  expect(thresholdUp, isNotNull);
  expect(thresholdUp, greaterThan(0));
  expect(thresholdUp, lessThan(1000));
  return thresholdUp;
}

/// Run the [_GpioServer] for interacting directly with the hardware
/// and providing/simulating PWM for pins other than pin 1.
Future _runGpioServer(SendPort sendPort) async {
  GpioHardware hardware;
  if (isRaspberryPi) {
    // Load the Raspberry Pi native method library if running on the RPi
    await rpi.loadLibrary();
    hardware = new rpi.RpiHardware();
  } else {
    // Create mock hardware when testing code on other platforms
    hardware = new MockHardware();
  }
  new GpioServer(hardware, sendPort).run();
}

/// Mock hardware for testing the [Gpio] library. This simulates
/// pin 3 connected to an LED,
/// pin 2 connected to a photo sensor which detects the state of the LED,
/// pin 1 connected to an LED,
/// pin 0 connected to a photo sensor which detects the state of the LED.
/// Also, pin 3 with a pull up/down resistor setting
class MockHardware implements GpioHardware {
  List<int> values = <int>[0, 0, 0, 0, null];

  @override
  int digitalRead(int pinNum) {
    // Simulate pin 0 input hooked to pin 1 output
    // and pin 2 input hooked to pin 3 output
    if (pinNum == 0) return values[1];
    if (pinNum == 2) return values[3];
    if (pinNum == 4) return values[4];
    return 0;
  }

  @override
  void digitalWrite(int pinNum, int value) {
    if (pinNum == 1) values[1] = value != 0 ? 1 : 0;
    if (pinNum == 3) values[3] = value != 0 ? 1 : 0;
  }

  @override
  void pinMode(int pinNum, int modeIndex) {
    // validated by RecordingHardware
  }

  @override
  void pullUpDnControl(int pinNum, int pud) {
    if (pinNum == 4) {
      if (pud == 2) {
        values[4] = 1;
      } else if (pud == 1) {
        values[4] = 0;
      } else {
        values[4] = null;
      }
    }
  }

  @override
  void pwmWrite(int pinNum, int pulseWidth) {
    // Simulate hardware pwm on pin 1 and software pwm on pin 3
    if (pinNum == 1) values[1] = pulseWidth > 500 ? 1 : 0;
    if (pinNum == 3) values[3] = pulseWidth > 500 ? 1 : 0;
  }
}
