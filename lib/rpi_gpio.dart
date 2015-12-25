library rpi_gpio;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:rpi_gpio/rpi_pwm.dart';

const PinMode input = PinMode.input;
const PinMode output = PinMode.output;
const PinPull pullDown = PinPull.down;
const PinPull pullOff = PinPull.off;
const PinPull pullUp = PinPull.up;
const PinMode pulsed = PinMode.pulsed;

/// Indexed by pin number, these strings are used to build
/// human readable description of known Raspberry Pi rev 2 GPIO pins.
/// See http://wiringpi.com/pins/special-pin-functions/
const List<String> _descriptionSuffix = const [
  'Phys 11)',
  'Phys 12, PMW)',
  'Phys 13)',
  'Phys 15)',
  'Phys 16)',
  'Phys 18)',
  'Phys 22)',
  'Phys 7,  Clock)',
  'Phys 3,  I2C SDA0/1)',
  'Phys 5,  I2C SCL0/1)',
  'Phys 24, SPI CE0)',
  'Phys 26, SPI CE1)',
  'Phys 19, SPI MOSI)',
  'Phys 21, SPI MISO)',
  'Phys 23, SPI SCLK)',
  'Phys 8,  UART TxD, Console)',
  'Phys 10, UART RxD, Console)',
  'Phys P5-3)',
  'Phys P5-4)',
  'Phys P5-5)',
  'Phys P5-6)',
];

/// An internal cache of currently defined pins indexed by wiringPi pin #
List<Pin> _pins = <Pin>[];

/// Return [true] if this is running on a Raspberry Pi.
bool get isRaspberryPi {
  if (!Platform.isLinux) return false;
  try {
    if (new File('/etc/os-release').readAsLinesSync().contains('ID=raspbian')) {
      return true;
    }
  } on FileSystemException catch (_) {
    // fall through
  }
  return raspberryPiMarkerFile.existsSync();
}

/// Return a marker file used to determine if the code is executing on the RPi.
File get raspberryPiMarkerFile =>
    //TODO need a better test for Raspberry Pi
    new File('/home/pi/.raspberrypi');

/// Return the [Pin] representing the specified GPIO pin
/// where [pinNum] is the wiringPi pin number.
Pin pin(int pinNum, [PinMode mode]) {
  while (_pins.length <= pinNum) _pins.add(null);
  Pin pin = _pins[pinNum];
  if (pin == null) {
    if (mode == null) throw new GpioException._missingMode(pin);
    pin = new Pin._(pinNum, mode);
    _pins[pinNum] = pin;
  } else if (mode != null) {
    pin.mode = mode;
  }
  return pin;
}

/// [Gpio] provides access to the General Purpose I/O (GPIO) pins.
/// Pulse width modulation can be simulated on pins other than pin 1
/// by substituting different [GpioHardware] implements via [hardware] method.
class Gpio {
  /// The single [Gpio] instance
  /// or `null` if [instance] has not yet been called.
  static Gpio _instance;

  /// The API used by this class to access the underlying hardware
  static GpioHardware _hardware;

  /// Set the underlying hardware API used by the [Gpio] [instance].
  /// This may be only called once.
  static void set hardware(GpioHardware hardware) {
    if (_hardware != null) throw new GpioException._hardwareAlreadySet();
    _hardware = hardware;
  }

  /// The instance for accessing Raspberry Pi GPIO functionality.
  static Gpio get instance {
    /// Return the single [Gpio] instance.
    if (_instance == null) _instance = new Gpio._();
    return _instance;
  }

  /// For emulating pulse width modulation on pins other than pin 1.
  SoftwarePWM _softPwm;

  /// The port on which interrupt events are received
  /// or `null` if not yet initialized.
  ReceivePort _interruptEventPort;

  Gpio._() {
    if (_hardware == null) throw new GpioException._setHardware();
    _softPwm = new SoftwarePWM(_hardware);
  }

  /// Return the [Pin] representing the specified GPIO pin
  /// where [pinNum] is the wiringPi pin number.
  @deprecated
  Pin pin(int pinNum, [PinMode mode]) {
    while (_pins.length <= pinNum) _pins.add(null);
    Pin pin = _pins[pinNum];
    if (pin == null) {
      if (mode == null) throw new GpioException._missingMode(pin);
      pin = new Pin._(pinNum, mode);
      _pins[pinNum] = pin;
    } else if (mode != null) {
      pin.mode = mode;
    }
    return pin;
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
      int pinNum = message & GpioHardware.pinNumMask;
      if (0 <= pinNum && pinNum < _pins.length) {
        int value = (message & GpioHardware.pinValueMask) != 0 ? 1 : 0;
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

class GpioException {
  final Pin pin;
  final String message;

  GpioException._hardwareAlreadySet()
      : pin = null,
        message = 'Gpio.hardware has already been set';

  GpioException._missingMode(this.pin)
      : message = 'Must specify initial pin mode';

  GpioException._mustCancelEventSubscription(this.pin)
      : message = 'Must cancel event stream subscription before changing mode';

  GpioException._selector(this.pin, String selector)
      : message = 'Invalid call: $selector for mode';

  GpioException._setHardware()
      : pin = null,
        message = 'Gpio.hardware must be set';

  @override
  String toString() => '$message pin: $pin';
}

/// API used by [Gpio] for accessing the underlying hardware.
abstract class GpioHardware {
  static final pinNumMask = 0x7F;
  static final pinValueMask = 0x80;

  /// Return the value for the given pin.
  /// 0 = low or ground, 1 = high or positive.
  /// The [pinMode] should be set to [input] before calling this method.
  int digitalRead(int pinNum);

  /// Set the current output voltage for the given pin.
  /// 0 = low or ground, 1 = high or positive.
  /// The [pinMode] should be set to [output] before calling this method.
  void digitalWrite(int pinNum, int value);

  /// Disable the background interrupt listener.
  void disableAllInterrupts();

  /// Enable interrupts for the given pin.
  /// Throws an exception if [initInterrupts] has not been called
  /// or if there cannot be any more active interrupts.
  /// The [pinMode] should be set to [input] before calling this method.
  /// TODO provide the ability to disable interrupts for a given pin.
  int enableInterrupt(int pinNum);

  /// Return the GPIO number for the given WiringPi pin number.
  int gpioNum(int pinNum);

  /// Initialize the background interrupt listener.
  /// Once called, interrupt events will be sent to [port].
  /// Each message is an int indicating the pin on which the interrupt occurred
  /// and the value of that pin at the time of the interrupt:
  ///
  ///     int message = pinNum | (pinValue != 0 ? GpioHardware.pinValueMask : 0);
  ///
  ///     int pinNum = message & GpioHardware.pinNumMask;
  ///     int pinValue = (message & GpioHardware.pinValueMask) != 0 ? 1 : 0;
  ///
  /// Throws an exception if interrupts have already been initialized.
  void initInterrupts(SendPort port);

  /// Set the given pin to the specified mode,
  /// which can be any of [PinMode] (e.g. [PinMode.input.index]).
  void pinMode(int pinNum, int mode);

  /// Set the internal pull up/down resistor attached to the given pin,
  /// which can be any of [PinPull] (e.g. [PinPull.up.index]).
  /// The [pinMode] should be set to [input] before calling this method.
  void pullUpDnControl(int pinNum, int pud);

  /// Set the pulse width for the given pin.
  /// The pulse width is a number between 0 and 1024 representing the amount
  /// of time out of 1024 that the pin outputs a high value rather than ground.
  /// The [pinMode] should be set to [pulsed] before calling this method.
  void pwmWrite(int pinNum, int pulseWidth);
}

/// [Pin] represents a single GPIO pin for Raspberry Pi
/// based upon the wiringPi library. See the top level [pin] function.
class Pin {
  /// The wiringPi pin number.
  final int pinNum;

  /// The pin mode: [input], [output], [pulsed]
  PinMode _mode;

  /// The state of the pin's pull up/down resistor
  PinPull _pull = pullOff;

  /// The event stream controller or null if none.
  StreamController<PinEvent> _events;

  /// The pin's value at the time of the last interrupt.
  /// This is used to filter duplicate interrupts.
  int _lastInterruptValue;

  Pin._(this.pinNum, PinMode mode) {
    this.mode = mode;
  }

  /// Return a human readable description of this pin
  String get description {
    return pinNum >= 0 && pinNum <= _descriptionSuffix.length
        ? 'Pin $pinNum (BMC_GPIO $gpioNum, ${_descriptionSuffix[pinNum]}'
        : 'Pin $pinNum';
  }

  /// Return a stream of pin events indicating state changes.
  Stream<PinEvent> get events {
    if (_events == null) {
      _events = new StreamController(onListen: () {
        if (_mode != input) {
          _events.addError(new GpioException._selector(this, 'events.listen'));
          return;
        }
        Gpio._instance._initInterrupts();
        Gpio._hardware.enableInterrupt(pinNum);
        _lastInterruptValue = value;
      }, onCancel: () {
        _events.close();
        _events = null;
        Gpio._instance._checkDisableAllInterrupts();
      });
    }
    return _events.stream;
  }

  /// Return the GPIO number for this pin
  int get gpioNum => Gpio._hardware.gpioNum(pinNum);

  /// Return the mode ([input], [output], [pulsed]) for this pin.
  PinMode get mode => _mode;

  /// Set the mode ([input], [output], [pulsed]) for this pin.
  void set mode(PinMode mode) {
    if (_mode == pulsed && mode != pulsed) {
      // Turn off software simulated pwm
      Gpio._instance._softPwm.pulseWidth(pinNum, null);
    }
    if (_mode == input && mode != input && _events != null) {
      throw new GpioException._mustCancelEventSubscription(this);
    }
    _mode = mode;
    if (pinNum != 1 && mode == pulsed) {
      // Simulate pulse width modulation using standard output mode
      Gpio._hardware.pinMode(pinNum, output.index);
    } else {
      Gpio._hardware.pinMode(pinNum, mode.index);
    }
  }

  /// Return the state of the pin's pull up/down resistor
  PinPull get pull => _pull;

  /// Set the state of the pin's pull up/down resistor.
  /// The internal pull up/down resistors have a value
  /// of approximately 50KΩ on the Raspberry Pi
  void set pull(PinPull pull) {
    if (mode != input) throw new GpioException._selector(this, 'pull');
    _pull = pull != null ? pull : pullOff;
    Gpio._hardware.pullUpDnControl(pinNum, _pull.index);
  }

  /// Set the pulse width (0 - 1024) for the given pin.
  /// The Raspberry Pi has one on-board PWM pin, pin 1 (BMC_GPIO 18, Phys 12).
  /// PWM on all other pins must be simulated via software.
  void set pulseWidth(int pulseWidth) {
    if (mode != pulsed) throw new GpioException._selector(this, 'pulseWidth');
    if (pinNum == 1) {
      Gpio._hardware.pwmWrite(pinNum, pulseWidth);
    } else {
      Gpio._instance._softPwm.pulseWidth(pinNum, pulseWidth);
    }
  }

  /// Return the digital value (0 = low, 1 = high) for this pin.
  int get value {
    if (mode != input) throw new GpioException._selector(this, 'value');
    return Gpio._hardware.digitalRead(pinNum);
  }

  /// Set the digital value (0 = low, 1 = high) for this pin.
  /// Any value other than zero is considered high.
  void set value(int value) {
    if (mode != output) throw new GpioException._selector(this, 'value=');
    Gpio._hardware.digitalWrite(pinNum, value);
  }

  @override
  String toString() => '$description $mode';

  /// Called when this pin's state has changed.
  /// Forward the event to listeners after filtering duplicate interrupts.
  void _handleInterrupt(int newValue) {
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
  final int value;

  PinEvent(this.pin, this.value);

  @override
  toString() => '$pin value: $value';
}

/// A pin can be set to receive [input] and interrupts, have a particular
/// [output] value, or be [pulsed] (Pulse Width Modulation or PWM).
enum PinMode { input, output, pulsed }

/// When a pin is in [input] mode, it can have an internal pull up or pull
/// down resistor connected.
enum PinPull { off, down, up }
