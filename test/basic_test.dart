library test.rpi_gpio.basic;

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

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

  // Assert physical pin mapping
  test('physNum', () {
    expect(hardware.physPinToGpio(1), -1); // 3.3 V
    expect(hardware.physPinToGpio(2), -1); // 5 V
    expect(hardware.physPinToGpio(11), 17); // pin 0 gpio 17
    expect(hardware.physPinToGpio(12), 18); // pin 1 gpio 18
    expect(hardware.physPinToGpio(16), 23); // pin 4 gpio 23
    expect(pin(0, Mode.input).physNum, 11);
    expect(pin(1, Mode.input).physNum, 12);
    expect(pin(4, Mode.input).physNum, 16);
  });

  // Assert pinNum to gpioNum
  test('gpioNum', () {
    expect(pin(0, Mode.input).gpioNum, 17);
    expect(pin(1, Mode.input).gpioNum, 18);
    expect(pin(2, Mode.input).gpioNum, 27);
    expect(pin(3, Mode.input).gpioNum, 22);
    expect(pin(4, Mode.input).gpioNum, 23);
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
    expectThrows(() => pin(0, Mode.input).value = 1);

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
    assertValue(pin4, 1);
    expect(pin4.pull, Pull.up);
    pin4.pull = null;
    expect(pin4.pull, Pull.off);
    pin4.pull = Pull.down;
    assertValue(pin4, 0);
    expect(pin4.pull, Pull.down);
    pin4.pull = Pull.off;
    expect(pin4.pull, Pull.off);
  });
}
