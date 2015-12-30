library test.rpi_gpio.mock;

import 'dart:isolate';

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
  bool getPin(int pinNum) {
    if (0 <= pinNum && pinNum <= 4) return values[pinNum] != 0;
    throw 'digitalRead not mocked for pin $pinNum';
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

  // ========== WiringPi Specific API ======================

  @override
  void disableAllInterrupts() {
    interruptEventPort = null;
    interruptMap = <Trigger>[null, null, null, null, null];
  }

  @override
  int gpioNum(int pinNum) =>
      [17, 18, 27, 22, 23, 24, 25, 4, 2, 3, 8, 7, 10, 9, 11, 14, 15][pinNum];

  @override
  void initInterrupts(SendPort port) {
    if (interruptEventPort != null) throw 'interrupts already initialized';
    interruptEventPort = port;
  }

  @override
  int physPinToGpio(int pinNum) => [
        -1, //                                      0
        -1, -1, 2, -1, 3, -1, 4, 14, -1, 15, //     1 - 10
        17, 18, 27, -1, 22, 23, -1, 24, 10, -1, // 11 - 20
        9, 25, 11, 8, -1, 7, 0, 1, 5, -1, //       21 - 30
        6, 12, 13, -1, 19, 16, 26, 20, -1, 21, //  31 - 40
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 41 - 50
        28, 29, 30, 31, -1, -1, -1, -1, -1, -1, // 51 - 60
        -1, -1, -1, -1, -1, -1, -1, -1, //         60+
      ][pinNum];

  @override
  void pullUpDnControl(int pinNum, int pud) {
    if (pinNum == 4) {
      if (pud == Pull.up.index) {
        setPin(4, true);
      } else if (pud == Pull.down.index) {
        setPin(4, false);
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
    if (pinNum == 1)
      setPin(1, pulseWidth > 500);
    else
      throw 'pwm not mocked for pin $pinNum';
  }

  void reset() {
    values = <int>[0, 0, 0, 0, null];
    stateChanges = new List<StateChange>();
    disableAllInterrupts();
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
