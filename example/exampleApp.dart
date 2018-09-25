import 'dart:async';

import 'package:rpi_gpio/gpio.dart';

import 'debouncer.dart';

Future runExample(Gpio gpio, {Duration blink, int debounce}) async {
  blink ??= const Duration(milliseconds: 500);
  debounce ??= 250;

  // Blink the LED 3 times
  final led = gpio.output(12);
  for (int count = 0; count < 3; ++count) {
    led.value = true;
    await new Future.delayed(blink);
    led.value = false;
    await new Future.delayed(blink);
  }

  // Wait for the button to be pressed 3 times
  final button = gpio.input(11);
  bool lastValue = button.value;
  int count = 0;
  final completer = new Completer();
  final subscription = button.values
      .transform(new Debouncer(lastValue, debounce))
      .listen((bool newValue) {
    if (lastValue == true && !newValue) {
      ++count;
      if (count == 3) {
        completer.complete();
      }
    }
    led.value = lastValue = newValue;
  });
  await completer.future;

  // Cleanup before exit
  subscription.cancel();
  gpio.dispose();
}
