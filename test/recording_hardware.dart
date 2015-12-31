library test.rpi_gpio.recording;

import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/rpi_gpio.dart';

class NoOpHardware extends RpiGPIO {
  @override int get pins => 0;
  @override String description(int pinNum) => 'Pin $pinNum';
  @override void disableAllInterrupts() {}
  @override bool getPin(int pin) => false;
  @override void initInterrupts(SendPort port) {}
  @override void setMode(int pin, Mode mode) {}
  @override void setPin(int pin, bool value) {}
  @override void setPull(int pinNum, Pull pull) {}
  @override void setPulseWidth(int pinNum, int pulseWidth) {}
  @override void setTrigger(int pin, Trigger trigger) {}
}

/// Records modes used with the GPIO hardware,
/// validates that the operation is appropriate for the current mode,
/// and optionally forwards the requests to the underlying hardware.
/// Usage can be displayed via [printUsage].
class RecordingHardware implements RpiGPIO {
  final RpiGPIO _hardware;
  ReceivePort _hardwarePort;
  SendPort _clientPort;

  /// A sequence of pin mode changes.
  List<_PinState> _states = [];

  /// A sequence of hardware events
  List _events = [];

  RecordingHardware([RpiGPIO hardware])
      : _hardware = hardware != null ? hardware : new NoOpHardware();

  @override
  int get pins => _hardware.pins;

  @override
  String description(int pinNum) => _hardware.description(pinNum);

  @override
  void disableAllInterrupts() {
    if (_clientPort == null) throw 'disableAllInterrupts already called';
    _hardware.disableAllInterrupts();
    _hardwarePort.close();
    _hardwarePort = null;
    _clientPort = null;
  }

  @override
  bool getPin(int pinNum) {
    _assertMode(pinNum, Mode.input);
    return _hardware.getPin(pinNum);
  }

  @override
  void initInterrupts(SendPort port) {
    if (_clientPort != null) throw 'initInterrupts already called';
    _clientPort = port;
    _hardwarePort = new ReceivePort()
      ..listen((message) {
        int pinNum = message & RpiGPIO.pinNumMask;
        int pinValue = (message & RpiGPIO.pinValueMask) != 0 ? 1 : 0;
        _events.add('pin $pinNum value $pinValue');
        _clientPort.send(message);
      });
    _hardware.initInterrupts(_hardwarePort.sendPort);
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
  void setMode(int pinNum, Mode mode) {
    if (mode == Mode.other) throw 'Cannot set any pin to Mode.other';
    if (_mode(pinNum) != mode) _states.add(new _PinState(pinNum, mode));
    _hardware.setMode(pinNum, mode);
  }

  @override
  void setPin(int pinNum, bool value) {
    _assertMode(pinNum, Mode.output);
    _hardware.setPin(pinNum, value);
  }

  @override
  void setPull(int pinNum, Pull pull) {
    _assertMode(pinNum, Mode.input);
    _hardware.setPull(pinNum, pull);
  }

  @override
  void setPulseWidth(int pinNum, int pulseWidth) {
    _assertMode(pinNum, Mode.output);
    _hardware.setPulseWidth(pinNum, pulseWidth);
  }

  @override
  void setTrigger(int pinNum, Trigger trigger) {
    if (_mode(pinNum) != Mode.input) throw 'Must set Mode.input for interrupts';
    _hardware.setTrigger(pinNum, trigger);
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
