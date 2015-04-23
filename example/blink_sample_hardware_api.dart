library test.hardware.blink;

import 'dart:async';

import 'package:rpi_gpio/rpi_hardware.dart';

/// Low level calls to blink an LED
/// connected to GPIO 1 (BMC_GPIO 18, Physical Pin 12).
///
/// Typically, users access the GPIO pins via package:rpi_gpio/rpi_gpio.dart
/// as shown in the blink_sample.dart rather than using this lower level API.
main() async {
  var hardware = new RpiHardware();
  hardware.pinMode(1, 1); // pin 1 output
  for (int count = 0; count < 5; ++count) {
    hardware.digitalWrite(1, 1);
    await _delay(1000);
    hardware.digitalWrite(1, 0);
    await _delay(1000);
  }
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}
