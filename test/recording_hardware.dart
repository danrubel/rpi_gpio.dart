library test.rpi_gpio.recording;

import 'package:rpi_gpio/rpi_gpio.dart';

/// Records modes used with the GPIO hardware,
/// validates that the operation is appropriate for the current mode,
/// and optionally forwards the requests to the underlying hardware.
/// Usage can be displayed via [printUsage].
class RecordingHardware implements GpioHardware {
  final GpioHardware _hardware;

  /// A sequence of pin mode changes.
  List<_PinState> _states = [];

  RecordingHardware([GpioHardware hardware])
      : _hardware = hardware != null ? hardware : new NoOpHardware();

  @override
  int digitalRead(int pinNum) {
    _assertMode(pinNum, input);
    return _hardware != null ? _hardware.digitalRead(pinNum) : 0;
  }

  @override
  void digitalWrite(int pinNum, int value) {
    _assertMode(pinNum, output);
    _hardware.digitalWrite(pinNum, value);
  }

  @override
  void pinMode(int pinNum, int modeIndex) {
    var mode = PinMode.values[modeIndex];
    if (_mode(pinNum) != mode) _states.add(new _PinState(pinNum, mode));
    _hardware.pinMode(pinNum, modeIndex);
  }

  void printUsage(Gpio gpio) {
    var map = <int, Set<PinMode>>{};
    print('');
    print('Rev 2 GPIO Pin mode changes');
    for (_PinState state in _states) {
      var pinNum = state.pinNum;
      var pinMode = state.mode;
      print('${gpio.pin(pinNum).description} ${pinMode}');
      var modes = map[pinNum];
      if (modes == null) {
        modes = new Set<PinMode>();
        map[pinNum] = modes;
      }
      modes.add(pinMode);
    }
    print('');
    print('Rev 2 GPIO Pins used');
    var separator = ' ';
    for (int pinNum in map.keys.toList()..sort()) {
      var sb = new StringBuffer();
      sb.write(gpio.pin(pinNum).description);
      for (PinMode mode in map[pinNum]) {
        sb.write(separator);
        sb.write(mode);
        separator = ', ';
      }
      print(sb);
    }
    print('');
  }

  @override
  void pullUpDnControl(int pinNum, int pud) {
    _assertMode(pinNum, input);
    _hardware.pullUpDnControl(pinNum, pud);
  }

  @override
  void pwmWrite(int pinNum, int pulseWidth) {
    _assertMode(pinNum, pulsed);
    _hardware.pwmWrite(pinNum, pulseWidth);
  }

  /// Assert that the given pin has the expected mode
  void _assertMode(int pinNum, PinMode expectedMode) {
    var currentMode = _mode(pinNum);
    if (currentMode != expectedMode) {
      throw 'Expected pin $pinNum mode $expectedMode, but was $currentMode';
    }
  }

  /// Return the current mode for the given pin or `null` if not set.
  PinMode _mode(int pinNum) {
    for (int index = _states.length - 1; index >= 0; --index) {
      var state = _states[index];
      if (state.pinNum == pinNum) return state.mode;
    }
    return null;
  }
}

class NoOpHardware extends GpioHardware {
  @override int digitalRead(int pin) => 0;
  @override void digitalWrite(int pin, int value) {}
  @override void pinMode(int pin, int mode) {}
  @override void pullUpDnControl(int pin, int pud) {}
  @override void pwmWrite(int pin, int pulseWidth) {}
}

/// Internal class for tracking the state of a pin
class _PinState {
  final int pinNum;
  final PinMode mode;

  _PinState(this.pinNum, this.mode);
}
