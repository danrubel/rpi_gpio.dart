library test.rpi_gpio.basic;

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'mock_hardware.dart';
import 'test_util.dart';

// Current test hardware configuration:
// pin 4 unconnected but with an internal pull up/down resistor setting
// pin 3 = an LED (1 = on, 0 = off)
// pin 2 = a photo resistor detecting the state of the LED on pin 3
// pin 1 = an LED (1 = on, 0 = off)
// pin 0 = a photo resistor detecting the state of the LED on pin 1

main() async {
  await setupHardware();
  runTests();
}

runTests() {
  // Assert wiringPi consts
  test('basic const', () {
    expect(Mode.input.index, 0);
    expect(Mode.output.index, 1);
    expect(Mode.other.index, 2);
    expect(Pull.off.index, 0);
    expect(Pull.down.index, 1);
    expect(Pull.up.index, 2);
  });

  // Assert that pins cannot be used contrary to their current mode
  test('basic mode', () {
    expectThrows(f()) {
      try {
        f();
        fail('expected exception');
      } on GPIOException {
        // Expected... fall through
      }
    }

    // Cannot set value on input pin
    expectThrows(() => pin(0, Mode.input).value = true);

    // Cannot set pulseWidth of input pin
    expectThrows(() => pin(1, Mode.input).pulseWidth = 10);

    // Pulse width only support on Pin 1
    expectThrows(() => pin(3, Mode.output).pulseWidth = 10);

    // Cannot get value of output pin
    expectThrows(() => pin(1, Mode.output).value);

    // Cannot set pull up for output pin
    expectThrows(() => pin(4, Mode.output).pull = Pull.up);
    expectThrows(() => pin(4, Mode.output).pull = Pull.down);
    expectThrows(() => pin(4, Mode.output).pull = Pull.off);

    // Cannot set other mode
    expectThrows(() => pin(4, Mode.other));
//
//      fail('Does wiringPi throw an exception'
//          ' if PWM is used on a pin other than pin 1?');
//
//      fail('Does wiringPi throw an exception'
//          ' if clock mode is used on a pin other than pin X?');
//
//      fail('Does wiringPi throw an exception'
//          ' if pin is set to an invalid mode?');
  });

  // Assert that each pin is represented by a single instance
  // regardless of mode.
  test('basic identical', () {
    var pinA = pin(4, Mode.output);
    expect(pinA.mode, Mode.output);
    var pinB = pin(4, Mode.input);
    expect(pinB.mode, Mode.input);
    expect(identical(pinA, pinB), isTrue);
  });

  // Test the pull up and pull down resistor settings
  // on a disconnected pin
  test('basic pull up/down', () {
    var pin4 = pin(4, Mode.input);
    expect(pin4.pull, Pull.off);
    pin4.pull = Pull.up;
    assertValue(pin4, true);
    expect(pin4.pull, Pull.up);
    pin4.pull = null;
    expect(pin4.pull, Pull.off);
    pin4.pull = Pull.down;
    assertValue(pin4, false);
    expect(pin4.pull, Pull.down);
    pin4.pull = Pull.off;
    expect(pin4.pull, Pull.off);
  });

  test('description', () {
    if (hardware is MockHardware) {
      expect(pin(0, Mode.input).description, 'Pin 0');
      expect(pin(1, Mode.input).description, 'Pin 1');
      // expect(hardware.description(0), 'Pin 0');
      // expect(hardware.description(1), 'Pin 1');
    } else {
      expect(hardware.description(0), 'Pin 0 (BMC_GPIO 17, Phys 11)');
      expect(hardware.description(1), 'Pin 1 (BMC_GPIO 18, Phys 12, PWM)');
      expect(pin(0, Mode.input).description, hardware.description(0));
      expect(pin(1, Mode.input).description, hardware.description(1));
    }
  });
}
