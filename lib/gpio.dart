import 'dart:async';

import 'package:rpi_gpio/src/gpio_const.dart';

/// Base GPIO interface supported by all GPIO implementations.
abstract class Gpio {
  final _allocatedPins = <int>[];

  /// Call dispose before exiting your application to cleanup native resources.
  void dispose();

  /// Return a GPIO pin configured for input,
  /// where [physicalPin] is the physical pin number not the GPIO number.
  GpioInput input(int physicalPin, [Pull pull = Pull.off]);

  /// Return a GPIO pin configured for output,
  /// where [physicalPin] is the physical pin number not the GPIO number.
  GpioOutput output(int physicalPin);

  /// Return a GPIO pin configured for software based PWM,
  /// where [physicalPin] is the physical pin number not the GPIO number.
  GpioPwm pwm(int physicalPin);

  /// Set the polling frequency for any [GpioInput.values] streams.
  /// The default polling frequency is every 10 milliseconds.
  /// Pass `null` to turn off polling.
  set pollingFrequency(Duration frequency);

  /// Check that the pin can be used for GPIO
  /// and that is has not already been allocated.
  /// This should be called by subclasses not clients.
  void allocatePin(int physicalPin) {
    if (physicalPin < 0 ||
        physicalPin >= physToBcmGpioRPi2.length ||
        physToBcmGpioRPi2[physicalPin] < 0) {
      throw GpioException('Invalid pin', physicalPin);
    }
    if (_allocatedPins.contains(physicalPin)) {
      throwPinAlreadyAllocated(physicalPin);
    }
    _allocatedPins.add(physicalPin);
  }

  void throwPinAlreadyAllocated(int physicalPin) {
    throw GpioException('Already allocated', physicalPin);
  }
}

/// A GPIO input pin.
abstract class GpioInput {
  bool get value;

  /// When the value of the input changes,
  /// the new value is appended to the returned stream.
  Stream<bool> get values;
}

/// A GPIO output pin.
abstract class GpioOutput {
  set value(bool newValue);
}

/// A GPIO software driven PWM pin.
abstract class GpioPwm {
  /// Sets the percent of time that the GPIO pin is on/high/true,
  /// where 0 is off/low/false all of the time and 100 is on/high/true all of the time.
  set dutyCycle(int percentOn);
}

/// A [GpioInput] can have an internal pull up or pull down resistor.
enum Pull { off, down, up }

/// Exceptions thrown by GPIO.
class GpioException {
  final String message;
  final int physicalPin;

  GpioException(this.message, [this.physicalPin]);

  @override
  String toString() =>
      physicalPin != null ? '$message pin: $physicalPin' : message;
}
