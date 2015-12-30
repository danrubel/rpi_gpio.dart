library test.hardware.blink;

import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/wiringpi_gpio.dart';

/// Low level calls to blink an LED
/// connected to Pin 1 (BMC_GPIO 18, Physical Pin 12).
///
/// Typically, users access the GPIO pins via package:rpi_gpio/rpi_gpio.dart
/// as shown in the blink.dart rather than using this lower level API.
main() async {
  // Directly access the hardware API
  var hardware = new WiringPiGPIO();

  hardware.setMode(1, Mode.output);
  for (int count = 0; count < 5; ++count) {
    hardware.setPin(1, true);
    await _delay(1000);
    hardware.setPin(1, false);
    await _delay(1000);
  }
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}
