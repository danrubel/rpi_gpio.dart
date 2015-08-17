import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';

/// Use interrupts to monitor the state change on a given pin
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

  // Subscribe to pin change events
  print('initial value: ${sensorPin.value}');
  var subscription = sensorPin.events.listen((PinEvent event) {
    print('${stopwatch.elapsedMilliseconds} value: ${event.value}');

    // Toggle the LED
    ledPin.value = event.value == 1 ? 0 : 1;
  });

  // Turn on the LED
  ledPin.value = 1;

  // Cancel listening for interrupts after 1 seconds
  new Timer(new Duration(seconds: 1), () {
    subscription.cancel();
  });
}

DateTime get now => new DateTime.now();
