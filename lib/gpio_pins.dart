library gpio_pins;

import 'dart:async';
import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';

/// An internal cache of currently defined pins indexed by wiringPi pin #
List<Pin> _pins = <Pin>[];

/// Return the [Pin] representing the specified GPIO pin
/// where [pinNum] is the wiringPi pin number.
Pin pin(int pinNum, [Mode mode]) {
  while (_pins.length <= pinNum) _pins.add(null);
  Pin pin = _pins[pinNum];
  if (pin == null) {
    if (mode == null)
      throw new GPIOException('Must specify initial pin mode', pin.pinNum);
    pin = new Pin._(pinNum, mode);
    _pins[pinNum] = pin;
  } else if (mode != null) {
    pin.mode = mode;
  }
  return pin;
}

/// [Gpio] provides access to the General Purpose I/O (GPIO) pins.
/// Pulse width modulation can be simulated on pins other than pin 1
/// by substituting different [RpiGPIO] implements via [hardware] method.
class Gpio {
  /// The single [Gpio] instance
  /// or `null` if [instance] has not yet been called.
  static Gpio _instance;

  /// The API used by this class to access the underlying hardware
  static RpiGPIO _hardware;

  /// Set the underlying hardware API used by the [Gpio] [instance].
  /// This may be only called once.
  static void set hardware(RpiGPIO hardware) {
    if (_hardware != null)
      throw new GPIOException('Gpio.hardware has already been set');
    _hardware = hardware;
  }

  /// The instance for accessing Raspberry Pi GPIO functionality.
  static Gpio get instance {
    /// Return the single [Gpio] instance.
    if (_instance == null) _instance = new Gpio._();
    return _instance;
  }

  /// The port on which interrupt events are received
  /// or `null` if not yet initialized.
  ReceivePort _interruptEventPort;

  Gpio._() {
    if (_hardware == null) throw new GPIOException('Gpio.hardware must be set');
  }

  /// If all pin event streams have been canceled/closed
  /// then call the underlying disableAllInterrupts method
  /// to stop forwarding interrupts.
  void _checkDisableAllInterrupts() {
    for (int pinNum = 0; pinNum < _pins.length; ++pinNum) {
      var pin = _pins[pinNum];
      if (pin != null && pin._events != null) {
        return;
      }
    }
    _hardware.disableAllInterrupts();
    _interruptEventPort.close();
    _interruptEventPort = null;
  }

  /// Called when a pin's state has changed.
  void _handleInterrupt(message) {
    if (message is int) {
      int pinNum = message & RpiGPIO.pinNumMask;
      if (0 <= pinNum && pinNum < _pins.length) {
        bool value = (message & RpiGPIO.pinValueMask) != 0;
        _pins[pinNum]._handleInterrupt(value);
      }
    }
  }

  /// Initialize interrupt handling if not already initialized
  void _initInterrupts() {
    if (_interruptEventPort == null) {
      _interruptEventPort = new ReceivePort()..listen(_handleInterrupt);
      _hardware.initInterrupts(_interruptEventPort.sendPort);
    }
  }
}

/// [Pin] represents a single GPIO pin for Raspberry Pi
/// based upon the wiringPi library. See the top level [pin] function.
class Pin {
  /// The wiringPi pin number.
  final int pinNum;

  /// The pin mode: [Mode.input], [Mode.output], [Mode.other]
  Mode _mode;

  /// The state of the pin's pull up/down resistor
  Pull _pull = Pull.off;

  /// The event stream controller or null if none.
  StreamController<PinEvent> _events;

  /// The pin's value at the time of the last interrupt.
  /// This is used to filter duplicate interrupts.
  bool _lastInterruptValue;

  Pin._(this.pinNum, Mode mode) {
    this.mode = mode;
  }

  /// Return a human readable description of this pin
  String get description {
    try {
      return Gpio._hardware.description(pinNum);
    } catch (_) {
      return 'Pin $pinNum';
    }
  }

  /// Return the mode ([Mode.input], [Mode.output], [Mode.other]) for this pin.
  Mode get mode => _mode;

  /// Set the mode ([Mode.input] or [Mode.output]) for this pin.
  void set mode(Mode mode) {
    if (_mode == Mode.input && mode != Mode.input && _events != null)
      throw new GPIOException(
          'Must cancel event stream subscription before changing mode', pinNum);
    if (mode == Mode.other)
      throw new GPIOException('Cannot set mode other', pinNum);
    _mode = mode;
    Gpio._hardware.setMode(pinNum, mode);
  }

  /// Return the state of the pin's pull up/down resistor
  Pull get pull => _pull;

  /// Set the state of the pin's pull up/down resistor.
  /// The internal pull up/down resistors have a value
  /// of approximately 50KΩ on the Raspberry Pi
  void set pull(Pull pull) {
    if (mode != Mode.input) throw new GPIOException.invalidCall(pinNum, 'pull');
    _pull = pull != null ? pull : Pull.off;
    Gpio._hardware.setPull(pinNum, _pull);
  }

  /// Set the pulse width (0 - 1024) for the given pin.
  /// The Raspberry Pi has one on-board PWM pin, pin 1 (BMC_GPIO 18, Phys 12).
  /// PWM on all other pins is not directly supported.
  void set pulseWidth(int pulseWidth) {
    if (mode != Mode.output)
      throw new GPIOException.invalidCall(pinNum, 'pulseWidth');
    if (pinNum != 1)
      throw new GPIOException('pulseWidth only supported on pin 1');
    Gpio._hardware.setPulseWidth(pinNum, pulseWidth);
  }

  /// Return the digital value (false = 0 = low, true = 1 = high) for this pin.
  bool get value {
    if (mode != Mode.input)
      throw new GPIOException.invalidCall(pinNum, 'value');
    return Gpio._hardware.getPin(pinNum);
  }

  /// Set the digital value (false = 0 = low, true = 1 = high) for this pin.
  void set value(bool value) {
    if (mode != Mode.output)
      throw new GPIOException.invalidCall(pinNum, 'value=');
    Gpio._hardware.setPin(pinNum, value);
  }

  /// Return a stream of pin events indicating state changes
  /// where [trigger] indicates which events are desired.
  /// If [trigger] is not specified, then both [Trigger.rising]
  /// and [Trigger.falling] events will be streamed.
  /// If [trigger] is [Trigger.none] or `null` then `null` is returned.
  /// An exception is thrown if [events] is called a second time
  /// without the stream subscription from the first call being canceled.
  Stream<PinEvent> events([Trigger trigger = Trigger.both]) {
    if (_events != null) {
      throw new GPIOException(
          'must cancel first subscription before calling events again', pinNum);
    }
    if (trigger == Trigger.none || trigger == null) return null;
    _events = new StreamController(onListen: () {
      if (_mode != Mode.input) {
        var e = new GPIOException.invalidCall(pinNum, 'events.listen');
        _events.addError(e);
        return;
      }
      Gpio._instance._initInterrupts();
      Gpio._hardware.setTrigger(pinNum, trigger);
      _lastInterruptValue = value;
    }, onCancel: () {
      _events.close();
      _events = null;
      Gpio._hardware.setTrigger(pinNum, Trigger.none);
      Gpio._instance._checkDisableAllInterrupts();
    });
    return _events.stream;
  }

  @override
  String toString() => '$description $mode';

  /// Called when this pin's state has changed.
  /// Forward the event to listeners after filtering duplicate interrupts.
  void _handleInterrupt(bool newValue) {
    if (_events != null && _lastInterruptValue != newValue) {
      _lastInterruptValue = newValue;
      _events.add(new PinEvent(this, newValue));
    }
  }
}

/// An event indicating that a pin has changed state.
class PinEvent {
  /// The pin that changed state.
  final Pin pin;

  /// The new value for the pin.
  final bool value;

  PinEvent(this.pin, this.value);

  @override
  toString() => '$pin value: $value';
}
