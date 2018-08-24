import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';

/// Simple example to blink an LED.
main() async {
  final gpio = new RpiGpio();
  final led = gpio.output(12);

  for (int count = 0; count < 5; ++count) {
    led.value = true;
    await new Future.delayed(new Duration(seconds: 1));
    led.value = false;
    await new Future.delayed(new Duration(seconds: 1));
  }
}
