library rpi_gpio;

import 'dart:io';

const PinMode input = PinMode.input;
const PinMode output = PinMode.output;
const PinPull pullDown = PinPull.down;
const PinPull pullOff = PinPull.off;
const PinPull pullUp = PinPull.up;
const PinMode pulsed = PinMode.pulsed;

enum PinMode { input, output, pulsed }
enum PinPull { off, down, up }

/// Human readable description of known Raspberry Pi rev 2 GPIO pins
/// See http://wiringpi.com/pins/special-pin-functions/
/// and
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

const _pwmPinNum = 1;

/// Return [true] if this is running on a Raspberry Pi.
bool get isRaspberryPi =>
    //TODO need a better test for Raspberry Pi
    Platform.isLinux && new File('/home/pi/.raspberrypi').existsSync();

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

  Gpio._();

  /// Return the [Pin] representing the specified GPIO pin
  /// where [pinNum] is the wiringPi pin number.
  Pin pin(int pinNum, [PinMode mode]) {
    while (_pins.length <= pinNum) _pins.add(null);
    Pin pin = _pins[pinNum];
    if (pin == null) {
      pin = new Pin._(pinNum, mode);
      _pins[pinNum] = pin;
    } else if (mode != null) {
      pin.mode = mode;
    }
    return pin;
  }
}

class GpioException {
  final Pin pin;
  final String message;

  GpioException._hardwareAlreadySet()
      : pin = null,
        message = 'Gpio.hardware has already been set';

  GpioException._selector(this.pin, String selector)
      : message = 'Invalid call: $selector for mode';

  @override
  String toString() => '$message pin: $pin';
}

/// API used by [Gpio] for accessing the underlying hardware.
abstract class GpioHardware {
  int digitalRead(int pin);
  void digitalWrite(int pin, int value);
  void pinMode(int pin, int mode);
  void pullUpDnControl(int pin, int pud);
  void pwmWrite(int pin, int pulseWidth);
}

/// [Pin] represents a single GPIO pin for Raspberry Pi
/// based upon the wiringPi library. See [Gpio.pin].
class Pin {

  /// The wiringPi pin number.
  final int pin;

  /// The pin mode: [input], [output], [pulsed]
  PinMode _mode;

  /// The state of the pin's pull up/down resistor
  PinPull _pull = pullOff;

  Pin._(this.pin, PinMode mode) {
    this.mode = mode;
  }

  /// Return a human readable description of this pin
  String get description => pin >= 0 && pin <= _pinDescriptions.length
      ? _pinDescriptions[pin]
      : 'Pin $pin';

  /// Return the mode ([input], [output], [pulsed]) for this pin.
  PinMode get mode => _mode;

  /// Set the mode ([input], [output], [pulsed]) for this pin.
  void set mode(PinMode mode) {
    _mode = mode;
    Gpio._hardware.pinMode(pin, mode.index);
  }

  /// Return the state of the pin's pull up/down resistor
  PinPull get pull => _pull;

  /// Set the state of the pin's pull up/down resistor.
  /// The internal pull up/down resistors have a value
  /// of approximately 50KΩ on the Raspberry Pi
  void set pull(PinPull pull) {
    if (mode != input) throw new GpioException._selector(this, 'pull');
    _pull = pull != null ? pull : pullOff;
    Gpio._hardware.pullUpDnControl(pin, _pull.index);
  }

  /// Set the pulse width (0 - 1024) for the given pin.
  /// The Raspberry Pi has one on-board PWM pin, pin 1 (BMC_GPIO 18, Phys 12).
  /// PWM on all other pins must be simulated via software.
  void set pulseWidth(int pulseWidth) {
    if (mode != pulsed) throw new GpioException._selector(this, 'pulseWidth');
    Gpio._hardware.pwmWrite(pin, pulseWidth);
  }

  /// Return the digital value (0 = low, 1 = high) for this pin.
  int get value {
    if (mode != input) throw new GpioException._selector(this, 'value');
    return Gpio._hardware.digitalRead(pin);
  }

  /// Set the digital value (0 = low, 1 = high) for this pin.
  /// Any value other than zero is considered high.
  void set value(int value) {
    if (mode != output) throw new GpioException._selector(this, 'value=');
    Gpio._hardware.digitalWrite(pin, value);
  }

  @override
  String toString() => '$description $mode';
}
