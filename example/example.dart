import 'package:rpi_gpio/rpi_gpio.dart';

import 'exampleApp.dart';

/// Launch the example by injecting an instance of [RpiGpio].
/// This only works on the Raspberry Pi.
///
/// The [exampleApp] resides in a separate library
/// so that it does not reference the [RpiGpio] native libary
/// and thus can be tested with a mock [Gpio] on any platform.
main() async {
  final gpio = RpiGpio();
  await runExample(gpio);
  gpio.dispose();
}
