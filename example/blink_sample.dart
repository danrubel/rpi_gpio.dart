library test.hardware.blink;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';

/// Simple example to blink an LED.
/// connected to GPIO 1 (BMC_GPIO 18, Physical Pin 12).
main() async {
  var gpio = new Gpio(new RpiHardware());
  var pin = gpio.pin(1, output);
  for (int count = 0; count < 5; ++count) {
    pin.value = 1;
    await _delay(1000);
    pin.value = 0;
    await _delay(1000);
  }
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}
