import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;

/// Monitor current values for pins 0 - 7 using polling
main() async {

  if (isRaspberryPi) {
    // Initialize the underlying hardware library
    await rpi.loadLibrary();
    Gpio.hardware = new rpi.RpiHardware();
  } else {
    // Mock the hardware when testing
    Gpio.hardware = new MockHardware();
  }
  var stopwatch = new Stopwatch()..start();

  var gpio = Gpio.instance;
  var sensors = [];
  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var sensor = new Sensor(gpio.pin(pinNum, input));
    sensors.add(sensor);
    print(sensor);
  }

  print('=== polling for changes');
  int count = 0;
  new Timer.periodic(new Duration(milliseconds: 5), (Timer timer) {
    sensors.forEach((Sensor sensor) {
      if (sensor.hasChanged()) {
        print('${stopwatch.elapsedMilliseconds}, '
            '${MockHardware.elapsedMillisecondsSinceTrigger} : $sensor');
      }
    });
    ++count;
    if (count >= 20) timer.cancel();
  });
}

/// Simulate hardware when testing.
class MockHardware implements GpioHardware {
  static var triggerTime = now;

  static get elapsedMillisecondsSinceTrigger =>
      now.difference(triggerTime).inMilliseconds;

  static DateTime get now => new DateTime.now();

  List<int> values = [0, 0, 0, 0, 0, 0, 0, 0];

  MockHardware() {
    new Timer(new Duration(milliseconds: 17), () => _changed(3, 1));
    new Timer(new Duration(milliseconds: 24), () => _changed(1, 1));
    new Timer(new Duration(milliseconds: 32), () => _changed(2, 1));
    new Timer(new Duration(milliseconds: 59), () => _changed(6, 1));
  }

  int digitalRead(int pinNum) => values[pinNum];

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void pinMode(int pinNum, int mode) {}

  int _changed(int pinNum, int value) {
    values[pinNum] = value;
    triggerTime = now;
    return value;
  }
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
