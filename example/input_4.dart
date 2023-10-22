import 'package:rpi_gpio/rpi_gpio.dart';

import 'input_4_app.dart';

/// Launch the example by injecting an instance of [RpiGpio].
/// This only works on the Raspberry Pi.
///
/// The [example_app] resides in a separate library
/// so that it does not reference the [RpiGpio] native libary
/// and thus can be tested with a mock [Gpio] on any platform.
void main() async {
  final gpio = await initialize_RpiGpio();
  await runInput4(gpio);
}
