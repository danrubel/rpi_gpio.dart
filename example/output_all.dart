import 'package:rpi_gpio/rpi_gpio.dart';

import 'output_all_app.dart';

/// Launch the example by injecting an instance of [RpiGpio].
/// This only works on the Raspberry Pi.
///
/// The [example_app] resides in a separate library
/// so that it does not reference the [RpiGpio] native libary
/// and thus can be tested with a mock [Gpio] on any platform.
void main(List<String> args) async {
  args = args.toList();

  var skipI2c = args.remove('--skip-i2c');
  var skipSpi = args.remove('--skip-spi');
  var skipEeprom = args.remove('--skip-eeprom');
  var skipUart = args.remove('--skip-uart');

  if (args.isNotEmpty) throw 'Unknown arguments: $args';

  final gpio = await initialize_RpiGpio(
      i2c: skipI2c, spi: skipSpi, eeprom: skipEeprom, uart: skipUart);
  await runAllOutput(gpio, skipI2c, skipSpi, skipEeprom, skipUart);
}
