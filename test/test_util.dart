library test.rpi_gpio.util;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;
import 'package:test/test.dart';

import 'mock_hardware.dart';
import 'recording_hardware.dart';

/// Hardware for testing
GpioHardware hardware;

/// Recording hardware for testing
RecordingHardware recording;

DateTime get now => new DateTime.now();

/// Assert a value for the given pin
assertValue(Pin pin, int expectedValue) {
  DateTime end = now.add(new Duration(milliseconds: 250));
  while (now.isBefore(end)) {
    if (pin.value == expectedValue) return;
  }
  fail('Expected $expectedValue on $pin');
}

/// Setup hardware for testing
Future<GpioHardware> setupHardware() async {
  if (recording != null) return recording;

  // Load the Raspberry Pi native method library if running on the RPi
  // otherwise create mock hardware for testing code on other platforms.
  if (isRaspberryPi) {
    await rpi.loadLibrary();
    hardware = new rpi.RpiHardware();
  } else {
    print('>>> initializing mock hardware');
    hardware = new MockHardware();
  }

  // Wrap the low level or mock hardware to record, validate, and display
  // which pins are used and for what purpose.
  recording = new RecordingHardware(hardware);
  Gpio.hardware = recording;
  return recording;
}
