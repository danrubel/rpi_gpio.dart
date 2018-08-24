import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';

/// Simple example to turn on an LED when a button is pressed.
main() async {
  final gpio = new RpiGpio();
  final button = gpio.input(11);
  final led = gpio.output(12);

  final subscription = button.values.listen((bool newValue) {
    led.value = newValue;
  });

  await new Future.delayed(new Duration(seconds: 30));

  subscription.cancel();
}
