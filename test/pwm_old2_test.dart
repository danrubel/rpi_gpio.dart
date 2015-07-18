library test.rpi_pwm;

import 'dart:async';

import 'package:rpi_gpio/rpi_pwm.dart';
import 'package:test/test.dart';

import 'mock_hardware.dart';

main() {
  group('SoftwarePWM', () {

    // Mock hardware used by pwm_old1_test.dart for testing the [Gpio] library
    // on platforms other than the Raspberry Pi. This simulates
    // pin 3 = an LED (1 = on, 0 = off)
    // pin 2 = a photo resistor detecting the state of the LED on pin 3
    MockHardware hardware = new MockHardware();
    SoftwarePWM pwm = new SoftwarePWM(hardware);

    test('on/off', () async {
      hardware.reset();
      pwm.pulseWidth(3, 1024);
      await _delay(5);
      expect(hardware.values[3], 1);
      expect(hardware.stateChanges, hasLength(1));
      pwm.pulseWidth(3, 0);
      await _delay(5);
      expect(hardware.values[3], 0);
      expect(hardware.stateChanges, hasLength(2));
    });

    test('pulsed', () async {
      hardware.reset();
      pwm.pulseWidth(3, 400);
      await _delay(30);
      StateChange previous;
      for (StateChange change in hardware.stateChanges) {
        var delta = change.time.difference(previous != null ? previous.time : change.time);
        print('$delta - ${change.pinNum} - ${change.value}');
        previous = change;
      }
      var len = hardware.stateChanges.length;
      print('$len state changes');
      var delta = hardware.stateChanges[len - 1].time.difference(hardware.stateChanges[0].time);
      print('over time $delta');
      expect(len, greaterThan(5));
      pwm.pulseWidth(3, 0);
      int expected = len;
      await _delay(5);
      expect(hardware.values[3], 0);
      expect(len, expected);
    });
  });

  group('PulseEntry', () {
    test('add', () {
      PulseEntry first = PulseEntry.add(null, 3, 200);
      _expectPulseEntries(first, [3, 200]);
      first = PulseEntry.add(first, 4, 500);
      _expectPulseEntries(first, [3, 200, 4, 500]);
      first = PulseEntry.add(first, 5, 100);
      _expectPulseEntries(first, [5, 100, 3, 200, 4, 500]);
      first = PulseEntry.add(first, 6, 150);
      _expectPulseEntries(first, [5, 100, 6, 150, 3, 200, 4, 500]);
    });
    test('remove', () {
      PulseEntry entry4 = new PulseEntry(4, 500);
      PulseEntry entry3 = new PulseEntry(3, 200, entry4);
      PulseEntry entry6 = new PulseEntry(6, 150, entry3);
      PulseEntry entry5 = new PulseEntry(5, 100, entry6);
      PulseEntry first = entry5;
      _expectPulseEntries(first, [5, 100, 6, 150, 3, 200, 4, 500]);
      first = PulseEntry.remove(first, 7);
      _expectPulseEntries(first, [5, 100, 6, 150, 3, 200, 4, 500]);
      first = PulseEntry.remove(first, 6);
      expect(entry6.next, PulseEntry.REMOVED);
      _expectPulseEntries(first, [5, 100, 3, 200, 4, 500]);
      first = PulseEntry.remove(first, 5);
      expect(entry5.next, PulseEntry.REMOVED);
      _expectPulseEntries(first, [3, 200, 4, 500]);
      first = PulseEntry.remove(first, 4);
      expect(entry4.next, PulseEntry.REMOVED);
      _expectPulseEntries(first, [3, 200]);
      first = PulseEntry.remove(first, 3);
      expect(entry3.next, PulseEntry.REMOVED);
      expect(first, isNull);
      first = PulseEntry.remove(first, 3);
      expect(first, isNull);
    });
    test('pulse', () {
      MockHardware hardware = new MockHardware();

      // Empty list
      PulseEntry next = PulseEntry.updateValues(hardware, null, null);
      expect(next, PulseEntry.REMOVED);
      _expectStateChanges(hardware, []);

      // One entry
      PulseEntry first = new PulseEntry(4, 500);
      hardware.reset();
      next = PulseEntry.updateValues(hardware, first, null);
      expect(next, first);
      _expectStateChanges(hardware, [4, 1]);
      hardware.reset();
      next = PulseEntry.updateValues(hardware, first, next);
      expect(next, null);
      _expectStateChanges(hardware, [4, 0]);

      // Two entries
      first = new PulseEntry(3, 200, first);
      _expectPulseEntries(first, [3, 200, 4, 500]);
      hardware.reset();
      next = PulseEntry.updateValues(hardware, first, null);
      expect(next, first);
      _expectStateChanges(hardware, [3, 1, 4, 1]);
      hardware.reset();
      next = PulseEntry.updateValues(hardware, first, next);
      expect(next, first.next);
      _expectStateChanges(hardware, [3, 0]);
      hardware.reset();
      next = PulseEntry.updateValues(hardware, first, next);
      expect(next, null);
      _expectStateChanges(hardware, [4, 0]);

      // Removed entry
      hardware.reset();
      next = PulseEntry.updateValues(
          hardware, first, new PulseEntry(7, 50, PulseEntry.REMOVED));
      expect(next, first);
      _expectStateChanges(hardware, []);
      hardware.reset();
      next = PulseEntry.updateValues(
          hardware, first, new PulseEntry(7, 200, PulseEntry.REMOVED));
      expect(next, first.next);
      _expectStateChanges(hardware, [3, 0]);
      hardware.reset();
      next = PulseEntry.updateValues(
          hardware, first, new PulseEntry(7, 250, PulseEntry.REMOVED));
      expect(next, first.next);
      _expectStateChanges(hardware, []);
      hardware.reset();
      next = PulseEntry.updateValues(
          hardware, first, new PulseEntry(7, 500, PulseEntry.REMOVED));
      expect(next, null);
      _expectStateChanges(hardware, [4, 0]);
      hardware.reset();
      next = PulseEntry.updateValues(
          hardware, first, new PulseEntry(7, 550, PulseEntry.REMOVED));
      expect(next, null);
      _expectStateChanges(hardware, []);
    });
  });
}

void _expectStateChanges(MockHardware hardware, List<int> values) {
  List<StateChange> stateChanges = hardware.stateChanges;
  if (values == null || values.isEmpty) {
    expect(stateChanges, hasLength(0));
    return;
  }
  int index = 0;
  int count = 0;
  while (index < values.length) {
    expect(stateChanges.length, greaterThan(count));
    expect(stateChanges[count].pinNum, values[index]);
    ++index;
    expect(stateChanges[count].value, values[index]);
    ++index;
    ++count;
  }
}

void _expectPulseEntries(PulseEntry first, List<int> values) {
  if (values == null || values.isEmpty) {
    expect(first, isNull);
    return;
  }
  PulseEntry entry = first;
  int index = 0;
  int count = 0;
  while (index < values.length) {
    ++count;
    if (entry == null) fail('Expected more than $count entries');
    expect(entry.pinNum, values[index]);
    ++index;
    expect(entry.pulseWidth, values[index]);
    ++index;
    entry = entry.next;
  }
  if (entry != null) fail('Found more than $count entries');
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}
