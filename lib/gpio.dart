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
/// [output] value, or be [pulsed] (Pulse Width Modulation or PWM).
enum Mode { input, output, pulsed }
