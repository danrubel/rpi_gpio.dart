library rpi_gpio;

import 'dart:io';
import 'dart:isolate';

import 'package:rpi_gpio/gpio.dart';

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

/// When a pin is in [Mode.input] mode, it can have an internal pull up or pull
/// down resistor connected.
enum Pull { off, down, up }

/// GPIO interface used for accessing GPIO on the Raspberry Pi.
abstract class RpiGPIO implements GPIO {
  /// Bit mask used for extracting the pin # from the interrupt event.
  /// See [initInterrupts].
  static final pinNumMask = 0x7F;

  /// Bit mask used for extracting the value from the interrupt event.
  /// See [initInterrupts].
  static final pinValueMask = 0x80;

  /// Return a short one line human readable description of the pin, including
  /// the GPIO #, physical pin #, and special pin function as appropriate.
  /// This is an OPTIONAL method and callers should be prepared to handle
  /// a `null` return value and exceptions such as [NoSuchMethodError].
  String description(int pinNum);

  /// Disable the background interrupt listener.
  void disableAllInterrupts();

  /// Initialize the background interrupt listener.
  /// Once called, interrupt events will be sent to [port].
  /// Each message is an int indicating the pin on which the interrupt occurred
  /// and the value of that pin at the time of the interrupt:
  ///
  ///     int message = pinNum | (pinValue ? RpiGPIO.pinValueMask : 0);
  ///
  ///     int pinNum = message & RpiGPIO.pinNumMask;
  ///     bool pinValue = (message & RpiGPIO.pinValueMask) != 0;
  ///
  /// Throws an exception if interrupts have already been initialized.
  void initInterrupts(SendPort port);

  /// Set the internal pull up/down resistor attached to the given pin,
  /// which can be any of [Pull] (e.g. [Pull.up.index]).
  /// The pin should be set to [Mode.input] before calling this method.
  void setPull(int pinNum, Pull pull);

  /// Set the pulse width for the given pin.
  /// The pulse width is a number between 0 and 1024 representing the amount
  /// of time out of 1024 that the pin outputs a high value rather than ground.
  /// The pin should be set to [Mode.output] before calling this method.
  void setPulseWidth(int pinNum, int pulseWidth);

  /// Sets the interrupt trigger for [pinNum] to [trigger].
  /// Throws an exception if [initInterrupts] has not been called
  /// or if there cannot be any more active interrupts.
  /// The pin should be set to [Mode.input] before calling this method.
  void setTrigger(int pinNum, Trigger trigger);
}
