library test.mock.hardware;

import 'package:rpi_gpio/rpi_gpio.dart';

/// Mock hardware used by rpi_gpio_test.dart for testing the [Gpio] library
/// on platforms other than the Raspberry Pi. This simulates
/// pin 4 unconnected but with an internal pull up/down resistor setting
/// pin 3 = an LED (1 = on, 0 = off)
/// pin 2 = a photo resistor detecting the state of the LED on pin 3
/// pin 1 = an LED (1 = on, 0 = off)
/// pin 0 = a photo resistor detecting the state of the LED on pin 1
class MockHardware implements GpioHardware {
  List<int> values;
  List<StateChange> stateChanges;

  MockHardware() {
    reset();
  }

  DateTime get now => new DateTime.now();

  @override
  int digitalRead(int pinNum) {
    if (0 <= pinNum && pinNum <= 4) return values[pinNum];
    throw 'digitalRead not mocked for pin $pinNum';
  }

  @override
  void digitalWrite(int pinNum, int value) {
    var digitalValue = value != 0 ? 1 : 0;
    stateChanges.add(new StateChange(now, pinNum, digitalValue));
    switch (pinNum) {
      case 1:
        values[1] = digitalValue;
        values[0] = digitalValue;
        break;
      case 3:
        values[3] = digitalValue;
        values[2] = digitalValue;
        break;
      case 4:
        values[4] = digitalValue;
        break;
      default:
        throw 'write not mocked for pin $pinNum';
    }
  }

  @override
  void pinMode(int pinNum, int modeIndex) {
    // validated by RecordingHardware
  }

  @override
  void pullUpDnControl(int pinNum, int pud) {
    if (pinNum == 4) {
      if (pud == pullUp.index) {
        digitalWrite(4, 1);
      } else if (pud == pullDown.index) {
        digitalWrite(4, 0);
      } else {
        values[4] = null;
      }
    } else if (pinNum != 0 && pinNum != 2) {
      throw 'pull up/down not mocked for pin $pinNum';
    }
  }

  @override
  void pwmWrite(int pinNum, int pulseWidth) {
    // Simulate hardware pwm on pin 1.
    if (pinNum == 1) digitalWrite(1, pulseWidth > 500 ? 1 : 0);
    else throw 'pwm not mocked for pin $pinNum';
  }

  void reset() {
    values = <int>[0, 0, 0, 0, null];
    stateChanges = new List<StateChange>();
  }
}

class StateChange {
  final DateTime time;
  final int pinNum;
  final int value;

  StateChange(this.time, this.pinNum, this.value);
}
