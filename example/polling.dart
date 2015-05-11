import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;

/// Monitor current values for pins 0 - 7 using polling
main() {
  if (isRaspberryPi) {
    // Initialize the underlying hardware library
    rpi.loadLibrary();
    Gpio.hardware = new rpi.RpiHardware();
  } else {
    // Mock the hardware when testing
    Gpio.hardware = new MockHardware();
  }

  var gpio = Gpio.instance;
  var sensors = [];
  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var sensor = new Sensor(gpio.pin(pinNum, input));
    sensors.add(sensor);
    print(sensor);
  }

  print('=== polling for changes');
  var stopwatch = new Stopwatch()..start();
  int count = 0;
  new Timer.periodic(new Duration(milliseconds: 5), (Timer timer) {
    sensors.forEach((Sensor sensor) {
      if (sensor.hasChanged()) {
        print('${stopwatch.elapsedMilliseconds} => $sensor');
      }
    });
    ++count;
    if (count >= 20) timer.cancel();
  });
}

/// Simulate hardware when testing.
class MockHardware implements GpioHardware {
  List<int> values = [0, 0, 0, 0, 0, 0, 0, 0];

  MockHardware() {
    new Timer(new Duration(milliseconds: 17), () => values[3] = 1);
    new Timer(new Duration(milliseconds: 24), () => values[1] = 1);
    new Timer(new Duration(milliseconds: 33), () => values[2] = 1);
    new Timer(new Duration(milliseconds: 58), () => values[6] = 1);
  }

  /// Simulate all pins return value of 1 (high).
  int digitalRead(int pinNum) => values[pinNum];

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  /// Called to set pin in input mode.
  void pinMode(int pinNum, int mode) {}
}

/// Encapsulate a pin with its most recent value
class Sensor {
  final Pin pin;
  int value;

  Sensor(this.pin) {
    value = pin.value;
  }

  /// Check if the sensor value has changed
  bool hasChanged() {
    var oldValue = value;
    value = pin.value;
    return value != oldValue;
  }

  toString() => '${value} => ${pin.description}';
}
