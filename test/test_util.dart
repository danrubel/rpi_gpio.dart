library test.rpi_gpio.util;

import 'dart:async';

import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/wiringpi_gpio.dart' deferred as wiringpi;
import 'package:test/test.dart';

import 'mock_gpio.dart';
import 'recording_gpio.dart';

/// GPIO API for testing
RpiGPIO gpio;

/// Recording hardware for testing
RecordingGPIO recording;

DateTime get now => new DateTime.now();

/// Assert a value for the given pin
assertValue(Pin pin, bool expectedValue) {
  DateTime end = now.add(new Duration(milliseconds: 250));
  while (now.isBefore(end)) {
    if (pin.value == expectedValue) return;
  }
  fail('Expected $expectedValue on $pin');
}

/// Setup GPIO for testing
Future<RpiGPIO> setupGPIO() async {
  if (recording != null) return recording;

  // Load the Raspberry Pi native method library if running on the RPi
  // otherwise create mock hardware for testing code on other platforms.
  if (isRaspberryPi) {
    await wiringpi.loadLibrary();
    gpio = new wiringpi.WiringPiGPIO();
  } else {
    print('>>> initializing mock hardware');
    gpio = new MockGPIO();
  }

  // Wrap the low level or mock GPIO to record, validate, and display
  // which pins are used and for what purpose.
  recording = new RecordingGPIO(gpio);
  Pin.gpio = recording;
  return recording;
}
