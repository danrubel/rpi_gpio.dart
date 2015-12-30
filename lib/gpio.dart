library gpio;

/// Base GPIO interface supported by all GPIO implementations.
abstract class GPIO {
  /// The default number of pins for wiringPi GPIO is 20.
  static const int defaultPins = 20;

  /// Number of pins exposed by this GPIO.
  int get pins;

  /// Get the value of the [pin].
  /// The boolean value [true] represents high (1)
  /// and the boolean value [false] represents low (0).
  /// The pin mode should already be set to [Mode.input].
  bool getPin(int pin);

  /// Set the mode of [pin] to [mode]
  /// where [mode] can be [Mode.input] or [Mode.output].
  void setMode(int pin, Mode mode);

  /// Set the value of the [pin] to [value].
  /// The boolean value [true] represents high (1)
  /// and the boolean value [false] represents low (0).
  /// The pin mode should already be set to [Mode.output].
  void setPin(int pin, bool value);
}

/// Exceptions thrown by GPIO.
class GPIOException {
  /// Exception message.
  final String message;
  final int pinNum;

  GPIOException(this.message, [this.pinNum]);

  GPIOException.invalidCall(this.pinNum, String selector)
      : message = 'Invalid call: $selector for mode';

  @override
  String toString() => '$message pin: $pinNum';
}

/// A GPIO pin can be set to receive [input] and interrupts, have a particular
/// [output] value or pulseWidth, or be in some [other] mode.
enum Mode {
  input,
  output,

  /// GPIO has functions other than [input] and [output]. Most GPIO pins have
  /// several special functions, so when in that mode this value can be
  /// returned. This value cannot be used when setting the mode.
  other
}

/// A GPIO pin can be set to receive interrupts
/// on the [rising] edge (was `false` and becomes `true`),
/// on the [falling] edge (was `true` and becomes `false`),
/// or [both].
enum Trigger { none, rising, falling, both, }
