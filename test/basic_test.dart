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
  var gpio = Gpio.instance;

  // Assert wiringPi consts
  test('basic const', () {
    expect(input.index, 0);
    expect(output.index, 1);
    expect(pulsed.index, 2);
    expect(pullOff.index, 0);
    expect(pullDown.index, 1);
    expect(pullUp.index, 2);
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
    expectThrows(() => gpio.pin(0, input).value = 1);
    expectThrows(() => gpio.pin(1, output).value);
    expectThrows(() => gpio.pin(1, output).pulseWidth = 10);
    expectThrows(() => gpio.pin(4, output).pull = pullUp);
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
    var pinA = gpio.pin(4, output);
    expect(pinA.mode, output);
    var pinB = gpio.pin(4, input);
    expect(pinB.mode, input);
    expect(identical(pinA, pinB), isTrue);
  });

  // Test the pull up and pull down resistor settings
  // on a disconnected pin
  test('basic pull up/down', () {
    var pin = gpio.pin(4, input);
    expect(pin.pull, pullOff);
    pin.pull = pullUp;
    assertValue(pin, 1);
    expect(pin.pull, pullUp);
    pin.pull = null;
    expect(pin.pull, pullOff);
    pin.pull = pullDown;
    assertValue(pin, 0);
    expect(pin.pull, pullDown);
    pin.pull = pullOff;
    expect(pin.pull, pullOff);
  });
}
