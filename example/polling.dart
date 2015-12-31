import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/wiringpi_gpio.dart';

/// Use polling to monitor the state change on a given pin
/// This assumes a hardware setup where
/// * pin 1 = an LED (1 = on, 0 = off)
/// * pin 0 = a photo resistor detecting the state of the LED on pin 1
main() async {

  // Initialize the hardware
  // See read_with_mocks.dart for testing on non-RaspberryPi platforms
  Pin.hardware = new WiringPiGPIO();

  var stopwatch = new Stopwatch()..start();

  var sensorPin = pin(0, Mode.input);
  var ledPin = pin(1, Mode.output);

  // Poll for changes to pin values
  var previousValue = sensorPin.value;
  print('initial value: $previousValue');
  var timer = new Timer.periodic(new Duration(milliseconds: 5), (_) {
    var currentValue = sensorPin.value;
    if (previousValue != currentValue) {
      previousValue = currentValue;
      print('${stopwatch.elapsedMilliseconds} value: ${currentValue}');
    }

    // Toggle the LED
    ledPin.value = !currentValue;
  });

  // Turn on the LED
  ledPin.value = true;

  // Cancel polling after 1/4 second
  new Timer(new Duration(milliseconds: 250), () {
    timer.cancel();
  });
}
