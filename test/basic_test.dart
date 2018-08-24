import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:test/test.dart';

import 'test_util.dart';

main() => runTests(new RpiGpio());

runTests(Gpio gpio) {
  test('const', () {
    expect(Pull.off.index, 0);
    expect(Pull.down.index, 1);
    expect(Pull.up.index, 2);
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
  });
}
