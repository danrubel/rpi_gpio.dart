import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';

/// Use polling to monitor the state change on a given pin
/// This assumes a hardware setup where
/// * pin 1 = an LED (1 = on, 0 = off)
/// * pin 0 = a photo resistor detecting the state of the LED on pin 1
main() async {

  // Initialize the hardware
  // See read_with_mocks.dart for testing on non-RaspberryPi platforms
  Gpio.hardware = new RpiHardware();

  var stopwatch = new Stopwatch()..start();
  var gpio = Gpio.instance;

  var sensorPin = gpio.pin(0, input);
  var ledPin = gpio.pin(1, output);

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
    ledPin.value = currentValue == 1 ? 0 : 1;
  });

  // Turn on the LED
  ledPin.value = 1;

  // Cancel polling after 1 seconds
  new Timer(new Duration(seconds: 1), () {
    timer.cancel();
  });
}
