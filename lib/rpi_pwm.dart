library rpi_pwm;

import 'dart:async';

import 'package:rpi_gpio/rpi_gpio.dart';

/// [PulseEntry] records the pin and desired pulse width for that pin
/// along with a link to the next larger pulse width entry.
class PulseEntry {
  static final PulseEntry REMOVED = new PulseEntry(-1, -1);

  final int pinNum;
  final int pulseWidth;

  /// The next entry in the sequence of pulses
  /// or `null` this is the last entry in the sequence
  /// or [PulseEntry.REMOVED] if it has been removed from the sequence.
  PulseEntry next;

  PulseEntry(this.pinNum, this.pulseWidth, [this.next]);

  /// Add the given pin/pulse to the list of pulse width entries
  /// while keeping the sequence sorted by pulse width.
  /// Return the first entry in the revised sequence.
  static PulseEntry add(PulseEntry first, int pinNum, int pulseWidth) {
    var newEntry = new PulseEntry(pinNum, pulseWidth);
    if (first == null || pulseWidth < first.pulseWidth) {
      newEntry.next = first;
      return newEntry;
    }
    PulseEntry entry = first;
    while (entry.next != null && entry.next.pulseWidth < pulseWidth) {
      entry = entry.next;
    }
    newEntry.next = entry.next;
    entry.next = newEntry;
    return first;
  }

  /// Remove the given pin from the list of pulse width entries.
  /// Return the first entry in the revised sequence.
  static PulseEntry remove(PulseEntry first, int pinNum) {
    if (first == null) return first;
    if (first.pinNum == pinNum) {
      var next = first.next;
      first.next = REMOVED;
      return next;
    }
    PulseEntry entry = first;
    while (entry.next != null) {
      if (entry.next.pinNum == pinNum) {
        var next = entry.next;
        entry.next = next.next;
        next.next = REMOVED;
        break;
      }
      entry = entry.next;
    }
    return first;
  }

  /// Update the values of the listed pins based upon the current position.
  /// Return the next entry to be updated,
  /// or `null` if the next update is the beginning of a cycle,
  /// or [REMOVED] if there are no entries to be updated.
  static PulseEntry updateValues(
      GpioHardware hardware, PulseEntry first, PulseEntry current) {
    if (first == null) return REMOVED;
    if (current == null) {
      // If this is the start of a cycle, then turn on all pwm pins
      // and schedule a timer for the first pin that should be turned off
      PulseEntry entry = first;
      while (entry != null) {
        hardware.digitalWrite(entry.pinNum, 1);
        entry = entry.next;
      }
      return first;
    }
    int pulseWidth = current.pulseWidth;
    if (current.next == REMOVED) current = first;
    while (current != null && current.pulseWidth <= pulseWidth) {
      if (current.pulseWidth == pulseWidth) {
        hardware.digitalWrite(current.pinNum, 0);
      }
      current = current.next;
    }
    return current;
  }
}

/// The Raspberry Pi pin 1 supports hardware based pulse width modulation.
/// For all other pins, [SoftwarePWM] simulates pwm.
class SoftwarePWM {
  final GpioHardware _hardware;

  /// The current timer
  Timer _timer;

  /// The first entry in a sequence of pulse widths to be simulated
  /// or `null` if none.
  PulseEntry _firstEntry;

  /// The next entry in the sequence to be visited by the timer.
  PulseEntry _nextEntry;

  SoftwarePWM(this._hardware);

  /// Set the pulse width for the given pin.
  /// pulseWidth >= 1024 set the pin value to one.
  /// pulseWidth <= 0 sets the pin value to zero.
  /// pulseWidth == `null` turns off pulsing for the given pin.
  void pulseWidth(int pinNum, int pulseWidth) {
    _firstEntry = PulseEntry.remove(_firstEntry, pinNum);
    if (pulseWidth != null) {
      if (pulseWidth >= 1024) {
        _hardware.digitalWrite(pinNum, 1);
      } else {
        _hardware.digitalWrite(pinNum, 0);
        if (pulseWidth > 0) {
          _firstEntry = PulseEntry.add(_firstEntry, pinNum, pulseWidth);
        }
      }
    }
    _updateValues();
  }

  /// Update the digital state of the pins in the pulse sequence.
  void _updateValues([_]) {
    int start = _nextEntry != null ? _nextEntry.pulseWidth : 0;
    _nextEntry = PulseEntry.updateValues(_hardware, _firstEntry, _nextEntry);
    if (_nextEntry != PulseEntry.REMOVED) {
      int end = _nextEntry != null ? _nextEntry.pulseWidth : 1024;
      Duration delta = new Duration(microseconds: (end - start) * 10);
      _timer = new Timer(delta, _updateValues);
    } else {
      _nextEntry = null;
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
    }
  }
}
