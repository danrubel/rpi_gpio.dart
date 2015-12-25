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
    expect(Mode.pulsed.index, 2);
    expect(pullOff.index, 0);
    expect(pullDown.index, 1);
    expect(pullUp.index, 2);
  });

  // Assert pinNum to gpioNum
  test('gpioNum', () {
    expect(pin(0, Mode.input).gpioNum, 17);
    expect(pin(1, Mode.input).gpioNum, 18);
    expect(pin(2, Mode.input).gpioNum, 27);
    expect(pin(3, Mode.input).gpioNum, 22);
  });

  // Assert that pins cannot be used contrary to their current mode
  test('basic mode', () {
    expectThrows(f()) {
      try {
        f();
        fail('expected exception');
      } on GpioException {
        // Expected... fall through
      }
    }
    expectThrows(() => pin(0, Mode.input).value = 1);
    expectThrows(() => pin(1, Mode.output).value);
    expectThrows(() => pin(1, Mode.output).pulseWidth = 10);
    expectThrows(() => pin(4, Mode.output).pull = pullUp);
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
    expect(pin4.pull, pullOff);
    pin4.pull = pullUp;
    assertValue(pin4, 1);
    expect(pin4.pull, pullUp);
    pin4.pull = null;
    expect(pin4.pull, pullOff);
    pin4.pull = pullDown;
    assertValue(pin4, 0);
    expect(pin4.pull, pullDown);
    pin4.pull = pullOff;
    expect(pin4.pull, pullOff);
  });
}
