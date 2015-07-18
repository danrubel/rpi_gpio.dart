import 'dart:async';
import 'dart:isolate';

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
  var subscriptions = [];
  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var pin = gpio.pin(pinNum, input);
    subscriptions.add(pin.events.listen((PinEvent event) {
      print('${stopwatch.elapsedMilliseconds}, '
          '${MockHardware.elapsedMillisecondsSinceTrigger} : '
          '${event.value} => ${event.pin}');
    }));
    print('${pin.value} => ${pin}');
  }

  print('=== wait for changes');
  new Timer(new Duration(milliseconds: 100), () {
    for (var s in subscriptions) {
      s.cancel();
    }
  });
}

/// Simulate hardware when testing.
class MockHardware implements GpioHardware {
  static var triggerTime = now;

  static get elapsedMillisecondsSinceTrigger =>
      now.difference(triggerTime).inMilliseconds;

  static DateTime get now => new DateTime.now();

  List<int> values = [0, 0, 0, 0, 0, 0, 0, 0];

  SendPort interruptPort;

  MockHardware() {
    new Timer(new Duration(milliseconds: 17), () => _changed(3, 1));
    new Timer(new Duration(milliseconds: 24), () => _changed(1, 1));
    new Timer(new Duration(milliseconds: 32), () => _changed(2, 1));
    new Timer(new Duration(milliseconds: 59), () => _changed(6, 1));
  }

  int digitalRead(int pinNum) => values[pinNum];

  @override
  int enableInterrupt(int pinNum) => -1;

  @override
  void initInterrupts(SendPort port) {
    interruptPort = port;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void pinMode(int pinNum, int mode) {}

  int _changed(int pinNum, int value) {
    values[pinNum] = value;
    triggerTime = now;
    interruptPort.send(pinNum | (value != 0 ? GpioHardware.pinValueMask : 0));
    return value;
  }
}
