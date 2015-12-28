library gpio;

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
enum Mode { input, output,
  /// GPIO has functions other than [input] and [output]. Most GPIO pins have
  /// several special functions, so when in that mode this value can be
  /// returned. This value cannot be used when setting the mode.
  other }
