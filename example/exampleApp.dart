import 'dart:async';
import 'dart:io';

import 'package:rpi_gpio/gpio.dart';

import 'debouncer.dart';

const dutyCycleValues = [100, 50, 100, 25, 100, 10, 100];

Future runExample(Gpio gpio, {Duration? blink, int? debounce}) async {
  blink ??= const Duration(milliseconds: 500);
  debounce ??= 250;

  // Blink the LED 3 times for each PWM level
  final led = gpio.output(15);
  final pwmLed = gpio.pwm(12);
  for (var dutyCycle in dutyCycleValues) {
    pwmLed.dutyCycle = dutyCycle;
    print('PWM Led brightness $dutyCycle %');
    for (int count = 0; count < 3; ++count) {
      led.value = true;
      // sleep blocks this thread, but not the RpiGpio isolate
      // so polling and pulse width modulation continue to operate
      sleep(blink);
      led.value = false;
      sleep(blink);
    }
  }
  pwmLed.dutyCycle = 0; // off

  // Get the current button state
  final button = gpio.input(11, Pull.up);
  print('Button state: ${await button.value}');

  // Wait for the button to be pressed 3 times
  bool lastValue = true;
  int count = 0;
  final completer = Completer();
  final subscription = button.values
      .transform(Debouncer(lastValue, debounce))
      .listen((bool newValue) {
    print('New button state: $newValue');
    if (lastValue == false && newValue) {
      ++count;
      if (count == 3) {
        completer.complete();
      }
    }
    led.value = lastValue = newValue;
  });
  print('Waiting for 3 button presses...');
  await completer.future.timeout(const Duration(seconds: 15), onTimeout: () {
    print('Stopped waiting for button presses');
  });
  led.value = false;

  // Cleanup before exit
  await subscription.cancel();
  await gpio.dispose();
  print('Complete');
}
