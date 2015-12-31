import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/wiringpi_gpio.dart';

/// Use interrupts to monitor the state change on a given pin
/// This assumes a hardware setup where
/// * pin 1 = an LED (1 = on, 0 = off)
/// * pin 0 = a photo resistor detecting the state of the LED on pin 1
main() async {

  // Initialize the GPIO API
  // See read_with_mocks.dart for testing on non-RaspberryPi platforms
  Pin.gpio = new WiringPiGPIO();

  var stopwatch = new Stopwatch()..start();

  var sensorPin = pin(0, Mode.input);
  var ledPin = pin(1, Mode.output);

  // Subscribe to pin change events
  print('initial value: ${sensorPin.value}');
  var subscription = sensorPin.events().listen((PinEvent event) {
    print('${stopwatch.elapsedMilliseconds} value: ${event.value}');

    // Toggle the LED
    ledPin.value = !event.value;
  });

  // Turn on the LED
  ledPin.value = true;

  // Cancel listening for interrupts after 1/4 second
  new Timer(new Duration(milliseconds: 250), () {
    subscription.cancel();

    // Ensure LED is off
    ledPin.value = false;
  });
}

DateTime get now => new DateTime.now();
