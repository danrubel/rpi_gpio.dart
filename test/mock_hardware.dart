library test.rpi_gpio.mock;

import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';

import 'test_util.dart';

/// Mock hardware used for testing the [Gpio] library
/// on platforms other than the Raspberry Pi. This simulates
/// pin 4 unconnected but with an internal pull up/down resistor setting
/// pin 3 = an LED (1 = on, 0 = off)
/// pin 2 = a photo resistor detecting the state of the LED on pin 3
/// pin 1 = an LED (1 = on, 0 = off)
/// pin 0 = a photo resistor detecting the state of the LED on pin 1
class MockHardware implements RpiGPIO {
  List<int> values;
  List<StateChange> stateChanges;
  SendPort interruptEventPort;
  List<Trigger> interruptMap;

  MockHardware() {
    reset();
  }

  @override
  int get pins => 20;

  @override
  String description(int pinNum) {
    // Simulate sparse mock where this is not implemented
    throw new NoSuchMethodError(this, new Symbol('description'), [pinNum], {});
  }

  @override
  void disableAllInterrupts() {
    interruptEventPort = null;
    interruptMap = <Trigger>[null, null, null, null, null];
  }

  @override
  bool getPin(int pinNum) {
    if (0 <= pinNum && pinNum <= 4) return values[pinNum] != 0;
    throw 'digitalRead not mocked for pin $pinNum';
  }

  @override
  void initInterrupts(SendPort port) {
    if (interruptEventPort != null) throw 'interrupts already initialized';
    interruptEventPort = port;
  }

  void reset() {
    values = <int>[0, 0, 0, 0, null];
    stateChanges = new List<StateChange>();
    disableAllInterrupts();
  }

  @override
  void setPin(int pinNum, bool boolValue) {
    var digitalValue = boolValue ? 1 : 0;
    _write(int pinNum) {
      if (values[pinNum] != digitalValue) {
        values[pinNum] = digitalValue;
        Trigger trigger = interruptMap[pinNum];
        if (digitalValue == 1) {
          // rising
          if (trigger == Trigger.rising || trigger == Trigger.both) {
            interruptEventPort
                .send(pinNum | (digitalValue != 0 ? RpiGPIO.pinValueMask : 0));
          }
        } else {
          // falling
          if (trigger == Trigger.falling || trigger == Trigger.both) {
            interruptEventPort
                .send(pinNum | (digitalValue != 0 ? RpiGPIO.pinValueMask : 0));
          }
        }
      }
    }
    stateChanges.add(new StateChange(now, pinNum, digitalValue));
    switch (pinNum) {
      case 1:
        _write(1);
        _write(0);
        break;
      case 3:
        _write(3);
        _write(2);
        break;
      case 4:
        _write(4);
        break;
      default:
        throw 'write not mocked for pin $pinNum';
    }
  }

  @override
  void setMode(int pin, Mode mode) {
    // validated by RecordingHardware
  }

  @override
  void setPull(int pinNum, Pull pull) {
    if (pinNum == 4) {
      if (pull == Pull.up) {
        setPin(4, true);
      } else if (pull == Pull.down) {
        setPin(4, false);
      } else {
        values[4] = null;
      }
    } else if (pinNum != 0 && pinNum != 2) {
      throw 'pull up/down not mocked for pin $pinNum';
    }
  }

  @override
  void setPulseWidth(int pinNum, int pulseWidth) {
    // Simulate hardware pwm on pin 1.
    if (pinNum == 1)
      setPin(1, pulseWidth > 500);
    else
      throw 'pwm not mocked for pin $pinNum';
  }

  @override
  void setTrigger(int pinNum, Trigger trigger) {
    if (interruptEventPort == null) throw 'must call initInterrupts';
    interruptMap[pinNum] = trigger;
  }
}

class StateChange {
  final DateTime time;
  final int pinNum;
  final int value;

  StateChange(this.time, this.pinNum, this.value);
}
