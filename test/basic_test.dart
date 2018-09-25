import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'test_util.dart';

main() {
  test('const', () {
    expect(Pull.off.index, 0);
    expect(Pull.down.index, 1);
    expect(Pull.up.index, 2);
  });

  RpiGpio gpio;
  test('instantiate', () {
    gpio = new RpiGpio();
  });

  test('exceptions', () async {
    // Only one instance of GPIO factory
    try {
      new RpiGpio();
      fail('expected exception');
    } on GpioException {
      // Expected... fall through
    }

    // Cannot allocate non-GPIO pins
    expectThrows(() => gpio.output(1)); // 3.3V
    expectThrows(() => gpio.output(6)); // GND

    // Cannot allocate I2C or SPI pins
    expectThrows(() => gpio.output(3)); // I2C
    expectThrows(() => gpio.output(19)); // SPI0
  });

  test('dispose', () => gpio.dispose());

  test('allow I2C and SPI as GPIO', () {
    gpio = new RpiGpio(i2c: false, spi: false);
    try {
      expect(gpio.output(3), isNotNull); // I2C
      expect(gpio.output(19), isNotNull); // SPI0
    } finally {
      gpio.dispose();
    }
  });
}
