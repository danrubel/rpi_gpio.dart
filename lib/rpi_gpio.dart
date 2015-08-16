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

/// Human readable description of known Raspberry Pi rev 2 GPIO pins
/// See http://wiringpi.com/pins/special-pin-functions/
const List<String> _pinDescriptions = const [
  'Pin 0  (BMC_GPIO 17, Phys 11)',
  'Pin 1  (BMC_GPIO 18, Phys 12, PMW)',
  'Pin 2  (BMC_GPIO 27, Phys 13)', // BMC_GPIO 21 on rev 1 board
  'Pin 3  (BMC_GPIO 22, Phys 15)',
  'Pin 4  (BMC_GPIO 23, Phys 16)',
  'Pin 5  (BMC_GPIO 24, Phys 18)',
  'Pin 6  (BMC_GPIO 25, Phys 22)',
  'Pin 7  (BMC_GPIO 4,  Phys 7,  Clock)',
  'Pin 8  (BMC_GPIO 2,  Phys 3,  I2C SDA0/1)', // BMC_GPIO 0 on rev 1 board
  'Pin 9  (BMC_GPIO 3,  Phys 5,  I2C SCL0/1)', // BMC_GPIO 1 on rev 1 board
  'Pin 10 (BMC_GPIO 8,  Phys 24, SPI CE0)',
  'Pin 11 (BMC_GPIO 7,  Phys 26, SPI CE1)',
  'Pin 12 (BMC_GPIO 10, Phys 19, SPI MOSI)',
  'Pin 13 (BMC_GPIO 9,  Phys 21, SPI MISO)',
  'Pin 14 (BMC_GPIO 11, Phys 23, SPI SCLK)',
  'Pin 15 (BMC_GPIO 14, Phys 8,  UART TxD, Console)',
  'Pin 16 (BMC_GPIO 15, Phys 10, UART RxD, Console)',
  'Pin 17 (BMC_GPIO 28, Phys P5-3)',
  'Pin 18 (BMC_GPIO 29, Phys P5-4)',
  'Pin 19 (BMC_GPIO 30, Phys P5-5)',
  'Pin 20 (BMC_GPIO 31, Phys P5-6)',
];

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

  List<Pin> _pins = <Pin>[];

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
      if (_pins[pinNum]._events != null) {
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
/// based upon the wiringPi library. See [Gpio.pin].
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
  String get description => pinNum >= 0 && pinNum <= _pinDescriptions.length
      ? _pinDescriptions[pinNum]
      : 'Pin $pinNum';

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
