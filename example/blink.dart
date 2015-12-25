library test.hardware.blink;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';

/// Simple example to blink an LED.
/// connected to Pin 1 (BMC_GPIO 18, Physical Pin 12).
main() async {

  // Initialize the hardware
  // See read_with_mocks.dart for testing on non-RaspberryPi platforms
  Gpio.hardware = new RpiHardware();

  // TODO Remove the need to call this method for initialization
  Gpio.instance;

  var ledPin = pin(1, Mode.output);
  for (int count = 0; count < 5; ++count) {
    ledPin.value = 1;
    await _delay(1000);
    ledPin.value = 0;
    await _delay(1000);
  }
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}
