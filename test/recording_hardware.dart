library test.rpi_gpio.recording;

import 'dart:isolate';

import 'package:rpi_gpio/rpi_gpio.dart';

class NoOpHardware extends GpioHardware {
  @override int digitalRead(int pinNum) => 0;
  @override void digitalWrite(int pinNum, int value) {}
  @override void disableAllInterrupts() {}
  @override int enableInterrupt(int pinNum) => -1;
  @override int gpioNum(int pinNum) => -1;
  @override void initInterrupts(SendPort port) {}
  @override  int physPinToGpio(int pinNum) => -1;
  @override void pinMode(int pinNum, int mode) {}
  @override void pullUpDnControl(int pinNum, int pud) {}
  @override void pwmWrite(int pinNum, int pulseWidth) {}
}

/// Records modes used with the GPIO hardware,
/// validates that the operation is appropriate for the current mode,
/// and optionally forwards the requests to the underlying hardware.
/// Usage can be displayed via [printUsage].
class RecordingHardware implements GpioHardware {
  final GpioHardware _hardware;
  ReceivePort _hardwarePort;
  SendPort _clientPort;

  /// A sequence of pin mode changes.
  List<_PinState> _states = [];

  /// A sequence of hardware events
  List _events = [];

  RecordingHardware([GpioHardware hardware])
      : _hardware = hardware != null ? hardware : new NoOpHardware();

  @override
  int digitalRead(int pinNum) {
    _assertMode(pinNum, Mode.input);
    return _hardware != null ? _hardware.digitalRead(pinNum) : 0;
  }

  @override
  void digitalWrite(int pinNum, int value) {
    _assertMode(pinNum, Mode.output);
    _hardware.digitalWrite(pinNum, value);
  }

  @override
  void disableAllInterrupts() {
    _hardware.disableAllInterrupts();
    _hardwarePort.close();
  }

  @override
  int enableInterrupt(int pinNum) => _hardware.enableInterrupt(pinNum);

  @override
  int gpioNum(int pinNum) => _hardware.gpioNum(pinNum);

  @override
  void initInterrupts(SendPort port) {
    _clientPort = port;
    _hardwarePort = new ReceivePort()
      ..listen((message) {
        int pinNum = message & GpioHardware.pinNumMask;
        int pinValue = (message & GpioHardware.pinValueMask) != 0 ? 1 : 0;
        _events.add('pin $pinNum value $pinValue');
        _clientPort.send(message);
      });
    _hardware.initInterrupts(_hardwarePort.sendPort);
  }

  @override
  int physPinToGpio(int pinNum) => _hardware.physPinToGpio(pinNum);

  @override
  void pinMode(int pinNum, int modeIndex) {
    var mode = Mode.values[modeIndex];
    if (_mode(pinNum) != mode) _states.add(new _PinState(pinNum, mode));
    _hardware.pinMode(pinNum, modeIndex);
  }

  void printUsage() {
    var map = <int, Set<Mode>>{};
    print('');
    print('Rev 2 GPIO hardware events');
    for (var message in _events) {
      print(' $message');
    }
    print('');
    print('Rev 2 GPIO Pin mode changes');
    for (_PinState state in _states) {
      var pinNum = state.pinNum;
      var pinMode = state.mode;
      print('${pin(pinNum).description}    ${pinMode}');
      var modes = map[pinNum];
      if (modes == null) {
        modes = new Set<Mode>();
        map[pinNum] = modes;
      }
      modes.add(pinMode);
    }
    print('');
    print('Rev 2 GPIO Pins used');
    for (int pinNum in map.keys.toList()..sort()) {
      var separator = '    ';
      var sb = new StringBuffer();
      sb.write(pin(pinNum).description);
      for (Mode mode in map[pinNum]) {
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
    _assertMode(pinNum, Mode.input);
    _hardware.pullUpDnControl(pinNum, pud);
  }

  @override
  void pwmWrite(int pinNum, int pulseWidth) {
    _assertMode(pinNum, Mode.pulsed);
    _hardware.pwmWrite(pinNum, pulseWidth);
  }

  /// Assert that the given pin has the expected mode
  void _assertMode(int pinNum, Mode expectedMode) {
    var currentMode = _mode(pinNum);
    if (currentMode != expectedMode) {
      throw 'Expected pin $pinNum mode $expectedMode, but was $currentMode';
    }
  }

  /// Return the current mode for the given pin or `null` if not set.
  Mode _mode(int pinNum) {
    for (int index = _states.length - 1; index >= 0; --index) {
      var state = _states[index];
      if (state.pinNum == pinNum) return state.mode;
    }
    return null;
  }
}

/// Internal class for tracking the state of a pin
class _PinState {
  final int pinNum;
  final Mode mode;

  _PinState(this.pinNum, this.mode);
}
